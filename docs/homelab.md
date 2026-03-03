 Homelab Platform Roadmap (Solo Engineer)

## Executive summary

You should build this platform in **small, production-like slices**: establish a secure GitOps foundation first, then ship a thin vertical slice of your app (frontend + backend + DB + auth), then add observability, and finally evolve into self-service workflows. The primary strategy is:

1. **Stabilize the platform control plane** (cluster, ingress, certs, Argo CD, baseline RBAC).
2. **Deliver one end-to-end workload** (React + FastAPI + Postgres + JWT) through GitOps.
3. **Add guardrails and visibility** (secrets management, policy, monitoring, logs, dashboards).
4. **Automate promotion and developer experience** only after baseline reliability is proven.

For a solo homelab, the key anti-pattern to avoid is building internal platform abstractions before you have repeated pain. Start manual-but-documented, then automate the repeated steps.

---

## Recommended implementation order (opinionated)

1. Phase 0: Foundation hardening and repo strategy
2. Phase 1: Minimum secure GitOps + app vertical slice
3. Phase 2: CI/CD image flow and promotion mechanics
4. Phase 3: Security depth and policy enforcement
5. Phase 4: Observability and operational maturity
6. Phase 5: Self-service and multi-environment expansion

---


## Current-state alignment (based on this repo)

Below is the practical alignment between this roadmap and what appears to already exist in the repository today.

### Already done / materially in place
- **Cluster and networking foundation:** k3s HA install automation, MetalLB, Traefik exposure, and gateway forwarding/WireGuard automation are present.
- **Core platform bootstrap automation:** Argo CD and cert-manager install playbooks/roles exist.
- **Security baseline partially implemented:** Argo CD `admin.enabled=false`, local RBAC defaults, and Argo CD network policy templating are already configured.
- **Infra-as-code for gateway layer:** Terraform for gateway networking/server provisioning exists.

### Partially done (needs completion/validation)
- **Argo CD RBAC hardening:** base policy exists, but project-level boundaries and end-to-end claim mapping still need validation.
- **Network-policy posture:** Argo CD policy exists; app namespace default-deny and explicit allow-lists are not yet represented as a complete standard.
- **Ingress security model:** controls exist in templates/vars, but OAuth/Cloudflare Zero Trust decision and rollout are pending.

### Not yet present (major gaps)
- Application code and manifests for the target platform app (React/FastAPI/Postgres/JWT).
- CI pipelines for build/test/publish + image promotion automation.
- GitOps workloads structure for multi-environment promotion.
- Secrets-as-code workflow (SOPS/Sealed Secrets) and rotation automation.
- Observability stack and runbooks (Prometheus/Grafana/Loki dashboards/alerts).

### Ticket status normalization
Use these tags in tracking:
- **DONE**: implemented in repo and minimally validated.
- **IN PROGRESS**: artifacts exist but missing policy checks/tests/runbook validation.
- **TODO**: no meaningful implementation yet.

Recommended immediate relabeling:
- **DONE:** T1.1.2 (admin disable + baseline RBAC), portions of T0.3.1 (platform namespace policy), and platform install foundations supporting Phase 0.
- **IN PROGRESS:** T3.1.1, T0.3.1 (app namespaces), T1.3.2.
- **TODO:** all of E2.x, most of E3.2/E3.3, all E4.x and E5.x.

---

## Re-baselined next steps (aligned to what is already done)

1. **Finish Phase 0 closure:** explicitly validate/standardize namespace policies and service-account least privilege.
2. **Accelerate to app vertical slice (E1.2/E1.3):** this is now the highest-value gap.
3. **Immediately follow with CI + image promotion (E2):** avoid manual deployment drift once app exists.
4. **Then complete identity/secrets decisions (E3.2/E3.3):** before opening access broadly.
5. **Add observability (E4) once app traffic exists:** dashboards before portal/self-service.

## Phased roadmap

### Phase 0 (Week 1-2): Platform baseline and delivery model
**Goal:** lock in architecture boundaries and bootstrap conventions before feature work.

#### Epics
- E0.1 Platform architecture and ADR baseline
- E0.2 GitOps repository topology and standards
- E0.3 Cluster baseline hardening

---

### Phase 1 (Week 3-5): First production-like app via GitOps
**Goal:** deploy a complete, secured, observable-enough MVP workload.

#### Epics
- E1.1 App-of-Apps bootstrap in Argo CD
- E1.2 Homelab app MVP (React + FastAPI + Postgres)
- E1.3 Authentication and app access controls
- E1.4 Portal Frontend v1 (React/Vite/Tailwind/shadcn) – start building the user-facing SPA and auth glue
- E1.6 Portal Product Features (Render‑like UX, read‑only first) – implement service catalog, status/dashboard pages, and links; no write actions yet

---

### Phase 2 (Week 6-7): CI and image promotion
**Goal:** deterministic build/deploy workflow with low manual toil.

#### Epics
- E2.1 CI pipeline with immutable artifacts
- E2.2 Automated image tag promotion for GitOps
- E2.3 Registry and provenance basics

---

### Phase 3 (Week 8-10): Security hardening and secrets lifecycle
**Goal:** remove obvious security debt and establish policy guardrails.

#### Epics
- E3.1 Argo CD and Kubernetes RBAC enforcement
- E3.2 External auth integration (OAuth or Cloudflare Zero Trust)
- E3.3 Secrets encryption and rotation workflow

---

### Phase 4 (Week 11-13): Observability stack and SLO-lite operations
**Goal:** detect failures quickly and understand deployment health.

#### Epics
- E4.1 Metrics and dashboards (Prometheus + Grafana)
- E4.2 Centralized logging (Loki preferred for homelab simplicity)
- E4.3 Deployment, health, and change visibility

---

### Phase 5 (Week 14+): Platform products and multi-env scale-out
**Goal:** add developer-experience features without breaking simplicity.

#### Epics
- E5.1 Multi-environment GitOps structure (dev/staging/prod)
- E5.2 Self-service project bootstrap
- E5.3 Internal developer portal seed

---

## Epics and detailed tickets

> **Ticket format:** Title, Description, Acceptance Criteria, Dependencies, Complexity, Risk.

### E0.1 Platform architecture and ADR baseline

#### T0.1.1 Create ADR repository structure and template
- **Description:** Add `/docs/adr` with a lightweight ADR template capturing context, decision, alternatives, consequences.
- **Status:** DONE (2026-02-27)
- **Acceptance Criteria:**
  - ADR template exists and is referenced in README.
  - At least 3 ADRs drafted from current decisions.
- **Dependencies:** None
- **Complexity:** S
- **Risk:** Low
- **Evidence:**
  - ADR structure and template committed under `docs/adr/`.
  - ADR index references created ADRs in `docs/adr/README.md`.

#### T0.1.2 Write initial ADR set (cluster distro, GitOps model, secrets strategy placeholder)
- **Description:** Capture current and pending architectural choices to prevent drift.
- **Status:** DONE (2026-02-27)
- **Acceptance Criteria:**
  - ADR-001: K3s + homelab constraints.
  - ADR-002: Argo CD App-of-Apps structure.
  - ADR-003: Secrets approach candidates (SOPS vs Sealed Secrets) with decision date.
- **Dependencies:** T0.1.1
- **Complexity:** S
- **Risk:** Low
- **Evidence:**
  - `0001-k3s-ha-cluster-topology.md`, `0002-argocd-gitops-model.md`, and `0003-secrets-management-strategy-placeholder.md` committed.

### E0.2 GitOps repository topology and standards

#### T0.2.1 Create dedicated workloads repo skeleton
- **Description:** Build a separate repo for app manifests with `bootstrap/`, `platform/`, `apps/`, and environment folders.
- **Status:** DONE (2026-02-28)
- **Acceptance Criteria:**
  - Repo contains documented folder conventions.
  - Argo CD can target repo/paths without ambiguity.
- **Dependencies:** T0.1.2
- **Complexity:** M
- **Risk:** Medium
- **Evidence:**
  - Dedicated `workloads` created with `bootstrap/`, `platform/`, `apps/`, and `environments/`.
  - Argo CD applications target repository paths for dev/prod child apps.

#### T0.2.2 Define manifest layering strategy
- **Description:** Decide Kustomize overlays (recommended) or Helm value layering for dev/prod.
- **Status:** DONE (2026-02-28)
- **Acceptance Criteria:**
  - One example app demonstrates base + overlay.
  - Promotion path between envs documented.
- **Dependencies:** T0.2.1
- **Complexity:** M
- **Risk:** Medium
- **Evidence:**
  - Base + overlay pattern implemented for `homelab-api` and `homelab-web`.
  - Promotion path documented in `workloads/README.md`.

### E0.3 Cluster baseline hardening

