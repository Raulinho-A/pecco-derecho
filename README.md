# PECCO Derecho

Legal intelligence and monitoring platform for lawyers and law firms.

## Requirements

- Docker Engine with Docker Compose and Compose Watch support.
- GNU Make for the convenience commands.
- `uv` is optional for running Python commands directly on the host.

## Environment files

Create local environment files before using the Makefile:

```sh
cp .env.example .env
cp .env.test.example .env.test
```

The files are ignored by Git and the Docker build context. The examples contain
no secrets. Keep testing credentials isolated and leave external AI calls
disabled unless a future test explicitly requires a controlled provider.

Compose's `--env-file` supplies values used to interpolate Compose YAML. The
service-level `env_file` injects variables into the container. The Makefile uses
the same selected file for both roles, but they remain separate Compose
mechanisms. Explicit service `environment` values override `env_file` values.

## Development commands

```sh
make dev    # development stack with Compose Watch
make debug  # development plus the pgAdmin debug profile
make logs   # follow development logs
make down   # stop development without deleting its volumes
make test   # isolated Docker test run and cleanup
make help   # list commands
```

Development uses the Compose project `pecco-derecho-dev`. `make down` does not
pass `--volumes`, so PostgreSQL, Qdrant, RabbitMQ, and pgAdmin development data
is preserved.

## Test isolation

Each `make test` invocation generates a unique test project name unless
`COMPOSE_TEST_PROJECT_NAME` is supplied. Unit tests run first without service
dependencies. PostgreSQL, Qdrant, and RabbitMQ then start for the integration
and E2E phase. Test services publish no host ports, use project-scoped volumes,
and are removed with those volumes and locally built test images even when
tests fail.

CI should provide a job-specific name and can use the same command:

```sh
cp .env.test.example .env.test
COMPOSE_TEST_PROJECT_NAME="pecco-test-${CI_JOB_ID}" make test
```

The current integration and E2E tests are discovery placeholders only. They do
not validate real services or user journeys. The eval dataset is fictional and
does not run models.

## Production image status

The `production` Docker target installs from `uv.lock`, excludes development
dependencies, runs as a non-root user, starts Uvicorn without reload, and has a
healthcheck against the existing root route. No env files or local AWS/tool
configuration are copied into the build context.

Validated locally where tooling permits: Compose rendering, locked dependency
installation, image builds, placeholder test discovery, test exit-code
propagation, and test-project cleanup. A production deployment is intentionally
not defined yet; its AWS destination, runtime secrets, networking, persistence,
migrations, scaling, and observability remain pending decisions.

## Project documentation

- [Implementation plan](implementation-plan.md)
- [Architecture decision records](docs/adr/)
