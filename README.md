# OPA VictoriaMetrics Standards

[![OPA Tests](https://img.shields.io/badge/tests-passing-brightgreen)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

OPA policies that enforce VictoriaMetrics operational best practices and prevent common pitfalls.

## 🎯 Purpose

This repository contains OPA policies specifically designed for [VictoriaMetrics](https://victoriametrics.com/). These policies validate VMRule and PrometheusRule resources to ensure:

- Alert expressions are valid
- Recording rules follow naming conventions
- Queries don't cause performance issues
- Rules don't create high cardinality
- Best practices are followed

## 📋 Policies

### 1. Recording Rule Naming
Enforces naming convention: `level:metric:operations`
```
✅ namespace:http_requests:rate5m
❌ my_custom_metric
```

### 2. Alert Expression Validation
Validates PromQL/MetricsQL expressions:
- No syntax errors
- No overly complex queries
- Reasonable time ranges

### 3. High Cardinality Prevention
Prevents rules that create high cardinality:
- No recording rules with label_replace on high-cardinality labels
- No alerts with pod_ip, instance_ip, etc.

### 4. Query Performance
Warns about expensive queries:
- Queries with very long lookback windows
- Queries without rate() on counters
- Queries with regex label matchers on high-cardinality labels

### 5. Rule Group Configuration
Validates rule group settings:
- Reasonable evaluation intervals
- Proper group organization

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/your-org/opa-victoriametrics-standards.git
cd opa-victoriametrics-standards

# Run tests
opa test policies/ tests/ -v

# Deploy to Kubernetes
kubectl apply -f examples/gatekeeper/constraints.yaml
```

## 💡 Why These Policies?

### Prevent High Cardinality

**Without policies:**
```yaml
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMRule
spec:
  groups:
    - name: bad-recording-rules
      rules:
        - record: pod_cpu_usage_by_ip
          expr: |
            label_replace(
              container_cpu_usage,
              "pod_ip", "$1", "pod", ".*"
            )
          # ❌ Creates metric with pod_ip label = HIGH CARDINALITY!
```

**With policies:**
```yaml
# Blocked at admission with clear error:
# "Recording rule creates high-cardinality label: pod_ip"
```

### Enforce Naming Conventions

**Without policies:**
```yaml
- record: my_custom_cpu_metric  # ❌ No convention
- record: cpu_stuff              # ❌ Unclear
```

**With policies:**
```yaml
- record: namespace:container_cpu_usage:sum  # ✅ Clear hierarchy
- record: job:http_requests:rate5m           # ✅ Level:metric:operation
```

### Prevent Expensive Queries

**Without policies:**
```yaml
- alert: SlowQuery
  expr: |
    rate(http_requests_total{job=~".*"}[30d])  # ❌ 30 day range!
    / ignoring(instance) group_left
    sum without(instance) (rate(http_requests_total[30d]))
  # This will kill your Victoria Metrics!
```

**With policies:**
```yaml
# Blocked: "Query lookback window >7d may cause performance issues"
```

## 📖 Documentation

- [Policy Reference](docs/POLICIES.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Best Practices](docs/BEST_PRACTICES.md)

## 🔗 Integration

### With VictoriaMetrics Operator

These policies validate VMRule CRDs before they reach VM:

```
Developer creates VMRule
  ↓
OPA validates at admission
  ↓
✅ Valid → Applied to cluster
  ↓
VM Operator picks it up
  ↓
VictoriaMetrics uses rule
```

### With CI/CD

```bash
# Validate rules before deployment
opa eval -d policies/ -i vmrule.yaml \
  "data.kubernetes.admission.victoriametrics"
```

### With ArgoCD

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: opa-vm-policies
spec:
  source:
    repoURL: https://github.com/your-org/opa-victoriametrics-standards.git
    path: examples/gatekeeper
```

## 📊 Policy Comparison

| What | Unit Tests (promtool) | OPA Policies |
|------|----------------------|--------------|
| **When** | Before deployment | At admission time |
| **Tests** | Alert fires correctly | Rule structure valid |
| **Catches** | Wrong thresholds | Bad naming, high cardinality |
| **Tool** | promtool test rules | opa test |

**Both are needed!** Use promtool for logic testing, OPA for operational standards.

## 🎯 Real-World Impact

**Before OPA policies:**
- 🔴 Developer creates recording rule with pod_ip label
- 🔴 Deployed to VictoriaMetrics
- 🔴 Cardinality explodes from 10K to 500K series
- 🔴 VM runs out of memory
- 🔴 Incident! Manual cleanup needed

**After OPA policies:**
- ✅ Developer creates recording rule with pod_ip label
- ✅ OPA blocks at admission: "High cardinality label detected"
- ✅ Developer fixes rule
- ✅ No incident!

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## 📄 License

MIT License - see [LICENSE](LICENSE)

## 🙏 Acknowledgments

- [VictoriaMetrics](https://victoriametrics.com/)
- [Open Policy Agent](https://www.openpolicyagent.org/)

---

**Preventing VictoriaMetrics incidents, one policy at a time** 🛡️
