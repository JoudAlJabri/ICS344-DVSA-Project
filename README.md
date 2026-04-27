# DVSA Vulnerability Discovery and Remediation

**ICS-344: Information Security — Course Project (Term 252)**
King Fahd University of Petroleum and Minerals (KFUPM)

## Overview

This repository contains the deliverables for the ICS-344 course project on the **OWASP Damn Vulnerable Serverless Application (DVSA)**. The project covers the discovery, exploitation, documentation, and remediation of 10 official serverless security vulnerabilities (plus bonus findings) in an AWS-based environment using S3, API Gateway, Lambda, DynamoDB, IAM, and Cognito.

## Team

| Name | Student ID |
|------|-----------|
| Joud Aljabri | 202277140 |
| Khawlah Almalki | 202247320 |

- **AWS Region:** `us-east-1`
- **DVSA Website URL:** http://dvsa-joud-2026-448842988219-us-east-1.s3-website.us-east-1.amazonaws.com/

## Repository Structure

```
.
├── README.md
├── report/                  # Final PDF report
├── slides/                  # Presentation slides
├── demo/                    # Demo video (or link)
├── lessons/
│   ├── 01-event-injection/
│   ├── 02-broken-authentication/
│   ├── 03-sensitive-data-exposure/
│   ├── 04-insecure-cloud-config/
│   ├── 05-broken-access-control/
│   ├── 06-denial-of-service/
│   ├── 07-over-privileged-functions/
│   ├── 08-logic-vulnerabilities/
│   ├── 09-vulnerable-dependencies/
│   └── 10-unhandled-exceptions/
├── bonus/                   # Additional/undocumented vulnerabilities
├── scripts/                 # Helper scripts (curl, python3, jq)
├── fixes/                   # Patched Lambda code & IAM policies
└── evidence/                # Screenshots, logs, CloudTrail exports
```

Each `lessons/<lesson>/` folder contains:
- `README.md` — the 10-part write-up (summary, root cause, setup, repro, evidence, fix, verification, structured analysis tables, takeaway)
- `exploit/` — payloads and reproduction scripts
- `fix/` — code/config diff and patched files
- `screenshots/` — proof-of-exploit and post-fix evidence

## Vulnerabilities Covered

| # | Lesson | Component | Status |
|---|--------|-----------|--------|
| 1 | Event Injection | Lambda / API Gateway | ✅ |
| 2 | Broken Authentication | JWT / Cognito | ✅ |
| 3 | Sensitive Data Exposure | S3 / Receipts | ✅ |
| 4 | Insecure Cloud Configuration | S3 Bucket Policy | ✅ |
| 5 | Broken Access Control | Admin Lambda | ✅ |
| 6 | Denial of Service | API Gateway / Lambda | ✅ |
| 7 | Over-Privileged Functions | IAM Role | ✅ |
| 8 | Logic Vulnerabilities | Order Workflow | ✅ |
| 9 | Vulnerable Dependencies | `node-serialize` | ✅ |
| 10 | Unhandled Exceptions | Error Handling | ✅ |

Bonus findings are documented in `bonus/`.

## Prerequisites

- A dedicated **non-production AWS account**
- Region set to `us-east-1`
- Local tools:
  - AWS CLI v2
  - `curl`
  - `jq`
  - `python3`

```bash
sudo apt update
sudo apt install -y unzip curl jq python3
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp && sudo /tmp/aws/install
aws --version
```

## Deployment

1. Open AWS Console → **Serverless Application Repository**
2. Search for **OWASP DVSA** (enable *Show apps that create custom IAM roles or resource policies*)
3. Provide:
   - `AdminEmail` — a real email you control
   - `WebsiteBucketPrefix` — globally unique (e.g. `dvsa-joud-2026`)
4. Acknowledge IAM capabilities and click **Deploy**
5. After deployment, copy the `WebsiteURL` from the CloudFormation **Outputs** tab

Verify by registering a user, logging in, and placing a test order.

## Reproducing a Vulnerability

Each lesson folder is self-contained. Example for Lesson #2:

```bash
cd lessons/02-broken-authentication
# Set your environment
export API="https://<api-id>.execute-api.us-east-1.amazonaws.com/Stage/order"
export TOKEN_B="<attacker JWT>"
export VICTIM_USER="<victim username/sub>"
# Run exploit
bash exploit/forge_token.sh
# Apply fix
bash fix/apply.sh
# Verify
bash exploit/forge_token.sh   # should now return 401
```

## Applying Fixes

Patched code lives in `fixes/`. To apply, open the corresponding Lambda in the AWS Console, paste the updated source from `fixes/<function-name>/`, and click **Deploy**. IAM policy changes are provided as JSON files to attach via the IAM Console.

## Evidence & Logs

- **CloudWatch Logs** (`/aws/lambda/<function>`) — runtime evidence of exploits and post-fix behavior
- **CloudTrail** — used in Lesson #7 for least-privilege policy generation
- **IAM Policy Simulator** — blast-radius testing for over-privileged roles

Screenshots are stored under each lesson's `screenshots/` directory and referenced from the report.

## Security & Academic Integrity

- No real AWS keys, JWTs, passwords, or session credentials are committed to this repo. All sensitive values in screenshots and logs are redacted.
- This work is the team's own. Use of AI tools was limited to clarification, organization, and debugging support; all technical content is understood and verifiable by the team.
- DVSA and this project are for **educational use only** within ICS-344. Unauthorized use, redistribution, or malicious application is prohibited.

## References

- OWASP DVSA: https://owasp.org/www-project-dvsa/
- DVSA GitHub: https://github.com/OWASP/DVSA
- AWS Lambda Docs: https://docs.aws.amazon.com/lambda/

## License

Educational use only — KFUPM ICS-344, Term 252. See course project description for full copyright and usage notice.
