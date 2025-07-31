#!/usr/bin/env python3
"""
Fetches DNS records from the Unbound cache, filters them using the Public
Suffix List to get a clean list of registrable domains, and writes them to
a specified output file.

This script is intended to be run periodically to generate a list of "popular"
domains that can be used to prime the Unbound cache after a restart.
"""

import subprocess
import sys
from datetime import datetime, timezone

from publicsuffixlist import PublicSuffixList

# --- Configuration ---
UNBOUND_CONFIG_PATH = "/etc/unbound/unbound.conf"
OUTPUT_FILE = "/var/lib/unbound/popular-domains.txt"


def process_cache_dump(cache_dump: str) -> list[str]:
    """
    Takes the raw output from 'unbound-control dump_cache' and returns a
    clean, sorted list of valid, registrable domain names.

    Args:
        cache_dump: A string containing the raw cache dump.

    Returns:
        A sorted list of filtered domain names.
    """
    psl = PublicSuffixList()
    valid_domains = set()

    for line in cache_dump.splitlines():
        if not line.startswith("msg"):
            continue

        parts = line.split()
        if len(parts) < 2:
            continue

        # Clean up the domain name
        domain = parts[1].strip().rstrip(".")
        if not domain:
            continue

        # Apply the filter: keep the domain only if it is NOT a public suffix.
        public_suffix = psl.publicsuffix(domain)
        if domain != public_suffix:
            valid_domains.add(domain)

    return sorted(list(valid_domains))


def main():
    """Main execution function."""
    print("Exporting and filtering active domains from Unbound cache...")

    # 1. Get the cache dump from unbound-control
    try:
        proc = subprocess.run(
            f"unbound-control -c {UNBOUND_CONFIG_PATH} dump_cache",
            shell=True,
            check=True,
            capture_output=True,
            text=True,
        )
        cache_dump = proc.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running unbound-control: {e.stderr}", file=sys.stderr)
        sys.exit(1)

    # 2. Process the domains using the dedicated function
    clean_domains = process_cache_dump(cache_dump)

    # 3. Write the final, clean list to the output file
    try:
        with open(OUTPUT_FILE, "w") as f:
            f.write(f"# Generated on {datetime.now(timezone.utc).isoformat()}\n")
            for domain in clean_domains:
                f.write(f"{domain}\n")
        print(f"Active domains list successfully updated at {OUTPUT_FILE}")
    except IOError as e:
        print(f"Error writing to {OUTPUT_FILE}: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