#### T0.3.1 Enforce namespace and network policy baseline
- **Description:** Add default-deny ingress/egress where feasible and explicit allow rules for platform components.
- **Status:** DONE (2026-03-01)
- **Acceptance Criteria:**
  - Default-deny policy applied to app namespaces.
  - App and Argo CD still function after policy rollout.
- **Dependencies:** T0.2.1
- **Complexity:** M
- **Risk:** Medium
- **Evidence:**
  - Default-deny + explicit allow NetworkPolicies present for `homelab-api` and `homelab-web`.
  - Workloads remained functional after policy rollout and validations.

#### T0.3.2 Define service account model for Kubernetes API access
- **Description:** Create minimal RBAC roles for backend API interactions with cluster.
- **Status:** DONE (2026-03-01)
- **Acceptance Criteria:**
  - Dedicated ServiceAccount exists for backend.
  - Role/RoleBinding grant least-privilege verbs/resources.
- **Dependencies:** T0.3.1
- **Complexity:** M
- **Risk:** Medium
- **Evidence:**
  - `homelab-api-backend` ServiceAccount, Role, and RoleBinding committed in `apps/homelab-api/base/`.
  - Permissions scoped to read-only Kubernetes resources used by backend workflows.

---

### E1.1 App-of-Apps bootstrap in Argo CD

#### T1.1.1 Create root app and child app definitions
- **Description:** Implement App-of-Apps with separate child apps for platform and workloads.
- **Status:** DONE (2026-02-28)
- **Acceptance Criteria:**
  - Root app syncs all child apps successfully.
  - Failed child app does not block inspection/recovery.
- **Dependencies:** T0.2.1
- **Complexity:** M
- **Risk:** Medium
- **Evidence:**
  - Root applications and child application manifests committed under `workloads/bootstrap/` and `workloads/environments/`.
  - Environment-specific child apps for `homelab-api` and `homelab-web` reconciled via Argo CD.

#### T1.1.2 Disable Argo CD admin and enforce local RBAC roles
- **Description:** Remove default admin usage and define operator/read-only roles.
- **Status:** DONE (2026-03-01)
- **Acceptance Criteria:**
  - `admin` login disabled.
  - At least two non-admin role mappings validated.
- **Dependencies:** T1.1.1
- **Complexity:** M
- **Risk:** High
- **Evidence:**
  - Argo CD hardening automation/configuration applied in cluster bootstrap workflow.
  - Repository status normalization and operational validations recorded this control as complete.

### E1.2 Homelab app MVP (React + FastAPI + Postgres)

#### T1.2.1 Scaffold backend API with health, auth, and metadata endpoints
- **Description:** Build FastAPI skeleton with `/health`, `/auth/login`, `/projects` endpoints.
- **Status:** DONE (2026-03-02)
- **Acceptance Criteria:**
  - Endpoint tests pass locally.
  - OpenAPI schema generated and committed.
- **Dependencies:** None
- **Complexity:** M
- **Risk:** Medium
- **Evidence:**
  - Backend endpoint test suite implemented and passing in CI (`apps/portal/.github/workflows/backend-ci.yml`).
  - OpenAPI schema generated and committed at `apps/portal/backend/openapi.json`.

#### T1.2.2 Deploy PostgreSQL with persistent volume and migration workflow
- **Description:** Provision Postgres via Helm/manifests and add schema migrations (Alembic recommended).
- **Status:** DONE (2026-03-02)
- **Acceptance Criteria:**
  - DB survives pod restart.
  - Migration can run idempotently in CI and cluster.
- **Dependencies:** T1.2.1
- **Complexity:** M
- **Risk:** Medium
- **Evidence:**
  - In-cluster persistence check passed: inserted marker row into `projects`, restarted `homelab-api-postgres-0`, row remained present.
  - Argo CD rollout of hardened migration hook succeeded: `homelab-api-dev` reached `Synced | Healthy` with operation state `Succeeded`.
  - CI migration idempotency check implemented and passing in `apps/portal/.github/workflows/backend-ci.yml` (`python -m alembic upgrade head` executed twice).

#### T1.2.3 Containerize and deploy frontend + backend through GitOps
- **Description:** Build/deploy both services with environment config and ingress routing.
- **Status:** DONE (2026-03-02)
- **Acceptance Criteria:**
  - Frontend can authenticate against backend.
  - Backend can read/write Postgres metadata.
- **Dependencies:** T1.2.1, T1.2.2, T1.1.1
- **Complexity:** L
- **Risk:** High
- **Evidence:**
  - Argo CD deployed `homelab-api-dev` and `homelab-web-dev` at revision `8e7f359...` with `Synced | Healthy`.
  - Runtime images verified:
    - `ghcr.io/wlodzimierrr/homelab-api:0.3.1`
    - `ghcr.io/wlodzimierrr/homelab-web:0.1.0`
  - Ingress endpoints validated:
    - `api.dev.homelab.local/health` returned HTTP 200.
    - `portal.dev.homelab.local` served frontend over Traefik.
  - Backend metadata persistence validated via API:
    - `POST /projects` returned HTTP 201.
    - `GET /projects` returned HTTP 200 with persisted records.

### E1.3 Authentication and app access controls

#### T1.3.1 Implement JWT issuance and validation path
- **Description:** Add token generation, expiration, refresh strategy, and protected routes.
- **Status:** DONE (2026-03-02)
- **Acceptance Criteria:**
  - Unauthorized access to protected endpoints returns 401.
  - Refresh/token expiry behavior documented and tested.
- **Dependencies:** T1.2.1
- **Complexity:** M
- **Risk:** Medium
- **Evidence:**
  - JWT auth flow implemented in backend with access + refresh token issuance, validation, and token-type checks.
  - Protected routes enforce bearer access tokens and return HTTP 401 for missing/invalid/expired tokens.
  - Refresh strategy documented in `apps/portal/backend/README.md` with TTL settings and stateless rotation behavior.
  - Backend test suite validates unauthorized access, refresh handling, and expiry behavior (`9 passed` in `apps/portal/backend/tests/test_api.py`).

#### T1.3.2 Add ingress auth gate (initially basic, evolving to OAuth/ZT)
- **Description:** Protect app entry point with interim controls before SSO integration.
- **Status:** DONE (2026-03-02)
- **Acceptance Criteria:**
  - Unauthenticated ingress requests blocked.
  - Emergency break-glass path documented.
- **Dependencies:** T1.2.3
- **Complexity:** S
- **Risk:** Medium
- **Evidence:**
  - Traefik basic-auth middleware added for portal ingress in `workloads/apps/homelab-web/base/middleware-basic-auth.yaml`.
  - Portal ingress split into UI (`/`) with basic-auth middleware and API (`/api`) without middleware to avoid `Authorization` header conflicts between ingress basic-auth and backend bearer JWT.
  - Secret bootstrap and break-glass disable/restore procedure documented in `workloads/README.md`.
  - Runtime validation completed after sync: portal access required basic-auth, backend login succeeded, and project refresh returned `Loaded 2 project(s)` with expected records (`proj-browser`, `proj-web`).

### E1.4 Portal Frontend v1

#### T1.4.1 Frontend scaffold: React + Vite + TypeScript + Tailwind + shadcn
- **Description:** Create the frontend skeleton for the Portal using Vite (React + TS), TailwindCSS, and shadcn/ui component primitives. Include linting, formatting, and a minimal layout (sidebar/topbar) plus theme toggle persistence.
- **Status:** DONE (2026-03-03)
- **Acceptance Criteria:**
  - `apps/portal/frontend` contains a Vite React TS app with `package.json`, `tsconfig.json`, `tailwind.config.cjs`, and `postcss.config.cjs`.
  - Basic layout routes exist: `/login`, `/dashboard`, `/projects`, `/services`, `/services/:serviceId`, `/services/:serviceId/deployments`, `/settings`.
  - Sidebar + topbar implemented, theme toggle persists in `localStorage`.
  - ESLint + Prettier (or equivalent) configured and `npm run lint` passes on created files.
- **Dependencies:** None (can scaffold independently)
- **Complexity:** M
- **Risk:** Low
- **Evidence:**
  - Vite + React + TypeScript frontend promoted to `apps/portal/frontend` with Tailwind/shadcn wiring and lint/format config (`package.json`, `tsconfig.json`, `tailwind.config.cjs`, `postcss.config.cjs`, `.prettierrc.json`).
  - Route scaffold implemented for `/login`, `/dashboard`, `/projects`, `/services`, `/services/:serviceId`, `/services/:serviceId/deployments`, `/settings` with shared sidebar/topbar layout in `src/components/layout/` and `src/components/navigation/`.
  - Theme toggle persists selection in `localStorage` (`portal-theme`) and applies dark class at app root.
  - Local verification completed by developer run: `npm install`, `npm run lint` (pass), `npm run dev` (pass after Tailwind v4 postcss plugin update).

