SHELL := /bin/sh

DEV_PROJECT_NAME ?= pecco-derecho-dev
DEV_ENV_FILE ?= .env
TEST_ENV_FILE ?= .env.test
TEST_PROJECT_NAME := $(or $(COMPOSE_TEST_PROJECT_NAME),pecco-derecho-test-$(shell date +%s%N))

DEV_COMPOSE = APP_ENV_FILE=$(DEV_ENV_FILE) docker compose --project-name $(DEV_PROJECT_NAME) --env-file $(DEV_ENV_FILE) --file compose.yml
TEST_COMPOSE = TEST_APP_ENV_FILE=$(TEST_ENV_FILE) docker compose --project-name $(TEST_PROJECT_NAME) --env-file $(TEST_ENV_FILE) --file compose.test.yml

.PHONY: dev down debug test logs help

dev: ## Start the development stack with Compose Watch.
	$(DEV_COMPOSE) watch

down: ## Stop development containers without deleting volumes.
	$(DEV_COMPOSE) down --remove-orphans

debug: ## Start development with debug-profile services such as pgAdmin.
	$(DEV_COMPOSE) --profile debug watch

test: ## Build and run isolated unit, integration, and E2E placeholder tests.
	@status=0; \
	cleanup() { $(TEST_COMPOSE) down --volumes --remove-orphans --rmi local >/dev/null 2>&1 || true; }; \
	trap cleanup EXIT INT TERM; \
	$(TEST_COMPOSE) build unit-tests integration-tests || status=$$?; \
	if [ "$$status" -eq 0 ]; then \
		$(TEST_COMPOSE) run --rm --no-deps unit-tests || status=$$?; \
	fi; \
	if [ "$$status" -eq 0 ]; then \
		$(TEST_COMPOSE) up --detach --wait postgres qdrant rabbitmq || status=$$?; \
	fi; \
	if [ "$$status" -eq 0 ]; then \
		$(TEST_COMPOSE) run --rm --no-deps integration-tests || status=$$?; \
	fi; \
	exit "$$status"

logs: ## Follow development logs.
	$(DEV_COMPOSE) logs --follow

help: ## Show available commands.
	@awk 'BEGIN {FS = ":.*## "; print "PECCO Derecho commands:"} /^[a-zA-Z_-]+:.*## / {printf "  %-10s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
