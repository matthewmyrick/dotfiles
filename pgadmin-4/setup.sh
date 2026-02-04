#!/bin/bash

# pgAdmin 4 Configuration Setup
# Sets up password file and provides server import instructions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PGADMIN_APP="/Applications/pgAdmin 4.app"

echo "🐘 Setting up pgAdmin 4 configuration..."

# --- 1. Check if pgAdmin 4 is installed ---
if [ ! -d "$PGADMIN_APP" ]; then
    echo "❌ pgAdmin 4 is not installed."
    echo "   Run: brew install --cask pgadmin4"
    exit 1
fi

# --- 2. Set up .pgpass file for auto-authentication ---
PGPASS_FILE="$HOME/.pgpass"
PGPASS_ENTRY="localhost:5438:*:postgres:postgres"

echo "🔑 Setting up PostgreSQL password file..."

if [ -f "$PGPASS_FILE" ]; then
    # Check if entry already exists
    if grep -qF "$PGPASS_ENTRY" "$PGPASS_FILE"; then
        echo "  ✓ Password entry already exists in ~/.pgpass"
    else
        echo "  Adding password entry to existing ~/.pgpass"
        echo "$PGPASS_ENTRY" >> "$PGPASS_FILE"
    fi
else
    echo "  Creating ~/.pgpass"
    cp "$SCRIPT_DIR/pgpass" "$PGPASS_FILE"
fi

# pgpass must be 0600 permissions
chmod 600 "$PGPASS_FILE"
echo "  ✓ ~/.pgpass permissions set (600)"

# --- 3. Import server definitions ---
echo ""
echo "📦 Server import:"
echo ""
echo "  Open pgAdmin 4 and import the pre-configured server:"
echo "    1. Tools > Import/Export Servers"
echo "    2. Select Import"
echo "    3. Browse to: $SCRIPT_DIR/servers.json"
echo "    4. Click Next and finish"
echo ""
echo "  This only needs to be done once. The server will persist across restarts."

echo ""
echo "✅ pgAdmin 4 setup complete!"
echo ""
echo "📋 Pre-configured server (in servers.json):"
echo "  ┌──────────┬──────────────┐"
echo "  │ Host     │ localhost    │"
echo "  │ Port     │ 5438         │"
echo "  │ Database │ postgres     │"
echo "  │ Username │ postgres     │"
echo "  │ Password │ (via pgpass) │"
echo "  └──────────┴──────────────┘"
