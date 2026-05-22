package config

import (
	"os"
	"testing"

	"github.com/spf13/viper"
)

func TestLoadConfigFromEnvWithoutFile(t *testing.T) {
	viper.Reset()
	t.Setenv("MONGO_URI", "mongodb+srv://user:pass@cluster.mongodb.net/?appName=test")
	t.Setenv("DB_NAME", "much_todo_db")
	t.Setenv("JWT_SECRET_KEY", "test-secret")
	t.Setenv("PORT", "8080")
	t.Setenv("ENABLE_CACHE", "false")

	cfg, err := LoadConfig(t.TempDir())
	if err != nil {
		t.Fatalf("LoadConfig: %v", err)
	}
	if cfg.MongoURI != "mongodb+srv://user:pass@cluster.mongodb.net/?appName=test" {
		t.Fatalf("MongoURI = %q, want mongodb+srv URI from env", cfg.MongoURI)
	}
	if cfg.DBName != "much_todo_db" {
		t.Fatalf("DBName = %q", cfg.DBName)
	}
	if cfg.JWTSecretKey != "test-secret" {
		t.Fatalf("JWTSecretKey not loaded from env")
	}
}

func TestMain(m *testing.M) {
	code := m.Run()
	viper.Reset()
	os.Exit(code)
}
