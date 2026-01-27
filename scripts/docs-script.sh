#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

DOCS_DIR="./docs"
HOSTING_BASE_PATH="ios-utilities"

command -v jq &> /dev/null || { echo -e "${RED}Error: jq is required. Install with: brew install jq${NC}"; exit 1; }
command -v swift &> /dev/null || { echo -e "${RED}Error: Swift is not available${NC}"; exit 1; }

get_products() {
    swift package dump-package | jq -r '
        . as $data | $data.targets[]
        | select(.type == "regular" and any($data.products[]; .targets | index(.)))
        | .name
    '
}

generate_index() {
    local products=$(get_products)
    local product_links=""
    
    for product in $products; do
        local lowercase=$(echo "$product" | tr '[:upper:]' '[:lower:]')
        product_links+="<a href=\"./documentation/$lowercase/\" class=\"module-link\">
            <div class=\"module-icon\">
                <svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\">
                    <path d=\"M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4\"/>
                </svg>
            </div>
            <div class=\"module-info\">
                <span class=\"module-name\">$product</span>
                <span class=\"module-desc\">API Reference</span>
            </div>
            <svg class=\"chevron\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\">
                <path d=\"M9 18l6-6-6-6\"/>
            </svg>
        </a>"
    done

    cat > "$DOCS_DIR/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="FueledUtils - iOS Utilities Library Documentation">
    <title>FueledUtils Documentation</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --fueled-black: #000000;
            --fueled-white: #F5F5F1;
            --fueled-nebula: #6652FF;
            --fueled-nebula-light: #8577ff;
            --fueled-gray: #666666;
            --radius: 12px;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--fueled-white);
            color: var(--fueled-black);
            min-height: 100vh;
            line-height: 1.6;
        }
        .header {
            background: var(--fueled-black);
            padding: 48px 20px 60px;
            text-align: center;
        }
        .logo {
            display: block;
            margin: 0 auto 24px;
            width: fit-content;
            transition: transform 0.2s;
        }
        .logo:hover {
            transform: scale(1.05);
        }
        .logo img {
            height: 80px;
            width: 80px;
            border-radius: 50%;
        }
        .header h1 {
            color: var(--fueled-white);
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 12px;
        }
        .header p {
            color: rgba(245,245,241,0.7);
            font-size: 1.1rem;
            max-width: 600px;
            margin: 0 auto;
        }
        .badge {
            display: inline-block;
            background: var(--fueled-nebula);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-bottom: 16px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .container {
            max-width: 800px;
            margin: -40px auto 40px;
            padding: 0 20px;
        }
        .card {
            background: #ffffff;
            border-radius: var(--radius);
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .card-header {
            padding: 24px;
            border-bottom: 1px solid rgba(0,0,0,0.06);
        }
        .card-header h2 {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--fueled-black);
        }
        .modules { padding: 8px; }
        .module-link {
            display: flex;
            align-items: center;
            padding: 16px;
            text-decoration: none;
            color: var(--fueled-black);
            border-radius: 8px;
            transition: all 0.2s ease;
            gap: 16px;
        }
        .module-link:hover {
            background: var(--fueled-white);
            transform: translateX(4px);
        }
        .module-icon {
            width: 44px;
            height: 44px;
            background: linear-gradient(135deg, var(--fueled-nebula), var(--fueled-nebula-light));
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .module-icon svg {
            width: 22px;
            height: 22px;
            color: white;
        }
        .module-info {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .module-name {
            font-weight: 600;
            font-size: 1rem;
        }
        .module-desc {
            font-size: 0.875rem;
            color: var(--fueled-gray);
        }
        .chevron {
            width: 20px;
            height: 20px;
            color: var(--fueled-gray);
            opacity: 0;
            transition: opacity 0.2s;
        }
        .module-link:hover .chevron { opacity: 1; }
        .footer {
            text-align: center;
            padding: 40px 20px;
            color: var(--fueled-gray);
            font-size: 0.875rem;
        }
        .footer a {
            color: var(--fueled-nebula);
            text-decoration: none;
            font-weight: 500;
        }
        .footer a:hover { text-decoration: underline; }
        .footer .fueled-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin-top: 12px;
            color: var(--fueled-gray);
        }
        .footer .fueled-link svg {
            height: 16px;
            width: auto;
        }
        @media (max-width: 640px) {
            .header { padding: 32px 20px 48px; }
            .header h1 { font-size: 2rem; }
            .container { margin-top: -20px; }
        }
    </style>
</head>
<body>
    <div class="header">
        <a href="https://fueled.com" class="logo" target="_blank" rel="noopener">
            <img src="./logo.png" alt="Fueled Logo">
        </a>
        <span class="badge">Swift Package</span>
        <h1>FueledUtils</h1>
        <p>A collection of utilities for iOS development, crafted by the team at Fueled.</p>
    </div>
    <div class="container">
        <div class="card">
            <div class="card-header">
                <h2>Modules</h2>
            </div>
            <div class="modules">
HTMLEOF

    echo "$product_links" >> "$DOCS_DIR/index.html"

    cat >> "$DOCS_DIR/index.html" << 'HTMLEOF'
            </div>
        </div>
    </div>
    <footer class="footer">
        <p>Built with Swift-DocC · <a href="https://github.com/Fueled/ios-utilities">View on GitHub</a></p>
    </footer>
</body>
</html>
HTMLEOF
}

main() {
    [ -f "Package.swift" ] || { echo -e "${RED}Error: Package.swift not found${NC}"; exit 1; }
    
    mkdir -p "$DOCS_DIR"
    
    echo -e "${BLUE}Generating documentation...${NC}"
    
    swift package --allow-writing-to-directory "$DOCS_DIR" \
        generate-documentation \
        --disable-indexing \
        --transform-for-static-hosting \
        --hosting-base-path "$HOSTING_BASE_PATH" \
        --output-path "$DOCS_DIR" \
        --enable-experimental-combined-documentation
    
    generate_index
    
    # Copy logo if it exists
    [ -f "logo.png" ] && cp logo.png "$DOCS_DIR/"
    
    echo -e "${GREEN}Documentation generated successfully${NC}"
    echo ""
    echo -e "${BLUE}To preview locally, run:${NC}"
    echo "  cd docs && python3 -m http.server 8000"
    echo "  Then open: http://localhost:8000"
}

main
