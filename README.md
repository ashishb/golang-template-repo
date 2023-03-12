# GoLang + Docker + Google Cloud Run template repository [![Test](https://github.com/ashishb/golang-template-repo/actions/workflows/test.yml/badge.svg)](https://github.com/ashishb/golang-template-repo/actions/workflows/test.yml) [![Build docker image](https://github.com/ashishb/golang-template-repo/actions/workflows/docker-test.yml/badge.svg)](https://github.com/ashishb/golang-template-repo/actions/workflows/docker-test.yml)


## Basic development

1. Init using your preferred GoLang module name, for example, `make init NAME=github.com/ashishb/golang-template-repo`
2. Write the code in `src/`
3. Format it using `make format`
4. Lint it using `make lint`
5. Build it using `make build`. If required, clean it using `make clean`
6. If you have written any tests then test using `make test`
7. Run using `make run`
8. Note: If you are on Mac OS, you can explicitly build for 64-bit GNU/Linux using `make build_linux`

## Docker
1. Build docker image using `make docker_build`
2. Test using `make docker_run`

## Google cloud run deployment
1. Create a new project on [Google Cloud](https://console.cloud.google.com/)
2. Put the project ID (not project name) in `GOOGLE_CLOUD_PROJECT_NAME` variable in Makefile
3. Create a new Cloud run service at [https://console.cloud.google.com/run](https://console.cloud.google.com/run)
4. Put the cloud run service name in `GOOGLE_CLOUD_RUN_SERVICE_NAME` variable in Makefile
5. Install [google-cloud-sdk](https://formulae.brew.sh/cask/google-cloud-sdk)
6. Run `make docker_gcr_login`. This is only required only once on your Google Cloud SDK installation
7. Now, push your local image to Google Cloud registry using `make docker_gcr_push`
8. And deploy the image using `make gcloud_deploy`
