# PECCO Derecho implementation plan

This document is the project's living implementation guide and checklist. It
records current progress and small implementation decisions. Architectural
decisions belong in `docs/adr/`.

## Working agreement

- [x] Use React for the frontend.
- [x] Use Python and FastAPI for the backend.
- [x] Use AWS as the cloud platform.
- [x] Work incrementally, block by block and component by component.
- [x] Review this plan and the ADRs before modifying a new area.
- [x] Discuss broad refactors, architectural changes, and new abstractions
  before implementation.
- [x] Preserve official legal sources as the source of truth.
- [x] Use AI only to assist analysis, summarization, classification,
  translation, and comparison; never as a replacement for source material.

## Current state

- [x] Initialize the Python project scaffold.
- [x] Add FastAPI as a backend dependency.
- [x] Record the technology stack and incremental design approach in ADR 0001.
- [x] Select PostgreSQL, Qdrant, and RabbitMQ for their stated infrastructure
  roles.
- [x] Add isolated Docker Compose workflows for development and testing.
- [x] Add typed environment configuration with `pydantic-settings`.
- [x] Add clearly labeled placeholder tests and a fictional eval dataset.
- [x] Record containerized development and test isolation in ADR 0002.
- [ ] Define the first implementation block with the product owner.

## Pending decisions

These items are intentionally undecided and must not be inferred from the
selected technology stack:

- [ ] Define the first user-facing workflow and its acceptance criteria.
- [ ] Select React application tooling and frontend structure when frontend
  implementation begins.
- [ ] Define backend boundaries and API contracts as each use case is designed.
- [ ] Select Python clients and define schemas, indexes, and migration behavior
  when persistence use cases are designed.
- [ ] Select ingestion mechanisms source by source.
- [ ] Select AI providers, models, evaluation criteria, and guardrails.
- [ ] Select specific AWS services and production deployment topology.
- [ ] Replace placeholder tests and eval data with requirements-driven cases.
- [ ] Define broader observability, security, and delivery requirements.

## Next step

Choose and design the first implementation block. Update this plan and create
an ADR only if that block introduces a significant architectural decision.
