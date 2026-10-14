# ADR 0002: Containerized development and test isolation

- Status: Accepted
- Date: 2026-10-10

## Context

Development and testing need reproducible commands without allowing test data,
containers, networks, or credentials to overlap with development. Unit tests
must also remain fast and independent from infrastructure they do not use.

## Decision

- Use Docker Compose Watch for the FastAPI development workflow.
- Use PostgreSQL for relational persistence, Qdrant for vector search, and
  RabbitMQ for future workflows and workers.
- Keep development and testing in separate Compose files and project names.
- Run unit tests in a test image without infrastructure dependencies.
- Start isolated real PostgreSQL, Qdrant, and RabbitMQ services before the
  integration and E2E test phase.
- Publish no test service ports and remove only the test project's containers,
  networks, volumes, and locally built test images after each run.
- Load typed application settings with `pydantic-settings` from the process
  environment. Compose remains responsible for injecting env-file values.

This decision does not define schemas, migrations, service clients, workers,
real integration tests, production infrastructure, or deployment topology.

## Rationale

Separate project names and project-scoped volumes prevent accidental sharing.
Splitting unit and integration phases avoids making unit tests depend on
databases or brokers. Typed settings fail early on invalid configuration while
keeping Compose interpolation separate from container environment injection.

## Alternatives considered

- Use one Compose project for development and testing. Rejected because names,
  networks, and volumes could collide.
- Start every service for unit tests. Rejected because those tests should not
  require unrelated infrastructure.
- Read local env files directly in application code. Rejected in favor of
  process environment injection, which behaves consistently in containers.

## Consequences

- Docker-based test runs have an infrastructure startup cost for integration
  and E2E phases.
- CI may set `COMPOSE_TEST_PROJECT_NAME` to a unique job-specific value.
- Local secret env files must be created from versioned examples.
- Production deployment details remain a separate future decision.
