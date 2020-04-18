package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

const homepageEndPoint = "/"
const dynamicEndpoint = "/dynamic"

var secret string

// StartWebServer the webserver
func StartWebServer() {
	port := os.Getenv("PORT")
	if len(port) == 0 {
		panic("Environment variable PORT is not set")
	}
	secret = strings.TrimSpace(string(GetBase64DecodedEnvVarOrFail("SECRET_VALUE")))
	http.Handle(homepageEndPoint, http.FileServer(http.Dir("./website")))
	http.HandleFunc(dynamicEndpoint, handleDynamic)

	log.Printf("Starting web server to listen on endpoints [%s] and port %s",
		homepageEndPoint, port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		panic(err)
	}
}

func handleDynamic(w http.ResponseWriter, r *http.Request) {
	urlPath := r.URL.Path
	log.Printf("Web request received on url path %s", urlPath)
	msg := fmt.Sprintf("Hello world from GoLang at %s. Secret value is \"%s\"",
		time.Now().Format("Jan 2 2006 15:04:05"), secret)
	_, err := w.Write([]byte(msg))
	if err != nil {
		fmt.Printf("Failed to write response, err: %s", err)
	}
}

func main() {
	StartWebServer()
}
