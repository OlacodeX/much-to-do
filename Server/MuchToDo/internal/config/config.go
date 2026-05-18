package config

import (
	"fmt"

	"github.com/spf13/viper"
)

// Config stores all configuration of the application.
type Config struct {
	ServerPort       string `mapstructure:"PORT"`
	MongoURI         string `mapstructure:"MONGO_URI"`
	DBName           string `mapstructure:"DB_NAME"`
	JWTSecretKey     string `mapstructure:"JWT_SECRET_KEY"`
	JWTExpirationHours int    `mapstructure:"JWT_EXPIRATION_HOURS"`
	EnableCache      bool   `mapstructure:"ENABLE_CACHE"`
	RedisAddr        string `mapstructure:"REDIS_ADDR"`
	RedisPassword    string `mapstructure:"REDIS_PASSWORD"`
	LogLevel      string `mapstructure:"LOG_LEVEL"`
	LogFormat     string `mapstructure:"LOG_FORMAT"`
}

// LoadConfig reads configuration from file or environment variables.
func LoadConfig(path string) (config Config, err error) {
	viper.AddConfigPath(path)
	viper.SetConfigName(".env")
	viper.SetConfigType("env")

	viper.AutomaticEnv()

	for _, key := range []string{
		"PORT", "APP_PORT", "MONGO_URI", "DB_NAME", "JWT_SECRET_KEY",
		"JWT_EXPIRATION_HOURS", "ENABLE_CACHE", "REDIS_ADDR", "REDIS_HOST",
		"REDIS_PORT", "REDIS_PASSWORD", "LOG_LEVEL", "LOG_FORMAT",
	} {
		if err = viper.BindEnv(key); err != nil {
			return
		}
	}

	viper.SetDefault("PORT", "8080")
	viper.SetDefault("ENABLE_CACHE", false)
	viper.SetDefault("JWT_EXPIRATION_HOURS", 72)

	err = viper.ReadInConfig()
	if err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			return
		}
	}

	err = viper.Unmarshal(&config)
	if err != nil {
		return
	}

	if config.ServerPort == "" {
		config.ServerPort = viper.GetString("APP_PORT")
	}
	if config.ServerPort == "" {
		config.ServerPort = "8080"
	}
	if config.RedisAddr == "" {
		host := viper.GetString("REDIS_HOST")
		port := viper.GetString("REDIS_PORT")
		if host != "" && port != "" {
			config.RedisAddr = fmt.Sprintf("%s:%s", host, port)
		}
	}

	return
}

