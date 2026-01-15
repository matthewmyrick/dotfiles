# Project Guidelines for Claude

## Critical Rules

### Git Operations
- **NEVER** run `git push` unless explicitly told to do so
- **NEVER** run `git push --force` or any force push variants
- **NEVER** amend commits that have been pushed to remote
- Always show git commands before executing and wait for approval on destructive operations

### AWS / Infrastructure
- **NEVER** run AWS commands that alter infrastructure unless explicitly told to do so
- This includes but is not limited to:
  - `aws ec2 terminate-instances`
  - `aws rds delete-db-instance`
  - `aws s3 rm` (especially with `--recursive`)
  - `aws cloudformation delete-stack`
  - `terraform apply` or `terraform destroy`
  - `kubectl delete`
  - Any `--force` or `--no-wait` flags on destructive commands
- Read-only AWS commands (describe, list, get) are allowed
- Always confirm before making any infrastructure changes

### Database Operations
- **NEVER** run `DROP`, `TRUNCATE`, or `DELETE` without `WHERE` clause unless explicitly approved
- Always use transactions for data modifications when possible
- Prefer `SELECT` queries first to verify what will be affected

## Allowed Operations
- Reading files and exploring the codebase
- Running tests
- Running builds
- Read-only AWS/infrastructure commands
- Local development operations

## When in Doubt
If you're unsure whether an operation is safe, **ask first**. It's better to confirm than to cause unintended changes.
