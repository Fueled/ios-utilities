#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOCS_DIR="./docs"
GH_PAGES_DIR="./gh-pages-work"
VERSION_PATH="${1:-}"
IS_RELEASE="${2:-false}"

[ -z "$GITHUB_TOKEN" ] && { echo -e "${RED}Error: GITHUB_TOKEN required${NC}" >&2; exit 1; }
[ -z "$GITHUB_REPOSITORY" ] && { echo -e "${RED}Error: GITHUB_REPOSITORY required${NC}" >&2; exit 1; }
[ -d "$DOCS_DIR" ] || { echo -e "${RED}Error: docs directory not found${NC}" >&2; exit 1; }
[ -d "$GH_PAGES_DIR" ] || { echo -e "${RED}Error: gh-pages-work not found${NC}" >&2; exit 1; }
command -v jq &> /dev/null || { echo -e "${RED}Error: jq required${NC}" >&2; exit 1; }

cd "$GH_PAGES_DIR"
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git remote set-url origin "https://x-access-token:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"

update_versions_json() {
    local version="$1"
    [ -f "versions.json" ] || echo '{"versions":[]}' > versions.json
    
    if ! jq -e ".versions | index(\"$version\")" versions.json > /dev/null 2>&1; then
        jq --arg v "$version" '.versions += [$v] | .versions |= sort_by(ltrimstr("v") | split(".") | map(tonumber)) | .versions |= reverse' \
            versions.json > versions.json.tmp && mv versions.json.tmp versions.json
    fi
}

generate_version_index() {
    local versions=$(jq -r '.versions[]' versions.json 2>/dev/null || echo "")
    local version_links=""
    
    for v in $versions; do
        version_links+="<a href=\"./$v/\" class=\"version-link\">$v</a>"
    done

    cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="FueledUtils Documentation">
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
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--fueled-white);
            color: var(--fueled-black);
            min-height: 100vh;
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
        }
        .container {
            max-width: 600px;
            margin: -40px auto 40px;
            padding: 0 20px;
        }
        .card {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .card-header {
            padding: 20px 24px;
            border-bottom: 1px solid rgba(0,0,0,0.06);
            font-weight: 600;
        }
        .versions { padding: 8px; }
        .version-link {
            display: block;
            padding: 14px 20px;
            text-decoration: none;
            color: var(--fueled-black);
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.2s;
        }
        .version-link:hover {
            background: var(--fueled-white);
            color: var(--fueled-nebula);
        }
        .version-link.latest {
            background: linear-gradient(135deg, var(--fueled-nebula), var(--fueled-nebula-light));
            color: white;
            margin: 8px;
        }
        .version-link.latest:hover {
            opacity: 0.9;
            background: linear-gradient(135deg, var(--fueled-nebula), var(--fueled-nebula-light));
            color: white;
        }
        .footer {
            text-align: center;
            padding: 40px 20px;
            color: var(--fueled-gray);
            font-size: 0.875rem;
        }
        .footer a { color: var(--fueled-nebula); text-decoration: none; }
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
    </style>
</head>
<body>
    <div class="header">
        <a href="https://fueled.com" class="logo" target="_blank" rel="noopener">
            <img src="./logo.png" alt="Fueled Logo">
        </a>
        <h1>FueledUtils</h1>
        <p>Select a documentation version</p>
    </div>
    <div class="container">
        <div class="card">
            <div class="card-header">Available Versions</div>
            <div class="versions">
                <a href="./documentation/" class="version-link latest">Latest (main)</a>
HTMLEOF

    echo "$version_links" >> index.html

    cat >> index.html << 'HTMLEOF'
            </div>
        </div>
    </div>
    <footer class="footer">
        <a href="https://github.com/Fueled/ios-utilities">View on GitHub</a>
    </footer>
</body>
</html>
HTMLEOF
}

[ -f "../logo.png" ] && cp "../logo.png" .

if [[ "$IS_RELEASE" == "true" && -n "$VERSION_PATH" ]]; then
    echo -e "${BLUE}Deploying version: $VERSION_PATH${NC}"
    mkdir -p "$VERSION_PATH"
    cp -r "../$DOCS_DIR"/* "$VERSION_PATH/"
    update_versions_json "$VERSION_PATH"
    generate_version_index
    git add "$VERSION_PATH" versions.json index.html logo.png
else
    echo -e "${BLUE}Deploying main branch${NC}"
    cp -r "../$DOCS_DIR"/* .
    [ -f "versions.json" ] && generate_version_index
    git add .
fi

if ! git diff --staged --quiet; then
    git commit -m "docs: Update documentation"
    git push origin gh-pages
    echo -e "${GREEN}Deployed successfully${NC}"
else
    echo -e "${YELLOW}No changes to deploy${NC}"
fi
