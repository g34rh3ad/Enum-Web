# enum_web

## Description

enum_web is a subdomain crawling tool designed for aggressive and fast scans. It leverages various tools like `subfinder`, `assetfinder`, `findomain`, `shuffledns`, `dnsx`, `httpx`, and `anew` to perform comprehensive subdomain enumeration for a given domain. It allows penetration testers, OSINT researchers, and web application security professionals to quickly discover subdomains and validate live services.

## Features

- Aggressive and fast scan modes for subdomain crawling.
- Supports both single-site and batch domain enumeration.
- Resolves subdomains, validates live domains, and checks for HTTP services.
- Easy-to-use command-line interface.
- Displays helpful usage information when needed.

## Prerequisites

Ensure the following tools are installed on your system:

- **subfinder**
- **assetfinder**
- **findomain**
- **shuffledns**
- **dnsx**
- **httpx**
- **anew**

To install these tools, you can follow their respective installation guides or use the following commands for Go-based tools:

```bash
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/findomain/findomain@latest
go install github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/tomnomnom/anew@latest
```

## Installation

Clone the repository and navigate to the folder:

```bash
git clone https://github.com/g34rh3ad/enum_web.git
cd enum_web
chmod +x enum_web.sh
```

## Usage

### Basic Commands

- **Crawl Subdomains for a Site**  
  To crawl subdomains for a single site:

  ```bash
  ./enum_web.sh -u <sitename> [-a | -fast]
  ```

  The default mode is **aggressive**, but you can specify **fast** for a quicker scan.

- **Batch Process Multiple Domains**  
  To process a file with multiple domain names:

  ```bash
  ./enum_web.sh -f <filename.txt> [-a | -fast]
  ```

### Example

- **Crawling Subdomains in Aggressive Mode**  
  ```bash
  ./enum_web.sh -u example.com
  ```

- **Crawling Subdomains in Fast Mode**  
  ```bash
  ./enum_web.sh -u example.com -fast
  ```

- **Batch Processing from a File in Aggressive Mode**  
  ```bash
  ./enum_web.sh -f domains.txt
  ```

- **Batch Processing from a File in Fast Mode**  
  ```bash
  ./enum_web.sh -f domains.txt -fast
  ```

## File Structure

- **enum_web.sh**: The main script for subdomain enumeration.
- **<sitename>_subdomains.txt**: The file where the discovered subdomains are saved.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Author

@g34rh3ad
