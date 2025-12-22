#!/bin/bash
# Generate Gatekeeper ConstraintTemplates from OPA policies

echo "🔧 Generating Gatekeeper ConstraintTemplates"
echo "==========================================="
echo ""

OUTPUT_DIR="../examples/gatekeeper"
mkdir -p "$OUTPUT_DIR"

# Generate ConstraintTemplate for recording rule naming
cat > "$OUTPUT_DIR/template-recording-rule-naming.yaml" << 'TEMPLATE'
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8svmrecordingrulenaming
spec:
  crd:
    spec:
      names:
        kind: K8sVMRecordingRuleNaming
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
REGO_CONTENT
TEMPLATE

# Read the actual rego policy
REGO_POLICY=$(cat ../policies/recording-rule-naming.rego | sed 's/^/        /')

# Replace placeholder with actual rego
sed -i "s|REGO_CONTENT|$REGO_POLICY|" "$OUTPUT_DIR/template-recording-rule-naming.yaml"

echo "✅ Generated: template-recording-rule-naming.yaml"

# Generate ConstraintTemplate for high cardinality
cat > "$OUTPUT_DIR/template-high-cardinality.yaml" << 'TEMPLATE'
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8svmhighcardinality
spec:
  crd:
    spec:
      names:
        kind: K8sVMHighCardinality
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
REGO_CONTENT
TEMPLATE

REGO_POLICY=$(cat ../policies/high-cardinality.rego | sed 's/^/        /')
sed -i "s|REGO_CONTENT|$REGO_POLICY|" "$OUTPUT_DIR/template-high-cardinality.yaml"

echo "✅ Generated: template-high-cardinality.yaml"

# Generate ConstraintTemplate for query performance
cat > "$OUTPUT_DIR/template-query-performance.yaml" << 'TEMPLATE'
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8svmqueryperformance
spec:
  crd:
    spec:
      names:
        kind: K8sVMQueryPerformance
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
REGO_CONTENT
TEMPLATE

REGO_POLICY=$(cat ../policies/query-performance.rego | sed 's/^/        /')
sed -i "s|REGO_CONTENT|$REGO_POLICY|" "$OUTPUT_DIR/template-query-performance.yaml"

echo "✅ Generated: template-query-performance.yaml"

echo ""
echo "📦 ConstraintTemplates generated in: $OUTPUT_DIR"
echo ""
echo "Deploy with:"
echo "  kubectl apply -f $OUTPUT_DIR/template-*.yaml"
