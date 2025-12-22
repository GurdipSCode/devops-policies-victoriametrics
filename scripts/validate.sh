#!/bin/bash
set -e

echo "🔍 Validating OPA VictoriaMetrics Policies"
echo "=========================================="
echo ""

# Check OPA installed
if ! command -v opa &> /dev/null; then
    echo "❌ OPA not installed"
    echo "Install: curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64"
    exit 1
fi

echo "✓ OPA installed: $(opa version | head -1)"
echo ""

# Run tests
echo "Running policy tests..."
opa test ../policies/ ../tests/ -v

# Check syntax
echo ""
echo "Checking policy syntax..."
opa check ../policies/

# Generate coverage
echo ""
echo "Generating coverage report..."
opa test ../policies/ ../tests/ --coverage --format=json > coverage.json
coverage=$(jq -r '.coverage' coverage.json)
echo "✓ Coverage: $coverage%"

if (( $(echo "$coverage < 80" | bc -l) )); then
    echo "⚠️  Coverage below 80%"
    exit 1
fi

echo ""
echo "✅ All validations passed!"
