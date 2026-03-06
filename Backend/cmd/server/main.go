package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/hibiken/asynq"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/config"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/handler"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/service"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/storage"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/worker"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
	slog.SetDefault(logger)

	cfg, err := config.Load()
	if err != nil {
		slog.Error("failed to load config", "error", err)
		os.Exit(1)
	}

	// Initialize Supabase store
	store, err := storage.NewSupabaseStore(cfg.DatabaseURL, cfg.SupabaseURL, cfg.SupabaseServiceKey)
	if err != nil {
		slog.Error("failed to connect to database", "error", err)
		os.Exit(1)
	}
	defer store.Close()

	// Initialize Redis client options for Asynq
	redisOpt := asynq.RedisClientOpt{
		Addr:     cfg.RedisAddr,
		Password: cfg.RedisPassword,
		DB:       cfg.RedisDB,
	}

	// Initialize Asynq client (for enqueuing tasks)
	asynqClient := asynq.NewClient(redisOpt)
	defer asynqClient.Close()

	// Initialize services
	azureClient := service.NewAzureClient(cfg.AzureSpeechKey, cfg.AzureSpeechRegion)
	openaiClient := service.NewOpenAIClient(cfg.OpenAIKey, cfg.OpenAIModel)
	scorer := service.NewScorer()
	evaluator := service.NewEvaluator(store, azureClient, openaiClient, scorer)

	// Initialize Asynq worker server
	asynqServer := asynq.NewServer(redisOpt, asynq.Config{
		Concurrency: cfg.MaxConcurrentEvaluations,
		Queues:      map[string]int{"evaluation": 10},
		Logger:      newAsynqLogger(),
	})

	// Register task handlers
	mux := asynq.NewServeMux()
	processor := worker.NewProcessor(evaluator)
	mux.HandleFunc(worker.TypeEvaluateSession, processor.HandleEvaluateSession)

	// Start Asynq worker in background
	go func() {
		if err := asynqServer.Start(mux); err != nil {
			slog.Error("failed to start asynq worker", "error", err)
			os.Exit(1)
		}
	}()

	// Set up HTTP server
	h := handler.NewHandler(asynqClient, store, cfg.Secret)
	httpMux := http.NewServeMux()
	httpMux.HandleFunc("POST /evaluate", h.Evaluate)
	httpMux.HandleFunc("GET /health", h.Health)

	server := &http.Server{
		Addr:         ":" + cfg.Port,
		Handler:      httpMux,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	// Start HTTP server
	go func() {
		slog.Info("starting HTTP server", "port", cfg.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			slog.Error("HTTP server error", "error", err)
			os.Exit(1)
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	slog.Info("shutting down...")
	asynqServer.Shutdown()

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	if err := server.Shutdown(ctx); err != nil {
		slog.Error("HTTP server shutdown error", "error", err)
	}

	slog.Info("server stopped")
}

// asynqLogger adapts slog for Asynq's logger interface.
type asynqLogger struct{}

func newAsynqLogger() *asynqLogger { return &asynqLogger{} }

func (l *asynqLogger) Debug(args ...interface{}) { slog.Debug("asynq", "msg", args) }
func (l *asynqLogger) Info(args ...interface{})  { slog.Info("asynq", "msg", args) }
func (l *asynqLogger) Warn(args ...interface{})  { slog.Warn("asynq", "msg", args) }
func (l *asynqLogger) Error(args ...interface{}) { slog.Error("asynq", "msg", args) }
func (l *asynqLogger) Fatal(args ...interface{}) { slog.Error("asynq fatal", "msg", args) }
