package config

import (
	"fmt"
	"os"
	"strconv"
)

type Config struct {
	Port          string
	Secret        string
	RedisAddr     string
	RedisPassword string
	RedisDB       int

	DatabaseURL        string
	SupabaseURL        string
	SupabaseServiceKey string

	AzureSpeechKey    string
	AzureSpeechRegion string

	OpenAIKey   string
	OpenAIModel string

	// Cloudflare R2
	R2AccountID  string
	R2AccessKey  string
	R2SecretKey  string
	R2BucketName string

	MaxConcurrentEvaluations int
}

func Load() (*Config, error) {
	cfg := &Config{
		Port:                     getEnv("PORT", "8080"),
		Secret:                   getEnv("SERVER_SECRET", ""),
		RedisAddr:                getEnv("REDIS_ADDR", "localhost:6379"),
		RedisPassword:            getEnv("REDIS_PASSWORD", ""),
		RedisDB:                  getEnvInt("REDIS_DB", 0),
		DatabaseURL:              getEnv("DATABASE_URL", ""),
		SupabaseURL:              getEnv("SUPABASE_URL", ""),
		SupabaseServiceKey:       getEnv("SUPABASE_SERVICE_ROLE_KEY", ""),
		AzureSpeechKey:           getEnv("AZURE_SPEECH_KEY", ""),
		AzureSpeechRegion:        getEnv("AZURE_SPEECH_REGION", "eastus"),
		OpenAIKey:                getEnv("OPENAI_API_KEY", ""),
		OpenAIModel:              getEnv("OPENAI_MODEL", "gpt-4o-mini"),
		R2AccountID:              getEnv("CLOUDFLARE_R2_ACCOUNT_ID", ""),
		R2AccessKey:              getEnv("CLOUDFLARE_R2_ACCESS_KEY", ""),
		R2SecretKey:              getEnv("CLOUDFLARE_R2_SECRET_KEY", ""),
		R2BucketName:             getEnv("R2_BUCKET_NAME", "ielts-audio"),
		MaxConcurrentEvaluations: getEnvInt("MAX_CONCURRENT_EVALUATIONS", 5),
	}

	if err := cfg.validate(); err != nil {
		return nil, err
	}
	return cfg, nil
}

// R2Enabled returns true if all R2 configuration is present.
func (c *Config) R2Enabled() bool {
	return c.R2AccountID != "" && c.R2AccessKey != "" && c.R2SecretKey != ""
}

func (c *Config) validate() error {
	required := map[string]string{
		"SERVER_SECRET":             c.Secret,
		"DATABASE_URL":              c.DatabaseURL,
		"SUPABASE_URL":              c.SupabaseURL,
		"SUPABASE_SERVICE_ROLE_KEY": c.SupabaseServiceKey,
		"AZURE_SPEECH_KEY":          c.AzureSpeechKey,
		"OPENAI_API_KEY":            c.OpenAIKey,
	}
	for name, val := range required {
		if val == "" {
			return fmt.Errorf("required environment variable %s is not set", name)
		}
	}
	return nil
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	if v := os.Getenv(key); v != "" {
		if i, err := strconv.Atoi(v); err == nil {
			return i
		}
	}
	return fallback
}
