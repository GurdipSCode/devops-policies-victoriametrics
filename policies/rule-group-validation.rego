package kubernetes.admission.victoriametrics.rulegroups

import future.keywords.if

# METADATA
# title: Rule Group Validation
# description: Validates rule group configuration
# severity: low
# category: victoriametrics
# version: 1.0.0

warning[{"msg": msg}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    group := input.review.object.spec.groups[_]
    
    # Check evaluation interval
    interval := group.interval
    interval != ""
    
    # Parse interval (simplified - assumes format like "30s", "1m")
    seconds := parse_interval_to_seconds(interval)
    seconds < 10
    
    msg := sprintf("Group '%s' has very short interval %s - may cause high load", [group.name, interval])
}

warning[{"msg": msg}] if {
    input.review.kind.kind in {"VMRule", "PrometheusRule"}
    group := input.review.object.spec.groups[_]
    
    # Groups should have reasonable number of rules
    rule_count := count(group.rules)
    rule_count > 50
    
    msg := sprintf("Group '%s' has %d rules - consider splitting for better manageability", [group.name, rule_count])
}

parse_interval_to_seconds(interval) := seconds if {
    endswith(interval, "s")
    seconds := to_number(trim_suffix(interval, "s"))
}

parse_interval_to_seconds(interval) := seconds if {
    endswith(interval, "m")
    minutes := to_number(trim_suffix(interval, "m"))
    seconds := minutes * 60
}
