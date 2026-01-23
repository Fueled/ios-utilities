#!/bin/bash

# Swift-DocC Documentation Generation Script
# This script generates API documentation for all products in the package using Swift-DocC.

set -e  # Exit on error

# Define color codes for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
DOCS_DIR="./docs"
HOSTING_BASE_PATH="ios-utilities"

# Check if jq is installed (required for parsing Package.swift)
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    echo "Install it with: brew install jq"
    exit 1
fi

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo -e "${RED}Error: Swift is not available.${NC}"
    exit 1
fi

echo -e "${BLUE}📚 Generating Swift-DocC documentation...${NC}"
echo ""

# Function to get all products from Package.swift
get_products() {
    local products
    products=$(swift package dump-package | jq -r '
    . as $data |
    $data.targets[]
    | select(.type == "regular" and 
            any($data.products[]; .targets | index(.)))
    | .name
    ')

    if [ -z "$products" ]; then
        echo -e "${RED}Error: No products found in Package.swift${NC}" >&2
        exit 1
    fi

    echo "$products"
}

# Function to generate an enhanced index.html file
generate_index_file() {
    echo -e "${BLUE}📄 Generating index.html file...${NC}"

    # Create the HTML file with enhanced styling and metadata
    cat > "$DOCS_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="FueledUtils API Documentation - A collection of utilities for iOS development">
    <title>FueledUtils API Documentation</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            max-width: 900px;
            margin: 0 auto;
            padding: 40px 20px;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            color: #333;
        }
        .container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            padding: 40px;
        }
        h1 {
            color: #0366d6;
            border-bottom: 3px solid #0366d6;
            padding-bottom: 15px;
            margin-bottom: 30px;
            font-size: 2.5em;
        }
        .description {
            color: #666;
            margin-bottom: 30px;
            font-size: 1.1em;
            line-height: 1.6;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin: 12px 0;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        li:hover {
            transform: translateX(5px);
        }
        a {
            color: #0366d6;
            text-decoration: none;
            font-size: 18px;
            display: block;
            padding: 15px 20px;
            border-radius: 8px;
            background: #f8f9fa;
            border-left: 4px solid #0366d6;
            transition: background-color 0.3s, border-color 0.3s;
        }
        a:hover {
            background-color: #e6f7ff;
            border-left-color: #0056b3;
            text-decoration: none;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #e1e4e8;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
        .footer a {
            display: inline;
            padding: 0;
            background: none;
            border: none;
            color: #0366d6;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📚 FueledUtils Documentation</h1>
        <p class="description">
            Welcome to the FueledUtils API documentation. Select a module below to explore its APIs, 
            types, and utilities for iOS development.
        </p>
    <ul>
EOF

    # Get the products and loop through them to create links
    local products
    products=$(get_products)
    local count=0
    
    for product in $products; do
        local lowercase_product
        lowercase_product=$(echo "$product" | tr '[:upper:]' '[:lower:]')
        echo "            <li><a href='./documentation/$lowercase_product/'>$product</a></li>" >> "$DOCS_DIR/index.html"
        ((count++))
    done

    # Closing the HTML tags
    cat >> "$DOCS_DIR/index.html" << EOF
    </ul>
        <div class="footer">
            <p>Generated with Swift-DocC • <a href="https://github.com/Fueled/ios-utilities">View on GitHub</a></p>
            <p>Last updated: $(date '+%B %d, %Y')</p>
        </div>
    </div>
</body>
</html>
EOF

    echo -e "${GREEN}✓ Generated index.html with $count module(s)${NC}"
}

# Main documentation generation
main() {
    echo -e "${BLUE}🔍 Analyzing package structure...${NC}"
    
    # Verify we're in the right directory
    if [ ! -f "Package.swift" ]; then
        echo -e "${RED}Error: Package.swift not found. Please run this script from the project root.${NC}"
        exit 1
    fi

    # Create docs directory if it doesn't exist
    mkdir -p "$DOCS_DIR"

    echo -e "${BLUE}📦 Generating documentation for all products...${NC}"
    echo ""
    
    # Generate documentation using Swift-DocC
    if swift package --allow-writing-to-directory "$DOCS_DIR" \
    generate-documentation \
    --disable-indexing \
    --transform-for-static-hosting \
        --hosting-base-path "$HOSTING_BASE_PATH" \
        --output-path "$DOCS_DIR" \
        --enable-experimental-combined-documentation; then
        echo -e "${GREEN}✓ Documentation generated successfully${NC}"
    else
        echo -e "${RED}✗ Failed to generate documentation${NC}"
        exit 1
    fi

    echo ""

    # Generate the index file
generate_index_file

    echo ""
    echo -e "${GREEN}✅ Documentation generation complete!${NC}"
    echo -e "${BLUE}📁 Documentation is available in: $DOCS_DIR${NC}"
    echo -e "${YELLOW}💡 To view locally, open: $DOCS_DIR/index.html${NC}"
}

# Run main function
main
