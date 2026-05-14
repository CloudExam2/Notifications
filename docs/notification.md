📄 README.md (Notification Service)

## AWS student lab constraint

**Outbound internet from workloads:** Student lab accounts often **do not allow** application instances to reach the **public internet** for arbitrary traffic (generic HTTP/HTTPS egress, public package indexes, Docker Hub at runtime, etc.). Treat the lab as **private-by-default**: use **VPC endpoints** (or other AWS-documented private integration) for **ECR, SSM, S3, SQS**, and similar, unless your instructor explicitly permits open egress.

**Internet / API Gateway:** Core provisions a **VPC with Internet Gateway** and a **regional API Gateway** (`gateway.tf`). See **Core** `docs/core.md` and **`docs/bootstrap-lab.md`** for setup order.

---

This repository contains the Notification Service, a worker module responsible for receiving sale events, generating/storing sale documents, and dispatching notifications. It integrates storage and messaging services to ensure reliable delivery of sales notes.
🏗️ Architecture & 12-Factor Compliance

    Codebase (Factor I): Single repository for the notification and document generation logic.

    Config (Factor III): All environmental parameters (Bucket names, SNS ARNs, DB credentials) are injected at runtime.

    Backing Services (Factor IV): S3 (Storage), SNS (Messaging), and RDS (Audit) are treated as attached resources.

    Statelessness (Factor VI): The service is stateless. All persistent files are stored in S3, and metadata is stored in RDS.

    Logs (Factor XI): No internal metric or logging frameworks. The application writes to stdout for external aggregation by the Core infrastructure.

🛠️ Infrastructure (Terraform)

This service manages its own dedicated resource stack via Terraform:

    Networking: Dedicated VPC/Subnets and Security Groups to isolate the worker and database.

    Compute (EC2): A dedicated instance (or Lambda) running the Dockerized worker that listens to the Sales SQS queue.

    Persistence (RDS): A private PostgreSQL instance to track notification status and prevent duplicate sends.

    Storage (S3): A dedicated bucket used to store the PDF versions of Sale Notes for archival and retrieval.

    Messaging (SNS): An SNS Topic used to decouple the "Event Received" state from the "Email Sent" state, allowing for reliable delivery.

🚀 CI/CD & Docker

    Containerization: The application is packaged as a Docker image.

    Pipeline (GitHub Actions):

        Build: Triggers on push to main.

        Publish: Automatically pushes the image to Amazon ECR.

        Deploy: Updates the compute environment (EC2 or Lambda) to pull and run the latest image.

📂 Project Structure
Plaintext

.
├── .github/workflows/  # CI/CD (Build -> ECR -> Deploy)
├── terraform/          # Infrastructure (EC2, RDS, S3, SNS, Network)
├── src/
│   ├── processor.py    # SQS Listener & PDF generation logic
│   ├── storage.py      # S3 Upload/Download logic
│   └── notifier.py     # SNS & Email dispatch logic
├── Dockerfile          # Container definition
└── requirements.txt    # Python dependencies

📄 environment.md (Notification Service)

These variables must be configured in the GitHub Secrets or the local environment to allow the service to interact with AWS resources.
Variable	Description	Source
DATABASE_URL	Connection string for the Notification RDS.	Terraform Output
S3_BUCKET_NAME	Name of the bucket for storing PDFs.	Terraform Output
SNS_TOPIC_ARN	ARN of the SNS Topic for notifications.	Terraform Output
SQS_NOTIFY_URL	URL of the queue to consume sales events.	Global Infra Output
AWS_REGION	Target region (us-east-1).	Static
SMTP_HOST	Host for the email provider.	Manual Config
Required Secrets (GitHub Secrets)

    DB_PASSWORD: Master password for the Notification RDS.

    SMTP_USER / SMTP_PASS: Credentials for sending the PDF by mail.

    AWS_ACCESS_KEY_ID / SECRET: Credentials for ECR, S3, and SNS access.