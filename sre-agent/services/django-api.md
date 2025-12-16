# Service: django-api

## Overview
**Service Name:** django-api
**Type:** REST API Backend
**Runtime:** Python/Django
**Infrastructure:** AWS ECS Fargate

## Summary
The Django API is the primary backend service for the Hadrius platform. It handles all REST API requests, authentication, business logic, and database operations. It connects to PostgreSQL (RDS) and Redis (ElastiCache) for caching.

## Architecture

```
                    ┌─────────────┐
                    │   Route 53  │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │     ALB     │
                    │ (api.*)     │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
        ┌─────▼─────┐┌─────▼─────┐┌─────▼─────┐
        │  ECS Task ││  ECS Task ││  ECS Task │
        │ django-api││ django-api││ django-api│
        └─────┬─────┘└─────┬─────┘└─────┬─────┘
              │            │            │
              └────────────┼────────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
        ┌─────▼─────┐┌─────▼─────┐
        │    RDS    ││   Redis   │
        │ PostgreSQL││ElastiCache│
        └───────────┘└───────────┘
```

## AWS Resources

### ECS
- **Cluster:** hadrius-production
- **Service:** django-api
- **Task Definition:** django-api

### Load Balancer
- **ALB Name:** hadrius-api-alb
- **Target Group:** django-api-tg

### Database
- **RDS Instance:** hadrius-production-db
- **Engine:** PostgreSQL 15

### Cache
- **ElastiCache:** hadrius-redis

---

## Health Checks

### Primary Health Check
```bash
# Internal health endpoint
curl -s https://api.hadrius.com/health/

# Expected response: {"status": "healthy", "database": "ok", "cache": "ok"}
```

### Detailed Health Check
```bash
# Detailed health with dependencies
curl -s https://api.hadrius.com/health/detailed/
```

### ALB Health Check
```bash
# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn "arn:aws:elasticloadbalancing:us-east-2:ACCOUNT_ID:targetgroup/django-api-tg/XXXXX" \
  --profile hadrius-dev
```

---

## AWS CloudWatch Log Groups

### Application Logs
```bash
# Main application logs
LOG_GROUP="/ecs/django-api"

# Query recent errors (adjust time range as needed)
aws logs filter-log-events \
  --log-group-name "$LOG_GROUP" \
  --filter-pattern "ERROR" \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --profile hadrius-dev

# Query exceptions
aws logs filter-log-events \
  --log-group-name "$LOG_GROUP" \
  --filter-pattern "Exception" \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --profile hadrius-dev

# Query 5xx responses
aws logs filter-log-events \
  --log-group-name "$LOG_GROUP" \
  --filter-pattern '"status_code": 5' \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --profile hadrius-dev
```

### Access Logs
```bash
# ALB access logs (if enabled in S3)
LOG_GROUP="/aws/alb/hadrius-api"
```

---

## AWS CloudWatch Metrics

### ECS Metrics
```bash
# CPU Utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ClusterName,Value=hadrius-production Name=ServiceName,Value=django-api \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average Maximum \
  --profile hadrius-dev

# Memory Utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name MemoryUtilization \
  --dimensions Name=ClusterName,Value=hadrius-production Name=ServiceName,Value=django-api \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average Maximum \
  --profile hadrius-dev

# Running Task Count
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name RunningTaskCount \
  --dimensions Name=ClusterName,Value=hadrius-production Name=ServiceName,Value=django-api \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average \
  --profile hadrius-dev
```

### ALB Metrics
```bash
# Request Count
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancer,Value=app/hadrius-api-alb/XXXXX \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Sum \
  --profile hadrius-dev

# 5xx Errors
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HTTPCode_Target_5XX_Count \
  --dimensions Name=LoadBalancer,Value=app/hadrius-api-alb/XXXXX \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Sum \
  --profile hadrius-dev

# Target Response Time
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=app/hadrius-api-alb/XXXXX \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average p95 p99 \
  --profile hadrius-dev

# Healthy Host Count
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HealthyHostCount \
  --dimensions Name=LoadBalancer,Value=app/hadrius-api-alb/XXXXX Name=TargetGroup,Value=targetgroup/django-api-tg/XXXXX \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average \
  --profile hadrius-dev
```

### RDS Metrics
```bash
# Database Connections
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=hadrius-production-db \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average Maximum \
  --profile hadrius-dev

# CPU Utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=hadrius-production-db \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average Maximum \
  --profile hadrius-dev

# Read/Write Latency
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name ReadLatency \
  --dimensions Name=DBInstanceIdentifier,Value=hadrius-production-db \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average Maximum \
  --profile hadrius-dev
```

### Redis Metrics
```bash
# Cache Hit Rate
aws cloudwatch get-metric-statistics \
  --namespace AWS/ElastiCache \
  --metric-name CacheHitRate \
  --dimensions Name=CacheClusterId,Value=hadrius-redis \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average \
  --profile hadrius-dev

# Current Connections
aws cloudwatch get-metric-statistics \
  --namespace AWS/ElastiCache \
  --metric-name CurrConnections \
  --dimensions Name=CacheClusterId,Value=hadrius-redis \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average Maximum \
  --profile hadrius-dev
```

---

## ECS Commands

### Check Service Status
```bash
# Describe service
aws ecs describe-services \
  --cluster hadrius-production \
  --services django-api \
  --profile hadrius-dev

# List running tasks
aws ecs list-tasks \
  --cluster hadrius-production \
  --service-name django-api \
  --profile hadrius-dev

# Describe tasks (get task ARNs from above)
aws ecs describe-tasks \
  --cluster hadrius-production \
  --tasks TASK_ARN \
  --profile hadrius-dev
```

### Check Recent Deployments
```bash
# Service events (shows recent deployments and issues)
aws ecs describe-services \
  --cluster hadrius-production \
  --services django-api \
  --query 'services[0].events[:10]' \
  --profile hadrius-dev
```

### Force New Deployment (if needed)
```bash
# This will restart all tasks
aws ecs update-service \
  --cluster hadrius-production \
  --service django-api \
  --force-new-deployment \
  --profile hadrius-dev
```

---

## Common Issues & Debugging

### Issue: High 5xx Error Rate
**Symptoms:** Spike in 5xx errors, slow response times
**Check:**
1. ECS task health (are tasks crashing?)
2. RDS connections (connection pool exhaustion?)
3. Memory utilization (OOM kills?)
4. Recent deployments

### Issue: Database Connection Errors
**Symptoms:** "connection refused", "too many connections"
**Check:**
1. RDS DatabaseConnections metric
2. RDS CPU utilization
3. Security group rules
4. Connection pool settings in Django

### Issue: High Latency
**Symptoms:** Slow API responses, timeouts
**Check:**
1. RDS read/write latency
2. Redis cache hit rate
3. ECS CPU utilization
4. ALB target response time

### Issue: Tasks Keep Restarting
**Symptoms:** RunningTaskCount fluctuating, service events showing task stops
**Check:**
1. ECS service events
2. Task stopped reason
3. Container logs for OOM or crashes
4. Health check configuration

---

## Runbook Links
- [Django API Runbook](https://notion.so/hadrius/django-api-runbook)
- [Incident Response Playbook](https://notion.so/hadrius/incident-response)
- [On-Call Guide](https://notion.so/hadrius/on-call-guide)

---

## Contacts
- **Team:** Platform Engineering
- **Slack:** #platform-eng
- **PagerDuty:** Platform On-Call
