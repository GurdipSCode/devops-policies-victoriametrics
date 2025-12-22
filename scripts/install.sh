#!/bin/bash
# Install OPA VictoriaMetrics Standards to Kubernetes cluster

set -e

echo "🚀 Installing OPA VictoriaMetrics Standards"
echo "=========================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found"
    exit 1
fi
echo "✅ kubectl found"

if ! command -v opa &> /dev/null; then
    echo "❌ OPA not found"
    echo "Install: curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64"
    exit 1
fi
echo "✅ OPA found"

# Run validation
echo ""
echo "Running validation..."
./validate.sh

# Check if Gatekeeper is installed
echo ""
echo "Checking for OPA Gatekeeper..."
if ! kubectl get deployment -n gatekeeper-system gatekeeper-controller-manager &> /dev/null; then
    echo "❌ Gatekeeper not installed"
    echo ""
    read -p "Install Gatekeeper now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
        echo "⏳ Waiting for Gatekeeper to be ready..."
        kubectl wait --for=condition=Ready pod -l control-plane=controller-manager -n gatekeeper-system --timeout=120s
        echo "✅ Gatekeeper installed"
    else
        echo "Skipping Gatekeeper installation"
        exit 0
    fi
else
    echo "✅ Gatekeeper found"
fi

# Generate ConstraintTemplates
echo ""
echo "Generating ConstraintTemplates..."
./generate-constraints.sh

# Deploy ConstraintTemplates
echo ""
echo "Deploying ConstraintTemplates..."
kubectl apply -f ../examples/gatekeeper/template-*.yaml

echo ""
echo "Waiting for ConstraintTemplates to be ready..."
sleep 5

# Deploy Constraints
echo ""
echo "Deploying Constraints..."
kubectl apply -f ../examples/gatekeeper/constraints.yaml

echo ""
echo "✅ Installation complete!"
echo ""
echo "Check status:"
echo "  kubectl get constrainttemplates"
echo "  kubectl get constraints"
echo ""
echo "Test with:"
echo "  kubectl apply -f your-vmrule.yaml"