#### T1.4.2 Auth integration (frontend)
- **Description:** Implement login UI calling `POST /api/auth/login`, store JWT in `localStorage`, attach `Authorization: Bearer <token>` to API calls, and handle 401 by clearing token and redirecting to `/login` with a toast.
- **Status:** DONE (2026-03-03)
- **Acceptance Criteria:**
  - Login screen submits credentials to `POST /api/auth/login` and stores returned token.
  - All API requests include bearer token when present.
  - On 401 responses the app clears token, redirects to `/login`, and shows a toast.
  - Tradeoffs documented in `apps/portal/frontend/README.md` (localStorage vs secure cookie).
- **Dependencies:** T1.4.1, backend `POST /api/auth/login`
- **Complexity:** S
- **Risk:** Medium
- **Evidence:**
  - Login form wired to backend auth endpoint and token persistence implemented in `apps/portal/frontend/src/pages/login-page.tsx` + `src/lib/auth.ts`.
  - Centralized request path adds `Authorization: Bearer <token>` for authenticated calls (`src/lib/api.ts`).
  - Global 401 handler clears token, redirects to `/login`, and shows toast notification (`src/App.tsx` + `src/components/ui/toast.tsx`).
  - LocalStorage vs secure cookie tradeoff documented under `apps/portal/frontend/README.md` (`Auth Storage Tradeoff` section).

#### T1.4.3 Projects UI (list + create)
- **Description:** Implement project list and create flow (Dialog/Sheet) using the existing `GET /api/projects` and `POST /api/projects` endpoints. Provide loading skeletons, empty states and toasts.
- **Status:** DONE (2026-03-03)
- **Acceptance Criteria:**
  - `/projects` lists projects using `GET /api/projects` with loading and empty states.
  - Create project dialog submits `POST /api/projects` and shows success/error toast.
  - API errors surfaced via consistent error component.
- **Dependencies:** T1.4.1, backend `/api/projects`
- **Complexity:** S
- **Risk:** Low
- **Evidence:**
  - `/projects` page fetches from `GET /api/projects` and renders loading skeletons + empty state (`apps/portal/frontend/src/pages/projects-page.tsx`).
  - Create project modal flow implemented with `POST /api/projects` and success/error toasts.
  - Reusable `ApiError` component introduced and used consistently for list/create API failures (`apps/portal/frontend/src/components/api-error.tsx`).
  - Dev proxy/path and environment alignment validated against hosted backend (`api.dev.homelab.local`) after local CORS/proxy fixes.

#### T1.4.4 API client layer and small state helpers
- **Description:** Add `src/lib/api.ts`, `src/lib/auth.ts`, and `src/lib/config.ts` for a typed API client, token helpers, and external URL config. Keep state with React hooks only.
- **Status:** DONE (2026-03-03)
- **Acceptance Criteria:**
  - `api.ts` exposes typed wrappers for `GET /api/projects`, `POST /api/projects`, and a generic `request()` that attaches auth header.
  - `auth.ts` exposes `getToken()`, `setToken()`, `clearToken()` and an `useAuth()` hook.
  - `config.ts` centralizes `VITE_API_BASE_URL` and external base URLs (Argo/Grafana).
- **Dependencies:** T1.4.1
- **Complexity:** S
- **Risk:** Low
- **Evidence:**
  - Typed API layer implemented in `apps/portal/frontend/src/lib/api.ts` with `request()`, `getProjects()`, `createProject()`, and auth header attachment.
  - Auth helpers refactored to `getToken()`, `setToken()`, `clearToken()` with `useAuth()` hook in `apps/portal/frontend/src/lib/auth.ts`.
  - External/runtime config centralized in `apps/portal/frontend/src/lib/config.ts` with API + Argo + Grafana base URLs.
  - Existing UI migrated from legacy `api-client.ts` to new modules; legacy client removed.

#### T1.4.5 Dockerfile + nginx SPA fallback
- **Description:** Add a multi-stage `Dockerfile` that builds the Vite app and serves with nginx, exposing port 80 and enabling SPA fallback for nested routes.
- **Status:** DONE (2026-03-03)
- **Acceptance Criteria:**
  - `apps/portal/frontend/Dockerfile` multi-stage build exists and produces a ~static nginx image.
  - Refreshing nested routes returns the SPA (nginx config uses try_files /index.html fallback).
  - Image listens on port 80.
- **Dependencies:** T1.4.1
- **Complexity:** S
- **Risk:** Low
- **Evidence:**
  - Multi-stage frontend image build implemented in `apps/portal/frontend/Dockerfile` (Node build stage + nginx runtime stage).
  - SPA fallback confirmed in nginx config via `try_files $uri /index.html` (`apps/portal/frontend/nginx.conf`).
  - Runtime port updated to `80` (`listen 80`, `EXPOSE 80`) and workload container port aligned to 80 in `workloads/apps/homelab-web/base/deployment.yaml`.

### E1.6 Portal Product Features (Render-like UX, read-only first)

#### T1.6.1 Services list page
- **Description:** Implement `/services` showing service name, environments, current status (health/sync), public URL (if present), and basic search/filter. Data should be read-only and may be adapted from `GET /api/projects` or a future `/services` endpoint.
- **Status:** DONE (2026-03-03)
- **Acceptance Criteria:**
  - `/services` shows a list/table of services with columns: name, env(s), status badge, public URL, last deploy timestamp (if available).
  - Client-side search and environment filter present and functional.
  - Loading skeletons and empty states implemented.
- **Dependencies:** T1.4.1, T1.4.4
- **Complexity:** M
- **Risk:** Medium
- **Evidence:**
  - `/services` is now data-driven from `GET /projects` via adapter logic, grouped by service name with environment aggregation (`apps/portal/frontend/src/pages/services-page.tsx`).
  - Services table renders required columns: service name, environment(s), health/sync status badges, public URL (or `N/A`), and last deploy timestamp (or `N/A`).
  - Client-side search and environment filtering implemented and combined in-memory before render (`services-page.tsx`).
  - Loading skeleton, API error + retry, empty state, and no-filter-match state added on the page.
  - API `Project` typing extended with optional `health`, `sync`, `publicUrl`, and `lastDeployAt` fields for forward compatibility (`apps/portal/frontend/src/lib/api.ts`).
  - Mobile topbar menu behavior on small screens updated from direct dashboard link to an actual navigation menu, fixing services flow navigation (`apps/portal/frontend/src/components/navigation/topbar.tsx`).

#### T1.6.2 Service detail page (overview)
- **Description:** Implement `/services/:serviceId` with Overview tab showing status cards: deployed version, sync/health state, links to Argo app, Grafana dashboard, and Logs. Endpoints list and a preview of recent deployments (top 5).
- **Acceptance Criteria:**
  - Overview tab shows version tag, health/sync indicators (use placeholders if backend not providing yet).
  - Links open external Argo/Grafana/Loki pages using templates from `config.ts`.
  - Endpoints section lists public/internal URLs if available.
  - Recent deployments preview shows up to 5 items (mocked fallback if backend lacks data).
- **Dependencies:** T1.6.1, T1.4.4
- **Complexity:** L
- **Risk:** Medium

#### T1.6.3 Service status view (health + sync)
- **Description:** Create reusable status components that display health and sync status with clear color semantics. Allow placeholder/mocked values until backend supplies real data.
- **Acceptance Criteria:**
  - `StatusCard` component accepts `health` and `sync` props and renders consistent UI.
  - Placeholder state when data is missing with CTA text like "Status unavailable — backend integration pending".
  - Tests or visual checks show all three states (Healthy, Degraded, Unknown).
- **Dependencies:** T1.6.2
- **Complexity:** S
- **Risk:** Low

#### T1.6.4 Deployment history page (read-only, mocked adapter)
- **Description:** `/services/:serviceId/deployments` lists last N deployments (timestamp, version/tag, outcome). Use a mocked data adapter that can be replaced by a backend adapter later.
- **Acceptance Criteria:**
  - Deployments page lists at least the 10 most recent entries (mocked if backend absent).
  - Data adapter implementation is isolated behind a single module `src/lib/adapters/deployments.ts` and documented TODO for swap.
  - Empty and error states handled.
- **Dependencies:** T1.4.4, T1.6.2
- **Complexity:** M
- **Risk:** Low

#### T1.6.5 Logs access (deep links to Grafana/Loki)
- **Description:** Provide a control that opens external Grafana/Loki with prefilled query parameters to filter by service label/namespace. Base URL and template strings come from `config.ts`.
- **Acceptance Criteria:**
  - Logs button opens a new tab to configured Grafana/Loki URL with query parameters populated for the selected service.
  - Template supports variables like `{{namespace}}`, `{{app_label}}`, and `{{time_range}}`.
  - Button disabled/hidden if external URL not configured.
