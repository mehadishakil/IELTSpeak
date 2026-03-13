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

	// Initialize Supabase store (DB + legacy storage)
	store, err := storage.NewSupabaseStore(cfg.DatabaseURL, cfg.SupabaseURL, cfg.SupabaseServiceKey)
	if err != nil {
		slog.Error("failed to connect to database", "error", err)
		os.Exit(1)
	}
	defer store.Close()

	// Initialize Cloudflare R2 client (optional, falls back to Supabase Storage)
	var r2Client *storage.R2Client
	if cfg.R2Enabled() {
		r2Client, err = storage.NewR2Client(cfg.R2AccountID, cfg.R2AccessKey, cfg.R2SecretKey, cfg.R2BucketName)
		if err != nil {
			slog.Error("failed to initialize R2 client", "error", err)
			os.Exit(1)
		}
		slog.Info("Cloudflare R2 storage initialized", "bucket", cfg.R2BucketName)
	} else {
		slog.Warn("Cloudflare R2 not configured, using Supabase Storage as fallback")
	}

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
	evaluator := service.NewEvaluator(store, r2Client, azureClient, openaiClient, scorer)

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

	// Set up HTTP handlers
	h := handler.NewHandler(asynqClient, store, cfg.Secret)

	// Upload handler (only if R2 is configured)
	var uploadHandler *handler.UploadHandler
	if r2Client != nil {
		uploadHandler = handler.NewUploadHandler(r2Client, store, asynqClient, cfg.Secret)
	}

	// Questions handler (serves questions with R2 pre-signed audio URLs)
	questionsHandler := handler.NewQuestionsHandler(r2Client, store, cfg.Secret)

	// Set up HTTP routes
	httpMux := http.NewServeMux()

	// Core evaluation endpoints
	httpMux.HandleFunc("POST /evaluate", h.Evaluate)
	httpMux.HandleFunc("GET /health", h.Health)

	// Questions endpoint (supports both server secret and Supabase JWT auth)
	httpMux.HandleFunc("GET /test-questions", questionsHandler.GetTestQuestions)

	// R2 upload endpoints (only registered if R2 is configured)
	if uploadHandler != nil {
		httpMux.HandleFunc("POST /generate-upload-url", uploadHandler.GenerateUploadURL)
		httpMux.HandleFunc("POST /upload-complete", uploadHandler.UploadComplete)
		httpMux.HandleFunc("GET /quota", uploadHandler.GetQuota)
		slog.Info("R2 upload endpoints registered: /generate-upload-url, /upload-complete, /quota")
	}

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
