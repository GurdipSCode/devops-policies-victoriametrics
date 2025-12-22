package kubernetes.admission.victoriametrics.cardinality

test_pod_ip_label_denied {
    input := {"review": {"kind": {"kind": "VMRule"}, "object": {"spec": {"groups": [{"name": "test", "rules": [{"record": "test:metric:sum", "expr": "label_replace(metric, \"pod_ip\", \"$1\", \"pod\", \".*)"}]}]}}}}
    count(violation) > 0
}

test_normal_recording_rule_allowed {
    input := {"review": {"kind": {"kind": "VMRule"}, "object": {"spec": {"groups": [{"name": "test", "rules": [{"record": "namespace:requests:rate5m", "expr": "sum by (namespace) (rate(requests[5m]))"}]}]}}}}
    count(violation) == 0
}
