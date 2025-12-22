#!/bin/bash
# Test a specific VMRule or PrometheusRule against OPA policies

if [ -z "$1" ]; then
    echo "Usage: $0 <rule-file.yaml>"
    echo ""
    echo "Example:"
    echo "  $0 my-recording-rule.yaml"
    exit 1
fi

RULE_FILE="$1"

if [ ! -f "$RULE_FILE" ]; then
    echo "❌ File not found: $RULE_FILE"
    exit 1
fi

echo "🧪 Testing rule: $RULE_FILE"
echo "=============================="
echo ""

# Check if OPA is installed
if ! command -v opa &> /dev/null; then
    echo "❌ OPA not installed"
    exit 1
fi

# Create test input
cat > /tmp/test-input.json << TESTEOF
{
  "review": {
    "kind": {
      "kind": "VMRule"
    },
    "object": $(cat "$RULE_FILE" | yq eval -o=json)
  }
}
TESTEOF

echo "Testing recording rule naming..."
opa eval -d ../policies/recording-rule-naming.rego \
  -i /tmp/test-input.json \
  "data.kubernetes.admission.victoriametrics.recordingrules.violation" \
  --format pretty

echo ""
echo "Testing high cardinality..."
opa eval -d ../policies/high-cardinality.rego \
  -i /tmp/test-input.json \
  "data.kubernetes.admission.victoriametrics.cardinality.violation" \
  --format pretty

echo ""
echo "Testing query performance..."
opa eval -d ../policies/query-performance.rego \
  -i /tmp/test-input.json \
  "data.kubernetes.admission.victoriametrics.queryperformance.warning" \
  --format pretty

echo ""
echo "Testing alert best practices..."
opa eval -d ../policies/alert-best-practices.rego \
  -i /tmp/test-input.json \
  "data.kubernetes.admission.victoriametrics.alerts.warning" \
  --format pretty

rm /tmp/test-input.json

echo ""
echo "✅ Test complete"