- **Dependencies:** T1.4.4, infra (Grafana/Loki URLs)
- **Complexity:** S
- **Risk:** Low

#### T1.6.6 External links config (Argo CD, Grafana)
- **Description:** Add `src/lib/config.ts` entries and README instructions for configuring Argo CD and Grafana base URLs in environment variables; support in-cluster `VITE_API_BASE_URL=/api` and local dev `VITE_API_BASE_URL=http://localhost:8000/api`.
- **Acceptance Criteria:**
  - `config.ts` reads `VITE_ARGO_BASE_URL` and `VITE_GRAFANA_BASE_URL` with sensible defaults (empty).
  - README documents how to configure these env vars for local dev and in-cluster values.
- **Dependencies:** T1.4.4
- **Complexity:** S
- **Risk:** Low

#### T1.6.7 Service registry model: static-config MVP vs DB-backed decision
- **Description:** Decide the simplest approach for service metadata: either add a lightweight DB model in backend or use a static YAML/JSON config stored in the repo for MVP. Implement the chosen MVP path.
- **Acceptance Criteria:**
  - Decision recorded in ticket with rationale and follow-up migration plan.
  - If static-config chosen: example `apps/portal/frontend/services.sample.json` included and used by the frontend adapter as fallback.
  - If DB-backed chosen: backend migration ticket referenced and sample API contract added.
- **Dependencies:** T1.2.1 (backend), T1.4.4
- **Complexity:** S
- **Risk:** Medium

#### T1.6.8 UX polish and shared components
- **Description:** Implement consistent loading, empty, and error components, Sonner toasts, and reuse shadcn Card/Table/Tabs/Dialog components across pages. Make layout responsive.
- **Acceptance Criteria:**
  - Shared `components/` directory with `Loading`, `Empty`, `Error`, and `Toast` wrappers.
  - All major pages use consistent components and are responsive on small screens.
- **Dependencies:** T1.4.1
- **Complexity:** M
- **Risk:** Low

#### T1.6.9 Frontend README and run instructions
- **Description:** Document local dev, env vars, Docker build/run, and note that deploy/logs are read-only and may be mocked until backend integration is complete.
- **Acceptance Criteria:**
  - `apps/portal/frontend/README.md` with: install, dev start, build, docker build/run, env vars list, and note about read-only behavior.
  - Commands validated locally (where possible) and documented.
- **Dependencies:** T1.4.1, T1.4.5
- **Complexity:** S
- **Risk:** Low

#### Anti-scope / NOT included in this iteration
- No deploy buttons or any write/deploy actions (no PR generation, no kubectl apply from UI).
- No environment variable editor or secrets management UI.
- No full Backstage-like scaffolding or cataloging features.
- No embedded Grafana dashboards — link-outs only.

### E2.1 CI pipeline with immutable artifacts

#### T2.1.1 Build/test/publish backend and frontend images in CI
- **Description:** Add pipeline stages for lint/test/build/publish to GHCR or Harbor.
- **Acceptance Criteria:**
  - Every main branch merge publishes immutable image tags.
  - Failed tests block publish.
- **Dependencies:** T1.2.3
- **Complexity:** M
- **Risk:** Medium

#### T2.1.2 Attach SBOM/provenance metadata to images
- **Description:** Generate SBOM and store build provenance to improve auditability.
- **Acceptance Criteria:**
  - CI artifact contains SBOM for each image.
  - Build metadata traceable to commit SHA.
- **Dependencies:** T2.1.1
- **Complexity:** M
- **Risk:** Medium

### E2.2 Automated image tag promotion for GitOps

#### T2.2.1 Implement auto-update controller (Argo CD Image Updater or equivalent)
- **Description:** Wire automated updates of image tags in GitOps manifests for dev.
- **Acceptance Criteria:**
  - New dev image tag triggers Git commit/PR automatically.
  - Sync applies without manual tag edits.
- **Dependencies:** T2.1.1, T0.2.2
- **Complexity:** M
- **Risk:** Medium

#### T2.2.2 Introduce gated promotion to staging/prod
- **Description:** Require manual approval or policy checks before higher env promotion.
- **Acceptance Criteria:**
  - Promotion pipeline supports approve/reject checkpoint.
  - Rollback procedure tested once.
- **Dependencies:** T2.2.1
- **Complexity:** L
- **Risk:** High

### E2.3 Registry and provenance basics

#### T2.3.1 Select and configure primary registry (GHCR default)
- **Description:** Standardize on one registry and auth pattern for cluster pulls.
- **Acceptance Criteria:**
  - Pull secrets configured and rotated procedure documented.
  - Registry retention policy defined.
- **Dependencies:** T2.1.1
- **Complexity:** S
- **Risk:** Low

---

### E3.1 Argo CD and Kubernetes RBAC enforcement

#### T3.1.1 Define Argo CD project-level RBAC boundaries
- **Description:** Restrict source repos, destinations, and namespaces by project.
- **Acceptance Criteria:**
  - App projects cannot deploy outside assigned namespaces.
  - Unauthorized repo path usage denied.
- **Dependencies:** T1.1.2
- **Complexity:** M
- **Risk:** High

#### T3.1.2 Audit and tighten Kubernetes service account permissions
- **Description:** Review all platform service accounts and reduce wildcards.
- **Acceptance Criteria:**
  - No cluster-admin bindings for app workloads.
  - RBAC audit report committed.
- **Dependencies:** T0.3.2
- **Complexity:** M
- **Risk:** Medium

### E3.2 External auth integration

#### T3.2.1 Decide OAuth provider vs Cloudflare Zero Trust
- **Description:** Evaluate operational burden, identity source, and ingress integration.
- **Acceptance Criteria:**
  - Decision ADR accepted.
  - Integration plan includes fallback access method.
- **Dependencies:** T1.3.2
- **Complexity:** S
- **Risk:** Medium

#### T3.2.2 Implement chosen SSO integration for Argo CD and app ingress
- **Description:** Replace interim auth with centralized identity control.
- **Acceptance Criteria:**
  - User/group claims map to Argo CD and app roles.
  - Local admin bypass disabled except break-glass.
- **Dependencies:** T3.2.1
- **Complexity:** L
- **Risk:** High

### E3.3 Secrets encryption and rotation workflow

#### T3.3.1 Implement secrets-as-code with SOPS (recommended default)
- **Description:** Encrypt secret manifests at rest in Git and decrypt in-cluster.
- **Acceptance Criteria:**s
  - Secrets in repo are encrypted only.
  - Argo CD can deploy and consume decrypted secrets.
- **Dependencies:** T1.1.1
- **Complexity:** M
- **Risk:** High

#### T3.3.2 Create quarterly secret rotation runbook and automation hooks
- **Description:** Define repeatable process for rotating DB creds, tokens, and registry secrets.
- **Acceptance Criteria:**
  - Rotation checklist exists and is tested once.
  - Rotation causes no prolonged outage (>5 min target).
- **Dependencies:** T3.3.1
- **Complexity:** M
- **Risk:** Medium

---

### E4.1 Metrics and dashboards

#### T4.1.1 Deploy kube-prometheus-stack with minimal retention
- **Description:** Install Prometheus/Grafana tuned for homelab resource limits.
- **Acceptance Criteria:**
  - Cluster/node/pod metrics visible.
  - Retention and storage usage documented.
- **Dependencies:** T1.1.1
- **Complexity:** M
- **Risk:** Medium

#### T4.1.2 Build platform health dashboard
- **Description:** Create dashboards for app availability, deployment status, and error rates.
- **Acceptance Criteria:**
  - Single dashboard shows API health, DB up status, frontend reachability.
  - Alert threshold prototypes configured.
- **Dependencies:** T4.1.1, T1.2.3
- **Complexity:** M
- **Risk:** Medium

### E4.2 Centralized logging

#### T4.2.1 Deploy Loki + Promtail and collect workload logs
- **Description:** Centralize logs with low-ops stack; defer ELK unless scale demands.
- **Acceptance Criteria:**
  - Logs searchable by namespace/app/container.
  - Basic retention policy active.
- **Dependencies:** T1.2.3
- **Complexity:** M
- **Risk:** Medium

#### T4.2.2 Add log-to-triage workflow documentation
- **Description:** Define how to correlate logs with deployments and incidents.
- **Acceptance Criteria:**
  - Runbook includes at least 3 common failure scenarios.
  - Time-to-diagnose baseline measured once.
- **Dependencies:** T4.2.1
- **Complexity:** S
- **Risk:** Low

### E4.3 Deployment and change visibility

#### T4.3.1 Build release dashboard (commits → image tags → Argo sync)
- **Description:** Surface end-to-end delivery state for confidence and debugging.
- **Acceptance Criteria:**
  - Dashboard links commit SHA to deployed image and sync status.
  - Drift detection visible.
