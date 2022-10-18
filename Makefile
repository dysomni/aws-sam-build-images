# Default value for environment variable. Can be overridden by setting the
# environment variable.

registry_id=$(shell aws ecr describe-registry | jq '.registryId' -r)

init:
	pip install -Ur requirements.txt

build:
	cd build-image-src && ./build_all_images.sh

build_ruby27_x86:
	cd build-image-src ;\
	docker build \
		-t "${registry_id}.dkr.ecr.us-east-1.amazonaws.com/aws-sam-cli-build-image-ruby2.7:x86_64" \
		-f Dockerfile-ruby27 \
		--platform linux/amd64 \
		--build-arg AWS_CLI_ARCH=x86_64 \
		--build-arg IMAGE_ARCH=x86_64 \
		--build-arg SAM_CLI_VERSION=1.36.0 \
		.
	docker push "${registry_id}.dkr.ecr.us-east-1.amazonaws.com/aws-sam-cli-build-image-ruby2.7:x86_64"

build_ruby27_arm64:
	cd build-image-src ;\
	docker build \
		-t "${registry_id}.dkr.ecr.us-east-1.amazonaws.com/aws-sam-cli-build-image-ruby2.7:arm64" \
		-f Dockerfile-ruby27 \
		--platform linux/arm64 \
		--build-arg IMAGE_ARCH=arm64 \
		--build-arg AWS_CLI_ARCH=aarch64 \
		--build-arg SAM_CLI_VERSION=1.36.0 \
		.
	docker push "${registry_id}.dkr.ecr.us-east-1.amazonaws.com/aws-sam-cli-build-image-ruby2.7:arm64"

build_ruby27: build_ruby27_arm64 build_ruby27_x86

build_python39_x86:
	cd build-image-src ;\
	docker build \
		-t "${registry_id}.dkr.ecr.us-east-1.amazonaws.com/aws-sam-cli-build-image-python3.9:x86_64" \
		-f Dockerfile-python39 \
		--platform linux/amd64 \
		--build-arg AWS_CLI_ARCH=x86_64 \
		--build-arg IMAGE_ARCH=x86_64 \
		--build-arg SAM_CLI_VERSION=1.36.0 \
		.
	docker push "${registry_id}.dkr.ecr.us-east-1.amazonaws.com/aws-sam-cli-build-image-python3.9:x86_64"

build_python39_arm64:
	cd build-image-src ;\
	docker build \
		-t "${registry_id}.dkr.ecr.us-east-1.amazonaws.com/aws-sam-cli-build-image-python3.9:arm64" \
		-f Dockerfile-python39 \
		--platform linux/arm64 \
		--build-arg IMAGE_ARCH=arm64 \
		--build-arg AWS_CLI_ARCH=aarch64 \
		--build-arg SAM_CLI_VERSION=1.36.0 \
		.
	docker push "${registry_id}.dkr.ecr.us-east-1.amazonaws.com/aws-sam-cli-build-image-python3.9:arm64"

build_python39: build_python39_arm64 build_python39_x86

test:
	pytest tests

lint:
	# Linter performs static analysis to catch latent bugs
	pylint --rcfile .pylintrc tests
	# mypy performs type check
	mypy tests/*.py

dev: lint test

black:
	black tests

black-check:
	black --check tests

# Verifications to run before sending a pull request
pr: init build black-check dev
