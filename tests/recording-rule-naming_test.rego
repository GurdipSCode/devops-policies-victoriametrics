package kubernetes.admission.victoriametrics.recordingrules

test_bad_naming_denied {
    input := {"review": {"kind": {"kind": "VMRule"}, "object": {"spec": {"groups": [{"name": "test", "rules": [{"record": "my_custom_metric"}]}]}}}}
    count(violation) > 0
}

test_good_naming_allowed {
    input := {"review": {"kind": {"kind": "VMRule"}, "object": {"spec": {"groups": [{"name": "test", "rules": [{"record": "namespace:http_requests:rate5m"}]}]}}}}
    count(violation) == 0
}

test_uppercase_denied {
    input := {"review": {"kind": {"kind": "VMRule"}, "object": {"spec": {"groups": [{"name": "test", "rules": [{"record": "MyMetric:test:sum"}]}]}}}}
    count(violation) > 0
}
