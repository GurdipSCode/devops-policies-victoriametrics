#!/bin/bash
# Lint recording rule naming conventions

echo "📝 Linting Recording Rule Names"
echo "================================"
echo ""

if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    echo ""
    echo "Example:"
    echo "  $0 ../examples/"
    exit 1
fi

DIR="$1"
ERRORS=0

# Expected format: level:metric:operations
NAMING_REGEX='^[a-z_]+:[a-z_]+:[a-z_0-9]+$'

# Find all YAML files and extract recording rules
for file in $(find "$DIR" -name "*.yaml" -o -name "*.yml"); do
    echo "Checking: $file"
    
    # Extract recording rule names (simplified - looks for "record:" lines)
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*record:[[:space:]]*[\"\'']?([a-zA-Z0-9_:]+)[\"\'']? ]]; then
            rule_name="${BASH_REMATCH[1]}"
            
            # Check naming convention
            if [[ ! $rule_name =~ $NAMING_REGEX ]]; then
                echo "  ❌ BAD: '$rule_name'"
                echo "     Should follow format: level:metric:operations"
                echo "     Example: namespace:http_requests:rate5m"
                ERRORS=$((ERRORS + 1))
            else
                echo "  ✅ GOOD: '$rule_name'"
            fi
        fi
    done < "$file"
done

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ All recording rules follow naming convention"
else
    echo "❌ Found $ERRORS naming violations"
    exit 1
fi
