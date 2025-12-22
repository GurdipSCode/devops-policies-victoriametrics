package kubernetes.admission.victoriametrics.queryperformance

import future.keywords.if

# METADATA
# title: Query Performance Validation
# description: Prevents expensive queries that hurt VictoriaMetrics performance
# severity: high
# category: victoriametrics
# version: 1.0.0

warning[{"msg": msg}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    rule := input.review.object.spec.groups[_].rules[_]
    
    # Check for very long lookback windows
    long_windows := ["[30d]", "[60d]", "[90d]"]
    window := long_windows[_]
    contains(rule.expr, window)
    
    msg := sprintf("Rule uses long lookback window %s - may cause performance issues", [window])
}

warning[{"msg": msg}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    rule := input.review.object.spec.groups[_].rules[_]
    
    # Warn about regex label matchers (expensive)
    contains(rule.expr, "=~")
    contains(rule.expr, ".*")
    
    msg := "Rule uses regex label matcher with .* - consider more specific patterns"
}

violation[{"msg": msg}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    rule := input.review.object.spec.groups[_].rules[_]
    rule.record
    
    # Recording rules should not use absent()
    contains(rule.expr, "absent(")
    
    msg := sprintf("Recording rule '%s' uses absent() - use alert rules for absence checks", [rule.record])
}
