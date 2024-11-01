#!/bin/bash

# Define color codes for terminal output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

get_products() {
    # Get all products from Package.swift
    PRODUCTS=$(swift package dump-package | jq -r '
    . as $data |
    $data.targets[]
    | select(.type == "regular" and 
            any($data.products[]; .targets | index(.)))
    | .name
    ')

    if [ -z "$PRODUCTS" ]; then
        echo -e "${RED}Error: No products found in Package.swift${NC}"
        exit 1
    fi

    echo "$PRODUCTS"
}

generate_index_file() {
    echo -e "${BLUE}Generating index.html file...${NC}"

    # Create the HTML file and write the initial content
    cat > ./docs/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Documentation</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f9f9f9;
            color: #333;
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #0366d6;
            padding-bottom: 10px;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin: 15px 0;
            transition: background-color 0.3s;
        }
        li:hover {
            background-color: #e6f7ff;
        }
        a {
            color: #0366d6;
            text-decoration: none;
            font-size: 18px;
            display: block; /* Makes the entire area clickable */
            padding: 10px;
            border-radius: 4px;
        }
        a:hover {
            text-decoration: underline;
            background-color: #e6f7ff; /* Highlights the link on hover */
        }
    </style>
</head>
<body>
    <h1>Available Documentation</h1>
    <ul>
EOF

    # Get the products and loop through them to create links
    PRODUCTS=$(get_products)
    for PRODUCT in $PRODUCTS; do
        LOWERCASE_PRODUCT=$(echo "$PRODUCT" | tr '[:upper:]' '[:lower:]')
        echo "        <li><a href='./documentation/$LOWERCASE_PRODUCT/'>$PRODUCT</a></li>" >> ./docs/index.html
    done

    # Closing the HTML tags
    cat >> ./docs/index.html << EOF
    </ul>
</body>
</html>
EOF
}

# This script is used to generate the documentation for the project.
swift package --allow-writing-to-directory ./docs \
    generate-documentation \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path ios-utilities \
    --output-path ./docs \
    --enable-experimental-combined-documentation

# Write the index.html file to navigate between the products
generate_index_file

# Notify user of completion
echo -e "${GREEN}Documentation generated in ./docs directory${NC}"