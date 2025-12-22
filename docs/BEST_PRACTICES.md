# VictoriaMetrics Best Practices

## Recording Rule Naming

Always follow the `level:metric:operations` convention:

```yaml
# ✅ Good
- record: namespace:http_requests_total:rate5m
- record: job:cpu_usage_seconds:sum
- record: cluster:memory_usage_bytes:avg

# ❌ Bad
- record: my_custom_metric
- record: request_rate
- record: CPUUsage
```

## Avoid High Cardinality

Never create metrics with these labels:
- `pod_ip`
- `node_ip`
- `instance_ip`
- `pod_uid`
- `container_id`

```yaml
# ❌ DANGEROUS - Will explode cardinality
- record: pod_metrics_by_ip
  expr: |
    label_replace(
      container_cpu_usage,
      "pod_ip", "$1", "pod", ".*"
    )

# ✅ Good - Aggregate appropriately
- record: namespace:container_cpu_usage:sum
  expr: sum by (namespace) (container_cpu_usage)
```

## Query Performance

### Use Appropriate Time Ranges

```yaml
# ❌ Too long - will be slow
expr: rate(metric[30d])

# ✅ Good
expr: rate(metric[5m])
```

### Rate vs irate

```yaml
# For alerts - use rate() for stability
expr: rate(http_requests_total[5m]) > 100

# For dashboards - irate() is fine
expr: irate(http_requests_total[5m])
```

### Avoid Expensive Regex

```yaml
# ❌ Expensive
expr: metric{job=~".*"}

# ✅ Better - be specific
expr: metric{job=~"api-.*"}
```

## Rule Groups

Keep groups focused and manageable:

```yaml
# ✅ Good - organized by purpose
groups:
  - name: node-recording-rules
    interval: 30s
    rules:
      - record: node:cpu_usage:rate5m
        expr: ...
      
  - name: pod-recording-rules
    interval: 30s
    rules:
      - record: pod:memory_usage:sum
        expr: ...

# ❌ Bad - everything in one group
groups:
  - name: all-rules
    rules:
      # 100 different rules...
```

## For Alerts

### Always Use 'for' Duration

```yaml
# ✅ Good - prevents flapping
- alert: HighCPU
  expr: cpu > 80
  for: 5m  # Wait 5 minutes before firing

# ❌ Bad - will flap
- alert: HighCPU
  expr: cpu > 80
```

### Use rate() on Counters

```yaml
# ✅ Good
- alert: HighErrorRate
  expr: rate(http_errors_total[5m]) > 1

# ❌ Bad
- alert: HighErrorRate
  expr: http_errors_total > 100
```