- **Dependencies:** T2.2.2, T4.1.1
- **Complexity:** L
- **Risk:** Medium

---

### E5.1 Multi-environment GitOps structure

#### T5.1.1 Split environments with clear promotion contracts
- **Description:** Implement dev/staging/prod overlays and promotion rules.
- **Acceptance Criteria:**
  - Environment differences are declarative and auditable.
  - Promotion between envs uses documented workflow only.
- **Dependencies:** T2.2.2
- **Complexity:** L
- **Risk:** High

### E5.2 Self-service project bootstrap

#### T5.2.1 Create project template generator (repo + manifests + CI seed)
- **Description:** Script/template that scaffolds a new service in <30 minutes.
- **Acceptance Criteria:**
  - New project includes CI, deployment manifests, and baseline policies.
  - At least one generated project deployed successfully.
- **Dependencies:** T5.1.1
- **Complexity:** XL
- **Risk:** High

### E5.3 Internal developer portal seed

#### T5.3.1 Publish a lightweight service catalog page
- **Description:** Start with static/service metadata view before full portal platform.
- **Acceptance Criteria:**
  - Catalog includes owner, repo, runbook, env status links.
  - Data source is Git (not manual spreadsheet).
- **Dependencies:** T5.2.1
- **Complexity:** M
- **Risk:** Medium

---

## Portal Level 3+: GitOps Write Workflows (Later Stage)

> This section outlines portal-driven GitOps mutation workflows (deploy, promote, config changes, self-service). **Critical design rule:** the portal writes Git changes; Argo CD remains the sole reconciler.

### Readiness gates (must be true before starting Level 3)

Before beginning Portal Level 3 work, your platform must demonstrate:

1. **Multi-service stability:** At least 3 different services deployed and stable (healthy and synced) for 2–4 weeks with no force-sync or manual cluster interventions required.
2. **Immutable artifacts from CI:** Every merged commit to app repos publishes an immutable image tag (semver or git-sha based); image rebuilds are reproducible and auditable.
3. **Proven image promotion:** Either auto-update (Argo CD Image Updater or equivalent) successfully bumps images in dev for >10 consecutive merges, OR PR-based manual bumps are tested end-to-end at least 3 times with zero failed syncs.
4. **Secrets strategy chosen and in-use:** Either SOPS or Sealed Secrets is integrated, secrets in Git are encrypted at rest, and at least 2 services consume decrypted secrets without issues.
5. **Observability baseline active:** Prometheus scrapes metrics, Grafana dashboards display cluster/app health, Loki collects logs, and at least one alert fires on a real event (and is confirmed to work).
6. **Runbook for rollback exists and tested:** Platform operator has walked through a rollback (git revert or tag bump) at least once and confirmed Argo CD applied the change within <5 minutes.

Attempting Level 3 before these gates will result in rework and operational toil.

---

## Phase 6 (Month 4–5): GitOps Write Workflows & Self-Service (Portal Level 3)

**Goal:** Enable developers to deploy, promote, and configure workloads through the portal by writing managed Git changes, keeping Argo CD as the single source of truth and reconciler.

### Epics

- E6.1 GitOps Git integration foundation
- E6.2 Deploy and promotion workflows (PR-based)
- E6.3 Configuration and secrets management workflows
- E6.4 Service scaffolding and registration (minimal MVP)
- E6.5 Multi-user access control and audit (optional later)

---

### E6.1 GitOps Git integration foundation

#### T6.1.1 Write ADR: Portal-to-Git workflow model
- **Description:** Decide how the portal will create Git changes: Option A (GitHub API PRs directly), Option B (write to "requests" branch and bot opens PR), or Option C (direct commits to feature branches, discouraged). Document trade-offs: latency, security token scope, audit trail, multi-git-provider support.
- **Status:** TODO
- **Acceptance Criteria:**
  - ADR accepts one option with rationale.
  - Implementation plan includes token management and scope limits.
  - Fallback for GitHub outage or rate limits addressed.
- **Dependencies:** None
- **Complexity:** S
- **Risk:** Medium
- **Notes:** Choose Option A (GitHub API PRs) for solo engineer simplicity and audit trail. Option B adds workflow bot maintenance. Option C loses audit and requires branch cleanup discipline.

#### T6.1.2 Implement backend Git integration module
- **Description:** Create `app/lib/git_service.py` (backend) with:
  - `create_branch(repo, from_branch, new_branch)` → returns branch ref
  - `modify_file(repo, branch, file_path, new_content)` → replaces file and returns diff
  - `open_pr(repo, from_branch, to_branch, title, description)` → returns PR URL and ID
  - `commit_to_branch(repo, branch, files_dict, message)` → multi-file commit
  - `close_pr(repo, pr_id)` → for cleanup (optional)
  - Error handling for conflicts, rate limits, auth failures.
- **Status:** TODO
- **Acceptance Criteria:**
  - Module has type hints and docstrings.
  - Unit tests mock GitHub API calls for all happy paths + auth failure + conflict scenarios.
  - `open_pr()` returns minimal PR object: `{id, url, number, state}`.
  - Dry-run mode logs calls without executing (for testing).
- **Dependencies:** T6.1.1
- **Complexity:** M
- **Risk:** Medium
- **Notes:** Use PyGithub or similar for API calls. Guard against rate limits with retries/backoff.

#### T6.1.3 Configure fine-scoped GitHub token and store securely
- **Description:** Create a GitHub personal access token (or fine-grained token) scoped to: workloads only, write access to Contents + Pull Requests. Store in `homelab-api` secret (encrypted via SOPS/Sealed Secrets) as `GIT_GITHUB_TOKEN`. Document token rotation quarterly.
- **Status:** TODO
- **Acceptance Criteria:**
  - Token has minimum required scopes (no admin, no org/user data access).
  - Secret stored encrypted in workloads repo or homelab-api namespace.
  - Rotation procedure documented in ops runbook.
  - Dry-run test confirms token can list repo without deploying.
- **Dependencies:** T6.1.2, secrets strategy (Phase 3)
- **Complexity:** S
- **Risk:** High
- **Notes:** Use GitHub "fine-grained personal access tokens" (beta at time of writing) for maximum scope isolation if available.

#### T6.1.4 Add Git provider abstraction + GitHub implementation
- **Description:** Design a `GitProvider` interface (Python ABC or Protocol) so future additions (GitLab, Gitea) stay decoupled. Implement GitHub provider.
- **Status:** TODO
- **Acceptance Criteria:**
  - `GitProvider` protocol defines required methods.
  - GitHub implementation passes all T6.1.2 tests.
  - Backend can be configured to use different providers via env var.
- **Dependencies:** T6.1.2
- **Complexity:** M
- **Risk:** Low
- **Notes:** Defer GitLab/Gitea until a second provider is actually needed.

---

### E6.2 Deploy and promotion workflows (PR-based)

#### T6.2.1 Portal API: "Deploy latest to dev" endpoint
- **Description:** `POST /api/services/{service_id}/deploy-to-dev` endpoint that:
  1. Fetches latest image tag from registry (or uses last N tags from CI artifact).
  2. Creates feature branch from dev overlay.
  3. Modifies kustomization patch to bump image tag in dev only.
  4. Commits and opens PR with title "Deploy {service}: {new_tag} to dev".
  5. Returns PR URL and status.
- **Status:** TODO
- **Acceptance Criteria:**
  - Endpoint requires auth (logged-in user).
  - PR diff shows only image tag change in dev kustomize patch.
  - Argo CD auto-syncs after merge (if Image Updater auto-sync enabled) or manual sync works.
  - PR can be merged without conflict.
  - Rollback behavior: closing PR without merge leaves dev unchanged.
- **Dependencies:** T6.1.2, T1.2.3 (app deployed), T2.1.1 (CI publishes images)
- **Complexity:** M
- **Risk:** High
- **Notes:** Use semantic versioning tag or git-sha convention. Handle case where latest tag already in dev (return 204 or info message).

#### T6.2.2 Portal API: "Promote dev → prod" endpoint
- **Description:** `POST /api/services/{service_id}/promote-to-prod` endpoint that:
  1. Reads current image tag from dev overlay (already deployed).
  2. Creates feature branch from prod overlay.
  3. Modifies prod kustomize patch to match dev tag.
  4. Commits and opens PR with title "Promote {service}: {tag} to prod".
  5. Returns PR URL (user approves/merges in GitHub).
- **Status:** TODO
- **Acceptance Criteria:**
  - Promotion PR contains only prod patch change.
  - Promotion copies the exact tag from dev (no manual override yet).
  - PR can be merged without conflict.
  - Merged promotion triggers Argo sync and deployment to prod.
  - Anti-pattern check: promotion of uncommitted/test tags blocked (tag must exist in registry).
