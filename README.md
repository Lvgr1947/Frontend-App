# Frontend App – DevOps CI/CD & Infrastructure Setup

This repository presents a **DevOps solution** for deploying a simple static frontend login application using a full CI/CD workflow, infrastructure as code, Kubernetes orchestration, and monitoring.

---

## Tech Stack Overview

| Layer            | Tools / Services                              |
| ---------------- | --------------------------------------------- |
| CI/CD            | GitHub Actions (Self-hosted + GitHub runners) |
| Containerization | Docker                                        |
| Cloud Infra      | AWS (EC2 via Terraform)                       |
| Orchestration    | Kubernetes (K3s lightweight cluster)          |
| Monitoring       | Prometheus + Grafana                          |
| Ingress & TLS    | NGINX Ingress + cert-manager + Let's Encrypt  |
| Secrets          | GitHub Encrypted Secrets                      |
| Environments     | Staging + Production via Namespaces           |

---

## High-Level Infrastructure Overview

```
                                 ┌────────────────────────────┐
                                 │        GitHub Repo         │
                                 │  (Code + Workflows + YAML) │
                                 └────────────┬───────────────┘
                                              │ GitHub Actions
                            ┌─────────────────▼────────────────┐
                            │       Self-hosted EC2 Runner     │
                            │      (t3.xlarge - Terraform)     │
                            └────────────┬────────────┬────────┘
                                         │            │
              ┌──────────────────────────▼─┐      ┌────▼────────────────┐
              │      K3s Kubernetes Node   │      │      Docker Hub     │
              │     (Deployed via SSH)     │      │  Image Registry     │
              └────────────┬───────────────┘      └─────────────────────┘
                           │
      ┌────────────────────┼────────────────────┐
      │                    │                    │
┌─────▼─────┐      ┌───────▼──────┐     ┌───────▼───────┐
│ Staging NS│      │ Production NS│     │ Monitoring NS │
└────┬──────┘      └───────┬──────┘     └───────┬───────┘
     │                      │                      │
┌────▼─────┐         ┌──────▼────┐          ┌─────▼──────┐
│App Deploy│         │App Deploy │          │ Prometheus │
│+Service  │         │+Service   │          │  Grafana   │
└──────────┘         └───────────┘          └────────────┘
     │                      │                      │
     └────Ingress + TLS─────┴────────Ingress───────┘
               venudev.duckdns.org

```

## CI/CD Pipeline Flow

```
[Code Push] --> GitHub Actions
                 |
                 ├── Lint HTML + K8s YAML
                 ├── Build Docker Image (staging/production)
                 ├── Push to Docker Hub
                 ├── Deploy to EC2 via SSH
                 │     ├── kubectl apply -f k8s/staging/
                 │     ├── kubectl apply -f k8s/production/
                 │     └── kubectl apply -f k8s/monitoring/
                 └── Integration Tests on Staging

```

## Folder Structure

```
.
├── app/
│   └── frontend/
│       ├── index.html                # UI for login form
│       ├── staging/                 # HTML for staging linter
│       ├── production/              # HTML for prod linter
│       └── Dockerfile               # Docker setup
├── k8s/
│   ├── staging/                     # Namespace, Deploy, Service, HPA, Ingress
│   ├── production/                  # Prod K8s resources + security + quotas
│   └── monitoring/                  # Prometheus and Grafana (if used)
├── terraform/
│   └── main.tf                      # EC2, Key Pair, Security Group
├── .github/
│   └── workflows/
│       └── ci-cd.yaml               # Complete CI/CD workflow
├── scripts/
│   └── test_endpoints.sh           # Integration testing script
```

---

## Infrastructure Provisioning (Terraform)

* Provision a `t3.xlarge` Ubuntu EC2 instance in `ap-south-1`
* Configure Security Group to allow SSH (22) and HTTP (80)
* Import Key Pair for SSH access to EC2
* Single-node cluster used for K3s setup and hosting all services

```sh
cd terraform
terraform init
terraform apply
```

---

## Docker Containerization

A minimal `Dockerfile` is used with the base image `nginx:alpine`, copying the static HTML page to the default nginx web root:

```Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

---

## Kubernetes (K3s) Setup

* K3s manually installed on provisioned EC2
* Ingress-NGINX installed via Helm
* MetalLB configured to expose ingress IP
* cert-manager + Let's Encrypt ClusterIssuer for TLS
* Namespaces `staging` and `prod` to separate environments

### Production namespace enhancements:

* PodDisruptionBudget for HA
* ResourceQuota for resource governance
* NetworkPolicy to limit ingress traffic

---

## CI/CD Pipeline (GitHub Actions)

### Trigger

* On push to `main` or `develop`
* Manual dispatch available

### Stages

| Stage               | Description                                      |
| ------------------- | ------------------------------------------------ |
| `validate-yaml`     | Run kubeconform to check all YAMLs               |
| `lint`              | Use `tidy` to lint `index.html` in both envs     |
| `build`             | Build and push Docker image for staging/prod     |
| `deploy_staging`    | SSH into EC2 and deploy staging manifests        |
| `integration_tests` | Run basic endpoint health check via shell script |
| `deploy_production` | SSH into EC2 and apply production manifests      |

---

## Secrets Managed in GitHub

| Secret Name       | Usage                         |
| ----------------- | ----------------------------- |
| `DOCKER_USERNAME` | For Docker Hub login          |
| `DOCKER_PASSWORD` | For Docker Hub login          |
| `EC2_HOST`        | Public IP of EC2 instance     |
| `EC2_SSH_KEY`     | SSH private key in PEM format |
| `STAGING_APP_URL` | Used for integration testing  |

---

## Ingress + TLS Setup

The following routes are set up using `Ingress` and TLS managed via cert-manager:

* `https://venudev.duckdns.org/staging` → Staging Environment
* `https://venudev.duckdns.org/` → Production Environment
* `https://venudev.duckdns.org/grafana` → Grafana (Monitoring)
* `https://venudev.duckdns.org/prometheus` → Prometheus (Monitoring)

TLS certs are issued via Let's Encrypt using appropriate annotations.

---

## Monitoring (Helm Deployed)

* **Prometheus** scrapes metrics from K8s + nodes
* **Grafana** exposes dashboard via Ingress
* Monitoring stack deployed using official Helm charts
* Accessible via `/grafana` and `/prometheus` paths

---

## Bonus Features Implemented

* Full CI/CD with environment-based deployments
* Staging + Production environments (namespaces)
* HPA for auto-scaling both deployments
* TLS + ingress rewrite + rate limiting
* PDB, ResourceQuota, NetworkPolicy in production
* GitHub Secrets used instead of plaintext vars
* Basic integration testing via shell script
* Docker images tagged by environment & pushed

---

## Loom Walkthrough

**Loom Video Link:** *To be added after recording*


---

## Author

**Venu Gopal**
DevOps Engineer

---

