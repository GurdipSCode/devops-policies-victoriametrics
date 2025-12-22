package kubernetes.admission.victoriametrics.alerts

import future.keywords.if

# METADATA
# title: Alert Best Practices
# description: Validates alert rules follow VictoriaMetrics best practices
# severity: medium
# category: victoriametrics
# version: 1.0.0

warning[{"msg": msg}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    rule := input.review.object.spec.groups[_].rules[_]
    rule.alert
    
    # Alert should have 'for' duration
    not rule.for
    
    msg := sprintf("Alert '%s' should have 'for' duration to avoid flapping", [rule.alert])
}

warning[{"msg": msg}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    rule := input.review.object.spec.groups[_].rules[_]
    rule.alert
    
    # Check for rate() without irate() consideration
    contains(rule.expr, "counter")
    not contains(rule.expr, "rate(")
    not contains(rule.expr, "irate(")
    
    msg := sprintf("Alert '%s' uses counter without rate() or irate()", [rule.alert])
}

violation[{"msg": msg}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    rule := input.review.object.spec.groups[_].rules[_]
    rule.alert
    
    # Alert expressions should not be too complex (simplified check)
    expr_length := count(rule.expr)
    expr_length > 500
    
    msg := sprintf("Alert '%s' expression is very long (%d chars) - consider splitting", [rule.alert, expr_length])
}