- **Dependencies:** T6.2.1, T6.1.2
- **Complexity:** M
- **Risk:** High
- **Notes:** Later enhancement: gated promotion (approvals, policy checks). For MVP: user merges PR in GitHub.

#### T6.2.3 Portal API: "Rollback to previous tag" endpoint
- **Description:** `POST /api/services/{service_id}/rollback` endpoint that:
  1. Reads current deployed tag from specified env overlay.
  2. Fetches previous 5 image tags from registry (or Git commit history of patch file).
  3. Allows user to select target tag.
  4. Creates PR bumping image tag back to target.
  5. User merges; Argo re-syncs.
- **Status:** TODO
- **Acceptance Criteria:**
  - At least 5 previous tags available for selection.
  - Rollback PR contains only tag change.
  - Rollback tested end-to-end once (deploy version N, deploy N+1, rollback to N, confirm N running).
  - Rollback does not modify any other deployments.
- **Dependencies:** T6.2.1, T6.1.2
- **Complexity:** M
- **Risk:** Medium
- **Notes:** Integrate with container registry API (GHCR, Harbor) to list tags with dates. Provide UI confirmation before generating PR.

#### T6.2.4 Portal UI: Deploy & promote controls
- **Description:** Add buttons/modals to service detail page:
  - "Deploy latest to dev" button → calls T6.2.1 → shows PR link in toast.
  - "Promote to prod" button (if user in prod-approver role) → calls T6.2.2 → shows PR link.
  - "Rollback" button → modal to select previous tag → calls T6.2.3.
  - Each button shows: current deployed tag, latest available tag, PR status (open/merged).
- **Status:** TODO
- **Acceptance Criteria:**
  - Buttons disabled if deploy already in progress (PR open).
  - PR links clickable and open in new tab.
  - Toast shows success/error with clear message.
  - UI shows previous 3 deployed tags inline.
- **Dependencies:** T6.2.1, T6.2.2, T6.2.3, T1.6.2 (service detail page)
- **Complexity:** M
- **Risk:** Low
- **Notes:** Show PR state (open, merged, closed) with color badges; auto-refresh every 30s to detect merge.

#### T6.2.5 Release traceability: link deployments to commits and images
- **Description:** Enhance Argo Application status annotation to include deployed commit SHA and image tag. Store in Argo Application `status.summary.images` and display in portal UI. Add metadata endpoint `GET /api/services/{service_id}/deployment-info` that returns: {deployed_image, image_digest, git_commit, deployed_timestamp, pr_link}.
- **Status:** TODO
- **Acceptance Criteria:**
  - Argo Application has custom annotations: `image-tag`, `commit-sha`, `deployed-at`.
  - Portal displays these in service detail → "Deploy Info" card.
  - Commit SHA links to GitHub commit; image tag links to registry.
  - pr_link field pulls from Argo Application label (set by CI or manual comment).
- **Dependencies:** T6.2.1, T1.6.2
- **Complexity:** M
- **Risk:** Medium
- **Notes:** Metadata initially populated via PR merge event (GitHub Actions comment on Argo Application manifest); later automate via Argo Notification or custom controller.

---

### E6.3 Configuration and secrets management workflows

#### T6.3.1 Portal API: "Edit config (non-secret environment variables)" endpoint
- **Description:** `POST /api/services/{service_id}/config/set` endpoint that:
  1. Takes `{env, config_key, config_value}` payload.
  2. Validates input: no known secret patterns (API_KEY, PASSWORD, etc.), max length, alphanumeric/standard chars.
  3. Reads current ConfigMap patch from kustomize overlay.
  4. Merges new key-value into patch.
  5. Creates PR with commit message "Config: {service} {env} {key}={value}".
  6. Returns PR URL.
  - Alternative simpler MVP: no validation, just require env var name convention (e.g. `APP_*` only).
- **Status:** TODO
- **Acceptance Criteria:**
  - Input validation rejects obvious secrets (contains PASSWORD, API_KEY, TOKEN, SECRET in name or typical secret patterns in value).
  - PR diff shows only ConfigMap patched object with updated data.
  - After merge, pod restart is triggered (via checksum annotation or kustomize patchesStrategicMergeList).
  - Multiple calls in succession create one PR (or update existing pending PR) to avoid PR spam.
- **Dependencies:** T6.1.2, workload has ConfigMap (T1.2.3)
- **Complexity:** M
- **Risk:** High
- **Notes:** Prevent accidental plaintext secrets by name-based heuristic. For MVP, allow portal admin to explicitly allow keys; do not auto-open to all env vars.

#### T6.3.2 Portal API: "Edit secrets (SOPS/Sealed Secrets)" endpoint
- **Description:** `POST /api/services/{service_id}/config/set-secret` endpoint that:
  1. Takes `{env, secret_key, secret_value}` payload (value submission over HTTPS only).
  2. Fetches current Secret patch from kustomize overlay.
  3. If SOPS: call local SOPS CLI to encrypt value, then update manifest.
  4. If Sealed Secrets: call sealed-secret controller API to seal value.
  5. Creates PR with commit "Secret: {service} {env} {key} updated".
  6. Returns PR URL (user reviews PR in GitHub; actual secret value not visible in portal).
- **Status:** TODO
- **Acceptance Criteria:**
  - Secret value never logged or stored in unencrypted form.
  - PR shows encrypted/sealed value only (never plaintext).
  - Argo CD applies decrypted secret successfully.
  - At least one secret edit end-to-end tested.
  - Rate limiting (1 edit per 30s) to prevent accidental spam.
- **Dependencies:** T6.1.2, T3.3.1 (secrets strategy live), workload has Secret (T1.2.3)
- **Complexity:** L
- **Risk:** High
- **Notes:** This is high-risk: leaking a secret value is catastrophic. Require explicit token/MFA for secret edits. Consider requiring portal admin approval before PR creation.

#### T6.3.3 Implement pod restart / rollout trigger (annotation checksum strategy)
- **Description:** Define and implement restart strategy for ConfigMap/Secret changes. Recommended: add checksum annotation to Deployment/StatefulSet pod template spec when ConfigMap/Secret is patched. Argo CD applies annotation change → Kubernetes restarts pods. Document in ops runbook.
- **Status:** TODO
- **Acceptance Criteria:**
  - Kustomize patch adds `checksum/config: <md5(configmap_data)>` annotation to pod spec when ConfigMap changes.
  - Pod restarts within 1 minute of PR merge & Argo sync.
  - Service remains available during rolling restart (readiness probes work).
  - Rollback also triggers pod restart (atomic).
- **Dependencies:** T6.3.1, T1.2.3 (app with graceful shutdown)
- **Complexity:** M
- **Risk:** Medium
- **Notes:** Alternative: use Sealed Secrets/SOPS Controller annotations (auto-restart on secret update). Implement whichever is already in use.

#### T6.3.4 Portal UI: Config and secrets editing interface
- **Description:** Add tabs to service detail page:
  - "Config" tab: list current ConfigMap keys with values (non-sensitive); "Edit" button opens form to add/modify; "Delete" removes key (if allowed).
  - "Secrets" tab: list secret keys (values hidden, show "***"); warning banner "You are about to modify encrypted secrets"; form to add/modify/delete.
  - Both tabs show: pending PR link, last update timestamp, editor (username).
  - Both tabs: "Editing disabled for prod" warning if user lacks prod-write role.
- **Status:** TODO
- **Acceptance Criteria:**
  - Config tab allows add/edit/delete with validation (prevent obviously bad keys).
  - Secrets tab requires confirm+MFA flow (or portal admin approval).
  - Both tabs show PR status in real-time (open/merged).
  - Form submission shows loading state and success toast.
- **Dependencies:** T6.3.1, T6.3.2, T1.6.2
- **Complexity:** M
- **Risk:** Medium
- **Notes:** MVP: secrets editing disabled unless user is app owner + admin role (two roles required).

---

### E6.4 Service scaffolding and registration (minimal MVP)

#### T6.4.1 Write ADR: Service metadata storage and registration model
- **Description:** Decide whether service metadata (name, owner, repo, runbook URL, envs, tags) lives in: Option A (Git-owned `services.yaml` or `services/` directory), Option B (backend database), Option C (Argo CD Application labels/annotations only). Option A is recommended for homelab (low ops burden, auditable, no DB).
- **Status:** TODO
- **Acceptance Criteria:**
  - ADR accepts Option A (Git-backed YAML manifest) with rationale.
  - Manifest schema defines required fields: name, owner_email, repo_url, envs[], tags.
  - Migration path to Option B noted if scale demands.
- **Dependencies:** None
- **Complexity:** S
- **Risk:** Low

