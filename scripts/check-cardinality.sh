#!/bin/bash
# Check VMRule files for high cardinality issues

echo "🔍 Checking for High Cardinality Issues"
echo "========================================"
echo ""

HIGH_CARDINALITY_LABELS=("pod_ip" "node_ip" "instance_ip" "pod_uid" "container_id")

if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    echo ""
    echo "Example:"
    echo "  $0 ../examples/"
    exit 1
fi

DIR="$1"
FOUND_ISSUES=0

# Find all YAML files
for file in $(find "$DIR" -name "*.yaml" -o -name "*.yml"); do
    echo "Checking: $file"
    
    # Check for label_replace with high cardinality labels
    for label in "${HIGH_CARDINALITY_LABELS[@]}"; do
        if grep -q "label_replace.*$label" "$file"; then
            echo "  ❌ CRITICAL: Found label_replace with high-cardinality label: $label"
            echo "     This will explode your time series count!"
            FOUND_ISSUES=$((FOUND_ISSUES + 1))
        fi
    done
    
    # Check for direct use of high cardinality labels in by() clauses
    for label in "${HIGH_CARDINALITY_LABELS[@]}"; do
        if grep -q "by.*$label" "$file"; then
            echo "  ⚠️  WARNING: Found by() clause with potentially high-cardinality label: $label"
            FOUND_ISSUES=$((FOUND_ISSUES + 1))
        fi
    done
    
    # Check for very long lookback windows
    if grep -q '\[30d\]\|\[60d\]\|\[90d\]' "$file"; then
        echo "  ⚠️  WARNING: Found long lookback window (30d/60d/90d)"
        echo "     This may cause performance issues"
        FOUND_ISSUES=$((FOUND_ISSUES + 1))
    fi
    
    # Check for regex with .*
    if grep -q '=~.*\.\*' "$file"; then
        echo "  ⚠️  WARNING: Found regex label matcher with .*"
        echo "     Consider more specific patterns"
        FOUND_ISSUES=$((FOUND_ISSUES + 1))
    fi
done

echo ""
if [ $FOUND_ISSUES -eq 0 ]; then
    echo "✅ No cardinality issues found"
else
    echo "⚠️  Found $FOUND_ISSUES potential issues"
    exit 1
fi
