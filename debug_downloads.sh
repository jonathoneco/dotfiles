#!/bin/bash

echo "=== Debugging Download Issues ==="
echo "Testing the exact commands from your Makefile..."
echo

# Test 1: Neovim download
echo "1. Testing Neovim download..."
echo "URL: https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
wget -q https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz -O /tmp/nvim-test.tar.gz
if [ $? -eq 0 ]; then
    echo "✅ Download succeeded"
    echo "File size: $(stat -f%z /tmp/nvim-test.tar.gz 2>/dev/null || stat -c%s /tmp/nvim-test.tar.gz)"
    echo "File type: $(file /tmp/nvim-test.tar.gz)"
    echo "Testing extraction..."
    tar -tzf /tmp/nvim-test.tar.gz >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Archive is valid"
    else
        echo "❌ Archive is corrupted"
    fi
else
    echo "❌ Download failed with exit code $?"
fi
echo

# Test 2: Ripgrep download
echo "2. Testing ripgrep download..."
echo "Getting latest version..."
RG_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep tag_name | cut -d'"' -f4)
if [ -z "$RG_VERSION" ]; then
    echo "❌ Failed to get ripgrep version from GitHub API"
    echo "API response:"
    curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | head -20
else
    echo "Latest version: $RG_VERSION"
    RG_URL="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb"
    echo "URL: $RG_URL"
    wget -q "$RG_URL" -O /tmp/ripgrep-test.deb
    if [ $? -eq 0 ]; then
        echo "✅ Download succeeded"
        echo "File size: $(stat -f%z /tmp/ripgrep-test.deb 2>/dev/null || stat -c%s /tmp/ripgrep-test.deb)"
        echo "File type: $(file /tmp/ripgrep-test.deb)"
        echo "Testing deb file..."
        dpkg-deb --info /tmp/ripgrep-test.deb >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ DEB file is valid"
        else
            echo "❌ DEB file is corrupted"
        fi
    else
        echo "❌ Download failed with exit code $?"
    fi
fi
echo

# Test 3: Network connectivity
echo "3. Testing network connectivity..."
echo "GitHub API rate limit status:"
curl -s https://api.github.com/rate_limit | jq -r '.rate.remaining, .rate.limit' 2>/dev/null || echo "jq not available"
echo

echo "DNS resolution for github.com:"
nslookup github.com
echo

echo "=== End of diagnostics ==="

# Clean up
rm -f /tmp/nvim-test.tar.gz /tmp/ripgrep-test.deb