#### T6.4.2 Implement service template generator (CLI + documentation)
- **Description:** Create `scripts/scaffold-service.sh` (or Python equivalent) that:
  1. Prompts for: service name, description, image repo (e.g. `ghcr.io/wlodzimierrr/my-app`), base language/framework.
  2. Generates and commits to workloads repo:
     - `apps/{service-name}/base/` (kustomization.yaml, deployment.yaml, service.yaml, hpa.yaml).
     - `apps/{service-name}/envs/dev/` and `envs/prod/` with kustomization overlays.
     - `environments/{dev,prod}/kustomization.yaml` patch to include new app.
     - Argo Application manifests for both envs under `bootstrap/`.
  3. Generates CI stub (GitHub Actions `.github/workflows/build-{service}.yml`) that: builds image, runs tests, publishes to registry.
  4. Registers service in `workloads/services.yaml` with metadata.
  5. Creates PR with all files + instructions for follow-up.
- **Status:** TODO
- **Acceptance Criteria:**
  - Script outputs a generated folder tree matching conventions.
  - Generated manifests are valid and deployable via `kustomize build`.
  - Generated Argo Application syncs without errors.
  - Generated CI workflow publishes test image successfully (or dry-runs).
  - At least one service scaffolded end-to-end and deployed.
  - Script is documented with examples in `workloads/README.md`.
- **Dependencies:** T6.4.1, T0.2.1 (workloads repo structure)
- **Complexity:** L
- **Risk:** High (template drift if not maintained)
- **Notes:** Command: `./scaffold-service.sh --name my-app --image ghcr.io/org/my-app`. Start minimal; iterate based on repeated patterns.

#### T6.4.3 Portal UI: "New service" scaffolding flow (later enhancement)
- **Description:** Add "New Service" button to services list that opens a step-by-step wizard:
  1. Step 1: Basic info (name, description, owner, repo URL).
  2. Step 2: Select template type (backend, frontend, job, etc.).
  3. Step 3: Configure image registry and build CI tool.
  4. Step 4: Review generated manifests and confirm.
  5. Calls backend endpoint that runs `scaffold-service.sh` with inputs and returns PR URL.
- **Status:** TODO
- **Acceptance Criteria:**
  - Wizard shows generated manifests for manual review before PR creation.
  - Back/next buttons allow revision.
  - PR link provided at completion.
  - Deployed service appears in list after PR merge and Argo sync.
- **Dependencies:** T6.4.2, T1.6.1 (services list)
- **Complexity:** L (UI only; backend is T6.4.2)
- **Risk:** Low
- **Notes:** Defer this UI until scaffold script proves stable (1–2 generations done manually).

#### T6.4.4 Service registration and metadata maintenance
- **Description:** Create `workloads/services.yaml` with schema:
  ```yaml
  services:
    - name: homelab-api
      owner_email: you@example.com
      repo_url: https://github.com/user/homelab
      description: Backend API for homelab platform
      envs:
        - name: dev
          namespace: homelab-api-dev
          argo_app: homelab-api-dev
        - name: prod
          namespace: homelab-api-prod
          argo_app: homelab-api-prod
      tags: [core, python, fastapi]
  ```
  Maintain by hand initially; later: auto-generate from scaffold.
- **Status:** TODO
- **Acceptance Criteria:**
  - Schema defined and validated (JSON Schema or similar).
  - All currently deployed services (homelab-api, homelab-web, etc.) registered.
  - service-name lookup returns all metadata needed for deploy/promote/config workflows.
  - Portal uses this as service directory (search, filter, list).
- **Dependencies:** T6.4.1, T1.2.3 (services exist)
- **Complexity:** S
- **Risk:** Low

---

### E6.5 Multi-user access control and audit (optional later phase)

#### T6.5.1 Portal RBAC roles and enforcement
- **Description:** Define portal roles: `admin` (all actions), `operator` (deploy/promote/config on non-prod), `developer` (read-only + can deploy-to-dev only), `viewer` (read-only). Map to JWT claims or OAuth groups. Enforce in backend API layer with decorators.
- **Status:** TODO
- **Acceptance Criteria:**
  - Role enum exists in backend.
  - Each endpoint checks role via decorator (e.g. `@require_role(admin, operator)`).
  - JWT token includes role claim (or mapped from OAuth/OIDC).
  - At least 2 users with different roles tested.
- **Dependencies:** T1.3.1 (JWT auth), external auth (T3.2.2 if OAuth)
- **Complexity:** M
- **Risk:** Medium
- **Notes:** Start simple: admin (own user) + demo user (public viewer). Add more roles on demand.

#### T6.5.2 Audit logging for portal mutations (GitOps actions)
- **Description:** Log all write actions (deploy, promote, config edit, service create) to backend database or structured file with: timestamp, user, action type, service, target env, PR URL, status (success/failed). Query endpoint `GET /api/audit-log` shows filtered results. Portal UI displays audit log per service.
- **Status:** TODO
- **Acceptance Criteria:**
  - Every write action creates audit entry.
  - Audit log queryable by user, date range, service, action type.
  - At least 30 days of logs retained (configurable).
  - Portal shows audit trail in service detail sidebar (last 10 changes by whom and when).
- **Dependencies:** T6.2.1, T6.3.1, T6.4.2, backend database (T1.2.2)
- **Complexity:** M
- **Risk:** Low
- **Notes:** Start with simple table in Postgres. Later: export to centralized audit sink (Grafana Loki, Splunk, etc.).

#### T6.5.3 Break-glass / emergency access procedure
- **Description:** Document and test procedure for platform admin to perform mutations (deploy, promote, config) if portal is down or unresponsive. Steps: direct Git branch + commit + PR (no portal), manually merge PR, await Argo sync.
- **Status:** TODO
- **Acceptance Criteria:**
  - Procedure documented in ops runbook.
  - Tested at least once (intentionally use break-glass, confirm success).
  - Break-glass action logged separately (manual Git change).
  - Recovery plan to re-enable portal noted.
- **Dependencies:** T6.2.1, docs
- **Complexity:** S
- **Risk:** Low

---

## Sequencing and dependencies for Portal Level 3

### Implementation order by epic

1. **Start E6.1 (Git integration)** once Phase 2 and 3 are stable (CI proven, secrets in place).
   - T6.1.1 → T6.1.2 → T6.1.3 → T6.1.4 (do all before moving to E6.2).

2. **Proceed with E6.2 (Deploy/promote/rollback)** immediately after E6.1.
   - T6.2.1 → T6.2.2 → T6.2.3 → T6.2.4 → T6.2.5.
   - **Checkpoint:** First deploy PR works end-to-end.
   - **Checkpoint:** Promotion works at least once.
   - **Checkpoint:** Rollback tested and verified.

3. **Parallel E6.3 (Config/secrets)** after E6.2 basics (T6.2.1–T6.2.4) are working.
   - T6.3.1 → T6.3.2 → T6.3.3 → T6.3.4.
   - **Checkpoint:** Config edit PR created and merged; env var applied to pod.
   - **Checkpoint:** Secret edit PR created; secret decrypts and applies (manual verification).

4. **Begin E6.4 (Service scaffolding)** after >3 services running and deploy/promote proven stable (2–3 weeks into Level 3).
   - T6.4.1 → T6.4.2 → T6.4.4 → T6.4.3 (portal UI only after manual scaffolding proven).

5. **E6.5 (Multi-user + audit)** only after E6.2/E6.3 prove stable and if adding more users.
   - T6.5.1 → T6.5.2 → T6.5.3.
   - **Do not do E6.5 for a solo engineer initially.**

### Critical sequencing rule

Do not attempt E6.2 or E6.3 until you have successfully:
- Expected readiness gates passed (above).
- Completed T6.1.1–T6.1.4 (Git integration tested with dry runs).
- Tested Git provider token with at least one manual PR (not via portal, just verify token works).

Attempting Level 3 before these checkpoints will result in Git-based outages and rework.

---

## Anti-scope creep for Portal Level 3

Explicitly NOT included in this phase:

- **Direct kubectl apply from portal:** Only Git-backed changes allowed. Cluster is read-only from portal view.
- **Custom Kubernetes controllers for provisioning:** Use Argo CD Applications only; no custom operators yet.
- **Full internal developer platform portal (e.g. Backstage):** Keep this lightweight (services list + deploy controls + links out). Advanced scaffolding, policy templates, and multi-team governance belong in later years.
- **Complex policy engines (OPA/Kyverno/Gatekeeper):** Rely on Git review process and RBAC for approval gates initially.
- **Multi-tenant isolation:** Assume single owner (you) or very small team. Tenant boundaries defer to Phase 7+.
- **Canary/blue-green deployments:** Use simple rolling updates. Advanced deployment strategies (traffic split, progressive rollout) deferred.
- **Service mesh integration:** Keep networking simple. Defer Istio/Linkerd until you have concrete mTLS or traffic-splitting requirements.
- **Portal write access to non-app resources:** services, namespaces, secrets (platform-layer) must be edited directly in Git. Portal only edits app-layer configs and images.

---

