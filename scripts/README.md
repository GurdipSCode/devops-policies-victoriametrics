# Scripts

Utility scripts for OPA VictoriaMetrics Standards.

## Available Scripts

### validate.sh
Runs all OPA tests and validation checks.

```bash
./validate.sh
```

Checks:
- ✅ OPA installation
- ✅ Policy syntax
- ✅ Test coverage (requires >80%)
- ✅ All tests pass

### test-rule.sh
Tests a specific VMRule or PrometheusRule file against all policies.

```bash
./test-rule.sh path/to/my-rule.yaml
```

Validates:
- Recording rule naming
- High cardinality detection
- Query performance
- Alert best practices

### check-cardinality.sh
Scans directory for high cardinality issues.

```bash
./check-cardinality.sh ../examples/
```

Detects:
- ❌ label_replace with pod_ip, node_ip, etc.
- ⚠️  by() clauses with high-cardinality labels
- ⚠️  Long lookback windows ([30d], [60d])
- ⚠️  Regex matchers with .*

### lint-rules.sh
Lints recording rule naming conventions.

```bash
./lint-rules.sh ../examples/
```

Validates format: `level:metric:operations`

Examples:
- ✅ namespace:http_requests:rate5m
- ❌ my_custom_metric

### generate-constraints.sh
Generates Gatekeeper ConstraintTemplates from OPA policies.

```bash
./generate-constraints.sh
```

Creates templates in `../examples/gatekeeper/`

### install.sh
Complete installation to Kubernetes cluster.

```bash
./install.sh
```

Steps:
1. Validates policies
2. Checks/installs Gatekeeper
3. Generates ConstraintTemplates
4. Deploys to cluster

## CI/CD Integration

### GitHub Actions

```yaml
- name: Validate OPA Policies
  run: |
    cd scripts
    ./validate.sh
```

### GitLab CI

```yaml
validate:
  script:
    - cd scripts
    - ./validate.sh
```

### Pre-commit Hook

```bash
#!/bin/bash
cd scripts
./validate.sh || exit 1
```

## Examples

### Validate before commit
```bash
./validate.sh
```

### Test new recording rule
```bash
./test-rule.sh my-new-rule.yaml
```

### Scan existing rules
```bash
./check-cardinality.sh /path/to/vmrules/
./lint-rules.sh /path/to/vmrules/
```

### Deploy to cluster
```bash
./install.sh
```
