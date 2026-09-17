# Observability & Configuration

---

## 1. Structured Logging with `log/slog`

> **Principle**: Log an error where it can be acted upon, not at every layer it passes through.

```go
package main

import (
    "log/slog"
    "os"
)

func SetupLogger() *slog.Logger {
    handler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
        Level: slog.LevelInfo,
    })
    logger := slog.New(handler)
    slog.SetDefault(logger)
    return logger
}

func HandleJob(logger *slog.Logger, jobID string, userID string) {
    logger.Info("processing background job",
        slog.String("job_id", jobID),
        slog.String("user_id", userID),
    )
}
```

---

## 2. Startup Configuration Parsing & Validation

```go
package config

import (
    "fmt"
    "os"
    "strconv"
)

type Config struct {
    DatabaseURL string
    Port        int
    APIKey      string // Secret: never log or expose
}

func LoadFromEnv() (*Config, error) {
    dbURL := os.Getenv("DATABASE_URL")
    if dbURL == "" {
        return nil, fmt.Errorf("DATABASE_URL is required")
    }

    portStr := os.Getenv("PORT")
    if portStr == "" {
        portStr = "8080"
    }
    port, err := strconv.Atoi(portStr)
    if err != nil {
        return nil, fmt.Errorf("invalid PORT: %w", err)
    }

    apiKey := os.Getenv("API_KEY")
    if apiKey == "" {
        return nil, fmt.Errorf("API_KEY is required")
    }

    return &Config{DatabaseURL: dbURL, Port: port, APIKey: apiKey}, nil
}
```
