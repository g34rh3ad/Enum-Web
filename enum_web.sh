#!/bin/bash

print_banner() {
    cat << "EOF"
   ______                       __      __    __       
  / ____/___  ____  _________  / /___  / /___/ /___  __
 / /   / __ \/ __ \/ ___/ __ \/ / __ \/ / __  / __ \/ /
/ /___/ /_/ / /_/ / /  / /_/ / / /_/ / / /_/ / /_/ / / 
\____/\____/ .___/_/   \____/_/\____/_/\__,_/\____/_/  
          /_/                   @g34rh3ad               
EOF
}

# Display usage instructions
print_usage() {
    print_banner
    echo ""
    echo "enum_web: A subdomain crawling tool with Aggressive and Fast scan modes"
    echo "Usage: enum_web -u <sitename> [-a | -fast] [or] -f <filename.txt> [-a | -fast]"
    echo "Options:"
    echo "  -u <sitename>       Specify a single site name to crawl URLs"
    echo "  -f <filename.txt>   Provide a file with multiple domain names for batch processing"
    echo "  -a                  Perform an aggressive scan (default mode)"
    echo "  -fast               Perform a quick scan"
}

# Ensure required tools are installed
REQUIRED_TOOLS=("subfinder" "assetfinder" "findomain" "shuffledns" "dnsx" "httpx" "anew")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "[!] Required tool '$tool' is not installed. Install it and try again."
        exit 1
    fi
done

# Function to perform subdomain enumeration
enumerate_subdomains() {
    local DOMAIN=$1
    local MODE=$2
    local OUTPUT_FILE="${DOMAIN}_subdomains.txt"
    local TEMP_FILE="results_${DOMAIN}.txt"

    echo "[+] Crawling subdomains for $DOMAIN in $MODE mode..."

    # Aggressive Scan (runs all tools)
    if [[ "$MODE" == "aggressive" ]]; then
        subfinder -d "$DOMAIN" -silent -o subfinder_${DOMAIN}.txt
        assetfinder --subs-only "$DOMAIN" > assetfinder_${DOMAIN}.txt
        findomain -t "$DOMAIN" -q > findomain_${DOMAIN}.txt

        # Merge and resolve subdomains with shuffledns
        cat subfinder_${DOMAIN}.txt assetfinder_${DOMAIN}.txt findomain_${DOMAIN}.txt \
            | anew -q > raw_subdomains_${DOMAIN}.txt
        shuffledns -d "$DOMAIN" -list raw_subdomains_${DOMAIN}.txt -o resolved_${DOMAIN}.txt

        # Validate live subdomains with dnsx
        dnsx -silent -l resolved_${DOMAIN}.txt -o live_dns_${DOMAIN}.txt

        # Check for HTTP services with httpx
        httpx -silent -l live_dns_${DOMAIN}.txt -o httpx_${DOMAIN}.txt

        # Aggregate results from all tools
        cat resolved_${DOMAIN}.txt live_dns_${DOMAIN}.txt httpx_${DOMAIN}.txt \
            | anew "$TEMP_FILE" > /dev/null

    # Fast Scan (uses only quick tools)
    elif [[ "$MODE" == "fast" ]]; then
        subfinder -d "$DOMAIN" -silent -o subfinder_${DOMAIN}.txt
        assetfinder --subs-only "$DOMAIN" > assetfinder_${DOMAIN}.txt

        # Merge and resolve subdomains with shuffledns
        cat subfinder_${DOMAIN}.txt assetfinder_${DOMAIN}.txt \
            | anew -q > raw_subdomains_${DOMAIN}.txt
        shuffledns -d "$DOMAIN" -list raw_subdomains_${DOMAIN}.txt -o resolved_${DOMAIN}.txt

        # Validate live subdomains with dnsx
        dnsx -silent -l resolved_${DOMAIN}.txt -o live_dns_${DOMAIN}.txt

        # Aggregate results from fast tools
        cat resolved_${DOMAIN}.txt live_dns_${DOMAIN}.txt \
            | anew "$TEMP_FILE" > /dev/null
    fi

    # Save final unique results
    cat "$TEMP_FILE" | anew "$OUTPUT_FILE" > /dev/null
    echo "[+] Subdomains for $DOMAIN saved to $OUTPUT_FILE"

    # Cleanup temporary files
    rm -f subfinder_${DOMAIN}.txt assetfinder_${DOMAIN}.txt findomain_${DOMAIN}.txt \
        raw_subdomains_${DOMAIN}.txt resolved_${DOMAIN}.txt live_dns_${DOMAIN}.txt \
        httpx_${DOMAIN}.txt "$TEMP_FILE"
}

# Parse command-line options
MODE="aggressive"  # Default to aggressive scan
if [[ "$*" == *"-fast"* ]]; then
    MODE="fast"
elif [[ "$*" == *"-a"* ]]; then
    MODE="aggressive"
fi

# Main logic
if [[ "$1" == "-u" && -n "$2" ]]; then
    print_banner
    enumerate_subdomains "$2" "$MODE"
elif [[ "$1" == "-f" && -n "$2" ]]; then
    FILENAME=$2
    if [[ ! -f "$FILENAME" ]]; then
        echo "[!] File $FILENAME not found."
        exit 1
    fi
    print_banner
    echo "[+] Reading domains from $FILENAME..."
    while IFS= read -r DOMAIN; do
        if [[ -n "$DOMAIN" ]]; then
            enumerate_subdomains "$DOMAIN" "$MODE"
        fi
    done < "$FILENAME"
    echo "[+] Batch processing completed."
else
    print_usage
    exit 1
fi
