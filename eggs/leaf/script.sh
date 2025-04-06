#!/bin/ash
# shellcheck shell=dash

# Fetch latest Leaf release information from GitHub API
LATEST_RELEASE=$(curl -s https://api.github.com/repos/Winds-Studio/Leaf/releases/latest)
LATEST_TAG=$(echo "$LATEST_RELEASE" | jq -r '.tag_name')
VERSION=$(echo "$LATEST_TAG" | sed 's/^ver-//')
ASSET_URL=$(echo "$LATEST_RELEASE" | jq -r '.assets[0].browser_download_url')
RELEASE_BODY=$(echo "$LATEST_RELEASE" | jq -r '.body')

# Extract checksums from release body
MD5_CHECKSUM=$(echo "$RELEASE_BODY" | grep -m1 "MD5" | awk '{print $3}')
SHA256_CHECKSUM=$(echo "$RELEASE_BODY" | grep -m1 "SHA256" | awk '{print $3}')

cd /mnt/server || exit
printf "Downloading Leaf version %s\n" "$VERSION"

# Backup existing server.jar if present
[ -f "server.jar" ] && mv server.jar server.jar.old

# Download with follow redirects and show progress
curl -L -# -o server.jar "$ASSET_URL"

printf "Downloading optimized configuration files\n"

if [ ! -d "config" ]; then
    mkdir config
fi

if [ ! -f "server.properties" ]; then
    curl -o server.properties https://raw.githubusercontent.com/Voltrapro/Software-Optimizations/refs/heads/main/eggs/leaf/config/server.properties
fi

if [ ! -f "bukkit.yml" ]; then
    curl -o bukkit.yml https://raw.githubusercontent.com/Voltrapro/Software-Optimizations/refs/heads/main/eggs/leaf/config/bukkit.yml
fi

if [ ! -f "spigot.yml" ]; then
    curl -o spigot.yml https://raw.githubusercontent.com/Voltrapro/Software-Optimizations/refs/heads/main/eggs/leaf/config/spigot.yml
fi

if [ ! -f "config/paper-global.yml" ]; then
    curl -o config/paper-global.yml https://raw.githubusercontent.com/Voltrapro/Software-Optimizations/refs/heads/main/eggs/leaf/config/world/paper-global.yml
fi

if [ ! -f "config/paper-world-defaults.yml" ]; then
    curl -o config/paper-world-defaults.yml https://raw.githubusercontent.com/Voltrapro/Software-Optimizations/refs/heads/main/eggs/leaf/config/world/paper-world-defaults.yml
fi

if [ ! -f "config/purpur.yml" ]; then
    curl -o purpur.yml https://raw.githubusercontent.com/Voltrapro/Software-Optimizations/refs/heads/main/eggs/leaf/config/purpur.yml
fi
