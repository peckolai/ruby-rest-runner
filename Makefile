.PHONY: help build run exec test clean docker-build docker-run docker-exec docker-compose-up docker-compose-down

# Default target
help:
	@echo "Ruby Rest Runner - Makefile Commands"
	@echo "===================================="
	@echo ""
	@echo "Docker Commands:"
	@echo "  make docker-build        Build Docker image"
	@echo "  make docker-run          Run rest-runner in Docker (shows help)"
	@echo "  make docker-exec ARGS=   Execute collection in Docker (e.g., ARGS='exec collections/demo.yml')"
	@echo "  make docker-compose-up   Start Docker Compose services"
	@echo "  make docker-compose-down Stop Docker Compose services"
	@echo ""
	@echo "Local Commands:"
	@echo "  make build               Bundle install"
	@echo "  make test                Run RSpec tests"
	@echo "  make run                 Show CLI help"
	@echo ""

# Local development targets
build:
	bundle install

test:
	bundle exec rspec spec/ --format progress

run:
	bundle exec ./bin/rest-run --help

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
