.PHONY: help build run test clean docker-build docker-run docker-exec docker-compose-up docker-compose-down ocra-build traveling-ruby-build

# Default target
help:
	@echo "Ruby Rest Runner - Makefile Commands"
	@echo "======================================"
	@echo ""
	@echo "Local Development:"
	@echo "  make build               Bundle install"
	@echo "  make test                Run RSpec tests"
	@echo "  make run                 Show CLI help"
	@echo "  make clean               Clean build artifacts"
	@echo ""
	@echo "Docker Commands:"
	@echo "  make docker-build        Build Docker image"
	@echo "  make docker-run          Run rest-runner in Docker (shows help)"
	@echo "  make docker-exec ARGS=   Execute collection in Docker"
	@echo "  make docker-compose-up   Start Docker Compose services"
	@echo "  make docker-compose-down Stop Docker Compose services"
	@echo "  make docker-demo         Run demo collection in Docker"
	@echo ""
	@echo "Distribution (Windows/Multi-Platform):"
	@echo "  make ocra-build          Build standalone Windows .exe"
	@echo "  make traveling-ruby-build Build cross-platform packages"
	@echo ""
	@echo "See INSTALL_METHODS.md for detailed installation guide"
	@echo ""

# Local development targets
build:
	bundle install

test:
	bundle exec rspec spec/ --format progress

run:
	bundle exec ./bin/rest-run --help

clean:
	rm -rf dist/ tmp/ coverage/ .rspec_status doc/
	@echo "✓ Cleaned build artifacts"

# Docker targets
docker-build:
	docker build -t ruby-rest-runner:latest .

docker-run:
	docker run --rm ruby-rest-runner:latest

docker-exec:
	docker run --rm \
		-v $$(pwd)/collections:/app/collections:ro \
		-v $$(pwd)/config/envs:/app/config/envs:ro \
		-v $$(pwd)/results:/app/results \
		ruby-rest-runner:latest \
		$(ARGS)

docker-compose-up:
	docker-compose up --build

docker-compose-down:
	docker-compose down

# Convenience targets
docker-demo:
	@echo "Running JSONPlaceholder demo collection..."
	@docker run --rm \
		-v $$(pwd)/collections:/app/collections:ro \
		ruby-rest-runner:latest \
		exec collections/jsonplaceholder_demo.yml

docker-list:
	@docker run --rm \
		-v $$(pwd)/collections:/app/collections:ro \
		ruby-rest-runner:latest \
		list

# Distribution Targets

ocra-build:
	@echo "Building Windows executable with OCRA..."
	@ruby build_ocra_exe.rb

ocra-test: ocra-build
	@echo "Testing OCRA executable..."
	@./dist/rest-run.exe --help

traveling-ruby-build:
	@echo "Building cross-platform packages with TravlingRuby..."
	@bash build_traveling_ruby.sh

traveling-ruby-test: traveling-ruby-build
	@echo "Testing TravlingRuby packages..."
	@cd dist && tar xzf ruby-rest-runner-1.0.0-linux-x86_64.tar.gz && \
	  ./ruby-rest-runner-1.0.0/rest-run --help && \
	  cd .. && rm -rf dist/ruby-rest-runner-1.0.0