## Suggested Portal Level 3 timeline (evenings/weekends, ~10–12h/week)

Assumption: Phase 2–5 readiness gates are already met.

### Month 1 of Level 3 (Weeks 1–4)
**Goal:** Prove PR-based deploy workflow.

- **Week 1:** Complete E6.1 (Git integration foundation).
  - T6.1.1 → ADR done.
  - T6.1.2 → Git service module + unit tests pass.
  - T6.1.3 → Token provisioned and rotated into secret.
  - ~12–15 hours.

- **Week 2:** Start E6.2.
  - T6.2.1 → Deploy-to-dev endpoint works, opens PR, can be merged.
  - T6.2.4 → UI button added, tested manually.
  - Checkpoint: First deploy PR from portal created and merged; service restarts successfully.
  - ~10–12 hours.

- **Week 3–4:** Complete core E6.2.
  - T6.2.2 → Promote-to-prod endpoint works.
  - T6.2.3 → Rollback endpoint works.
  - T6.2.5 → Traceability annotations added (minimal version).
  - End-to-end test: dev deploy → promote → rollback all work.
  - Checkpoint: Full deploy/promote/rollback workflow end-to-end tested.
  - ~15–18 hours.

### Month 2 of Level 3 (Weeks 5–8)
**Goal:** Config/secrets workflows + stabilize.

- **Week 5:** E6.3.1–T6.3.2.
  - T6.3.1 → Config edit endpoint.
  - T6.3.2 → Secrets edit endpoint (requires high scrutiny).
  - ~12–15 hours.

- **Week 6:** E6.3.3–T6.3.4.
  - T6.3.3 → Pod restart strategy tested.
  - T6.3.4 → Portal UI for config/secrets.
  - ~10–12 hours.

- **Week 7:** Stabilize and test E6.2/E6.3.
  - End-to-end tests: config edit + pod restart + verify new value in app.
  - Edge case testing: concurrent edits, rollback mid-edit, token expiry.
  - ~8–10 hours.

- **Week 8:** Ops & runbook.
  - Document Level 3 workflows: how to deploy, promote, rollback, edit config.
  - Incident playbooks: "PR merge failed", "token expired", "conflict on promote".
  - ~6–8 hours.

### Month 3 of Level 3 (Weeks 9–12)
**Goal:** Service scaffolding + evaluation.

- **Week 9–10:** E6.4.2–T6.4.4.
  - T6.4.1 → ADR and schema for services.yaml.
  - T6.4.2 → Scaffold script.
  - T6.4.4 → services.yaml populated.
  - Generate at least 2 services end-to-end.
  - ~15–18 hours.

- **Week 11:** E6.4.3 (optional for Month 3; defer if time-constrained).
  - Portal UI for "New Service" wizard.
  - ~8–10 hours.

- **Week 12:** Evaluation & retrospective.
  - Successful service scaffolds deployed?
  - Deployment/promotion automatio proven? Any gaps?
  - Decision: proceed to E6.5 or iterate more on E6.2–E6.4?
  - Document lessons learned and update runbooks.
  - ~4–6 hours.

### Estimated total Level 3 effort
- Month 1: 35–45 hours (Git integration + core deploy/promote/rollback).
- Month 2: 40–50 hours (Config/secrets + stabilization).
- Month 3: 27–34 hours (Service scaffolding + evaluation).
- **Total: 100–130 hours (~10–12 hours/week for 10 weeks).**

If solo engineering at evenings/weekends (5–8 hours/week), extend by 1.5–2x (15–20 weeks for full Level 3).

### Checkpoints and decision gates

- **After Month 1:** Can portal deploy to dev, merge PR, and restart pod? If YES, proceed to Month 2. If NO, iterate on E6.2 before moving forward.
- **After Month 2:** Can operator edit config and secrets via portal? Are all changes Git-backed? If YES, proceed to scaffolding. If NO, address E6.3 gaps.
- **After Month 3:** Are >3 new services scaffolded and deployed? Is scaffolding repeatable in <30 min? If YES, move to production use. If NO, keep script maintenance as ongoing task.

---

## ADR candidates (architectural decision points)

1. **ADR: Secrets management approach** (SOPS vs Sealed Secrets vs external secret manager).
2. **ADR: GitOps layout** (single repo vs split repos; environment layering model).
3. **ADR: Manifest tooling** (Kustomize vs Helm-first vs mixed strategy).
4. **ADR: AuthN/AuthZ pattern** (OAuth provider vs Cloudflare Zero Trust; claim mapping).
5. **ADR: Registry standard** (GHCR vs Harbor, retention and vulnerability scanning).
6. **ADR: Observability stack scope** (Loki vs ELK; alerting toolchain depth).
7. **ADR: Promotion model** (auto-dev, gated staging/prod semantics).
8. **ADR: Multi-env branching strategy** (folder-based trunk vs branch-per-env).

---

## Sequencing risks and blockers

### Top blockers
- **Identity integration uncertainty:** Delaying OAuth/ZT decision will stall Argo CD RBAC hardening.
- **Secrets strategy churn:** Migrating from plaintext/adhoc secrets later is painful and risky.
- **GitOps structure indecision:** Reorganizing repo topology midstream creates migration overhead.
- **Over-automation too early:** Building full self-service before stable deploy standards adds rework.

### High-risk sequencing mistakes to avoid
1. Implementing self-service provisioning before deterministic CI/CD and promotion exists.
2. Building multi-env overlays before single-env reliability is proven.
3. Introducing ELK early (resource-heavy) before proving Loki is insufficient.
4. Delaying RBAC and admin disablement until after broad user access is granted.

---

## What NOT to build yet (anti-scope creep)

- Full internal developer portal platform (Backstage-class) before you have >5 services.
- Complex policy engines (OPA/Gatekeeper/Kyverno) until baseline RBAC/network policies are stable.
- Service mesh (Istio/Linkerd) unless you have concrete mTLS/traffic-splitting requirements.
- Multi-cluster federation before one cluster runs reliably for several weeks.
- Custom deployment controllers when Argo CD + Image Updater already solves current needs.

---

## Maturity model (Level 1 → Level 5)

### Level 1: Repeatable manual platform
- Cluster and Argo CD installed.
- App deployed via GitOps manually updated tags.
- Basic ingress auth and backups.

### Level 2: Secure baseline platform
- Argo admin disabled, RBAC enforced.
- JWT auth implemented; service account least privilege applied.
- Secrets encrypted in Git.

### Level 3: Automated delivery platform
- CI builds/tests/publishes immutable images.
- Auto image updates in dev; gated promotion to higher envs.
- Rollback playbook tested.

### Level 4: Observable and operable platform
- Metrics, logs, and release dashboards in place.
- Alerting for key failures.
- Incident/runbook workflows consistently used.

### Level 5: Productized internal platform
- Multi-environment promotion is routine.
- New service bootstrap is semi-self-service.
- Lightweight internal catalog/portal supports discoverability and operations.

---

## Early automation to reduce rework

Prioritize these automations as soon as baseline app deploy works:

1. **Template-driven manifests** (base app chart/overlay skeleton).
2. **CI reusable workflows** (shared build/test/publish jobs).
3. **Automated image bump PRs/commits for dev.**
4. **Secrets encryption/decryption workflow in CI and local tooling.**
5. **One-command environment bootstrap scripts** for new cluster/app namespaces.
6. **Release traceability links** (commit → image → deployment annotation).

These yield compounding benefits and reduce migration pain later.

---

## Suggested timeline (evenings/weekends realistic plan)

Assumption: ~8-12 hours/week.

- **Month 1:** Phase 0 + Phase 1 core (first end-to-end app live through Argo CD).
- **Month 2:** Phase 2 automation (CI, image promotion) + start Phase 3 decisions.
- **Month 3:** Complete Phase 3 security + Phase 4 observability baseline.
- **Month 4+:** Phase 5 only after at least 3-4 weeks of stable operations.

Practical checkpoint rule: do not advance phases unless current phase has at least one "fire drill" (rollback/recovery test) completed successfully.

---

## Architectural evolution diagram (textual)

### Stage A (Foundation)
Developer push → Git (infra/workloads repos) → Argo CD sync → K3s cluster resources.

### Stage B (Vertical slice)
User → Ingress → React frontend → FastAPI backend → PostgreSQL.

### Stage C (Automated delivery)
Developer push → CI build/test → image registry publish → image updater commit/PR → Argo CD sync.

### Stage D (Secure + observable platform)
Identity provider/Cloudflare ZT → ingress and Argo CD auth;
Prometheus/Grafana + Loki ingest telemetry from cluster/app;
Dashboards map deployment state to runtime health.

### Stage E (Platform product)
Project template automation creates repo/manifests/pipelines;
Multi-env promotion workflow governs dev → staging → prod;
Catalog view surfaces ownership, status, and operational links.
