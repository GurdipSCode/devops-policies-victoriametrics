package kubernetes.admission.victoriametrics.recordingrules

import future.keywords.if

# METADATA
# title: Recording Rule Naming Convention
# description: Enforces level:metric:operations naming convention for recording rules
# severity: medium
# category: victoriametrics
# version: 1.0.0

violation[{"msg": msg, "details": details}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    rule := input.review.object.spec.groups[_].rules[_]
    rule.record
    
    # Check naming convention: level:metric:operations
    not regex.match(`^[a-z_]+:[a-z_]+:[a-z_0-9]+$`, rule.record)
    
    msg := sprintf("Recording rule '%s' must follow 'level:metric:operations' format", [rule.record])
    details := {
        "rule": rule.record,
        "format": "level:metric:operations",
        "examples": ["namespace:http_requests:rate5m", "job:cpu_usage:sum"]
    }
}

violation[{"msg": msg}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    rule := input.review.object.spec.groups[_].rules[_]
    rule.record
    
    # Recording rule names should not start with uppercase
    startswith(rule.record, upper(substring(rule.record, 0, 1)))
    
    msg := sprintf("Recording rule '%s' should not start with uppercase", [rule.record])
}
