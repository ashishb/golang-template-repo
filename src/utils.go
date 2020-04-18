package main

import (
	"encoding/base64"
	"github.com/golang/glog"
	"os"
	"strings"
)

// GetEnvVarOrFail returns the value of an environment variable.
// It fails if the value isn't available.
func GetEnvVarOrFail(varName string) string {
	value := strings.TrimSpace(os.Getenv(varName))
	if len(value) == 0 {
		glog.Fatalf("Environment variable %s is not set", varName)
	}
	return value
}

// GetBase64DecodedEnvVarOrFail returns the base 64 decoded value of an environment variable.
// It fails if the value isn't available or it cannot be decoded via Standard Base64 decoding.
func GetBase64DecodedEnvVarOrFail(varName string) []byte {
	value := GetEnvVarOrFail(varName)
	result, err := base64.StdEncoding.DecodeString(value)
	if err != nil {
		glog.Fatalf("Failed to do base 64 decoding of the value of %s: \"%s\", error: %v",
			varName, value, err)
	}
	return result
}
