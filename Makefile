BINARY_NAME = "binary_name"
# TODO: Edit these field names based on your Google cloud setup
GOOGLE_CLOUD_PROJECT_NAME = "gcloud_project_name"
GOOGLE_CLOUD_RUN_SERVICE_NAME = "gcloud_service_name"

DOCKER_TAG = "gcr.io/${GOOGLE_CLOUD_PROJECT_NAME}/${GOOGLE_CLOUD_RUN_SERVICE_NAME}:main"

# One-time usage
# Example: `go mod init NAME=calendarbot`
init:
	GO111MODULE=on go mod init ${NAME}

build:
	GO111MODULE=on go build -v -o bin/${BINARY_NAME} src/*.go

# Warning: This produces the same "bot" binary as `build` command.
build_linux:
	GOOS=linux GOARCH=amd64 go build -v src/*.go -o bin/${BINARY_NAME}

go_lint:
	GO111MODULE=on go mod tidy
	GO111MODULE=on go vet ./src
	golint -set_exit_status ./src/...

docker_lint:
	hadolint Dockerfile

lint: format go_lint docker_lint build

format:
	go fmt ./src/...

clean:
	GO111MODULE=on go clean --modcache
	rm -rf bin/*

test:
	GO111MODULE=on go test ./src/... -v

run: build
	PORT=8080 ./bin/${BINARY_NAME}

docker_build:
	docker build -f Dockerfile -t ${DOCKER_TAG} --build-arg BINARY_NAME=${BINARY_NAME} .
	echo "Created docker image with tag ${DOCKER_TAG} and size `docker image inspect ${DOCKER_TAG} --format='{{.Size}}' | numfmt --to=iec-i`"

# For local testing
docker_run: docker_build
	docker rm ${BINARY_NAME}; docker run --name ${BINARY_NAME} -p 127.0.0.1:80:80 \
		-p 127.0.0.1:443:443 \
		--env PORT=80 \
		-it ${DOCKER_TAG}

# One time
docker_gcr_login:
	gcloud auth configure-docker

docker_gcr_push: docker_build
	docker push ${DOCKER_TAG}
	echo "Pushed image can be seen at https://console.cloud.google.com/run?project=${GOOGLE_CLOUD_PROJECT_NAME}"

gcr_deploy: docker_gcr_push
	gcloud run deploy ${GOOGLE_CLOUD_RUN_SERVICE_NAME} \
		--image ${DOCKER_TAG} \
		--platform managed \
		--region us-central1 \
		--project ${GOOGLE_CLOUD_PROJECT_NAME}
	echo "Once you are satisfied with the new deployment, delete the old one at https://console.cloud.google.com/run/detail/us-central1/${GOOGLE_CLOUD_RUN_SERVICE_NAME}/revisions?project=${GOOGLE_CLOUD_PROJECT_NAME}"


