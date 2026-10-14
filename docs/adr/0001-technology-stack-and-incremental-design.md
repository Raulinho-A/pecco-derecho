# ADR 0001: Technology stack and incremental design

- Status: Accepted
- Date: 2026-09-25

## Context

PECCO Derecho will combine legal-document ingestion and analysis with a web
application. Many business rules and infrastructure details are intentionally
open and must be decided as the product is designed.

Prematurely selecting services, abstractions, or a complete architecture would
make unvalidated assumptions part of the implementation.

## Decision

- Develop the product as an AI Engineering and full-stack application.
- Use React for the frontend, Python with FastAPI for the backend, and AWS as
  the cloud platform.
- Design and implement the system incrementally, one agreed block, component,
  and method at a time.
- Review existing ADRs and `implementation-plan.md` before starting a new
  implementation area.
- Discuss broad refactors, architectural changes, and new abstractions before
  implementing them.
- Record important architectural decisions in ADRs. Keep smaller decisions in
  the implementation plan.

This decision does not select specific React tooling, AWS services, databases,
AI providers or models, ingestion mechanisms, deployment topology, or
observability tools.

## Rationale

The chosen stack establishes the project's technology boundaries while the
incremental process preserves the product owner's control over the main design
decisions. It also allows business rules and technical choices to be validated
before they become architecture constraints.

## Alternatives considered

- Define the complete architecture up front. Rejected because key business
  rules and implementation decisions are still intentionally open.
- Implement broad abstractions in anticipation of future requirements.
  Rejected until concrete use cases justify them.

## Consequences

- Progress will be organized into small, reviewable increments.
- Some technical choices and estimates will remain pending until their
  requirements are discussed.
- Documentation must be updated as part of each relevant decision.
- Cross-cutting changes may require an explicit proposal and approval before
  implementation.
