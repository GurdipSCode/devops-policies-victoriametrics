package kubernetes.admission.victoriametrics.cardinality

import future.keywords.if
import future.keywords.in

# METADATA
# title: High Cardinality Prevention
# description: Prevents creation of high-cardinality metrics
# severity: critical
# category: victoriametrics
# version: 1.0.0

high_cardinality_labels := {"pod_ip", "node_ip", "instance_ip", "pod_uid", "container_id"}

violation[{"msg": msg, "details": details}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    rule := input.review.object.spec.groups[_].rules[_]
    rule.record
    
    # Check for label_replace creating high-cardinality labels
    contains(rule.expr, "label_replace")
    label := high_cardinality_labels[_]
    contains(rule.expr, label)
    
    msg := sprintf("Recording rule '%s' creates high-cardinality label: %s", [rule.record, label])
    details := {
        "rule": rule.record,
        "cardinality_label": label,
        "impact": "This will create millions of time series and crash VictoriaMetrics"
    }
}

violation[{"msg": msg}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    rule := input.review.object.spec.groups[_].rules[_]
    
    # Warn about by() clauses with more than 10 labels
    contains(rule.expr, "by(")
    # This is a simplified check - in production you'd parse the expression
    label_count := count(array.slice(split(rule.expr, ","), 0, 15))
    label_count > 10
    
    msg := sprintf("Rule has >10 labels in by() clause - may cause high cardinality")
}
