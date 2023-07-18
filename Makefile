BINARY_NAME = "binary_name"
# TODO: Edit these field names based on your Google cloud setup
GOOGLE_CLOUD_PROJECT_ID = "gcloud_project_id"
GOOGLE_CLOUD_RUN_SERVICE_NAME = "gcloud_service_name"
REGION="us-east4"

# We base64 encode it to remove encode all special characters including whitespace
SECRET_VALUE=`cat secret.txt | base64`

DOCKER_TAG = "gcr.io/${GOOGLE_CLOUD_PROJECT_ID}/${GOOGLE_CLOUD_RUN_SERVICE_NAME}:main"

# One-time usage
# Example: `make init NAME=calendarbot`
init:
	GO111MODULE=on go mod init ${NAME}
	# A random secret value like a credential
	echo "random value" > secret.txt

build_debug:
	GO111MODULE=on go build -v -o bin/${BINARY_NAME} src/*.go

build_prod:
	# Shrink binary by removing symbol and DWARF table
	# Ref: https://lukeeckley.com/post/useful-go-build-flags/
	GO111MODULE=on go build -v -ldflags="-s -w" -o bin/${BINARY_NAME} src/*.go

# Warning: This produces the same "bot" binary as `build` command.
build_linux:
	GOOS=linux GOARCH=amd64 go build -o bin/${BINARY_NAME} -v src/*.go

go_lint:
	GO111MODULE=on go mod tidy
	GO111MODULE=on go vet ./src
	golint -set_exit_status ./src/...
	go tool fix src/
	golangci-lint run

docker_lint:
	hadolint --ignore DL3018 Dockerfile

html_lint:
	find website -iname '*htm*' -exec htmlhint  --config .htmlhintrc {} \;
	
update_go_deps:
	GO111MODULE=on go get -t -u ./...

lint: format go_lint docker_lint html_lint build

format:
	go fmt ./src/...

clean:
	GO111MODULE=on go clean --modcache
	rm -rf bin/*

test:
	GO111MODULE=on go test ./src/... -v

run: build_debug
	PORT=8080 SECRET_VALUE=${SECRET_VALUE} ./bin/${BINARY_NAME}

run_debug:  # watch for modifications and restart the binary if any golang file changes
	filewatcher --immediate --restart "**/*.go" "killall ${BINARY_NAME}; make run"

docker_build:
	DOCKER_BUILDKIT=1 docker build -f Dockerfile -t ${DOCKER_TAG} --build-arg BINARY_NAME=${BINARY_NAME} .
	echo "Created docker image with tag ${DOCKER_TAG} and size `docker image inspect ${DOCKER_TAG} --format='{{.Size}}' | numfmt --to=iec-i`"

# For local testing
docker_run: docker_build
	docker rm ${BINARY_NAME}; docker run --name ${BINARY_NAME} -p 127.0.0.1:80:80 \
		-p 127.0.0.1:443:443 \
		--env PORT=80 \
		--env SECRET_VALUE=${SECRET_VALUE} \
		-it ${DOCKER_TAG}

# One time
docker_gcr_login:
	gcloud auth configure-docker

# One time: enable container registry by visiting
# https://console.cloud.google.com/marketplace/product/google/containerregistry.googleapis.com?project=${GOOGLE_CLOUD_PROJECT_ID}
# or
# Enable Google Artifact Registry via
# gcloud --project ${GOOGLE_CLOUD_PROJECT_ID} services enable containerregistry.googleapis.com
docker_gcr_push: docker_build
	docker push ${DOCKER_TAG}
	echo "Pushed image can be seen at https://console.cloud.google.com/run?project=${GOOGLE_CLOUD_PROJECT_ID}"

# Enable Google Cloud Run via
# gcloud --project ${GOOGLE_CLOUD_PROJECT_ID} services enable run.googleapis.com
gcloud_deploy: docker_gcr_push
	git tag "gcloud_deploy_$(shell date | tr ' ' '_' | tr ':' '-')"
	gcloud run deploy ${GOOGLE_CLOUD_RUN_SERVICE_NAME} \
		--image ${DOCKER_TAG} \
		--platform managed \
		--region ${REGION} \
		--set-env-vars=SECRET_VALUE=${SECRET_VALUE} \
		--project ${GOOGLE_CLOUD_PROJECT_ID}
	echo "Once you are satisfied with the new deployment, delete the old one at https://console.cloud.google.com/run/detail/${REGION}/${GOOGLE_CLOUD_RUN_SERVICE_NAME}/revisions?project=${GOOGLE_CLOUD_PROJECT_ID}"


