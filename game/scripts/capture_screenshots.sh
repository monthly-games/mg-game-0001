#!/bin/bash
# Screenshot Capture Script for MG-0001
# Captures screenshots for Google Play Store and Apple App Store

echo "🎮 MG-0001 Screenshot Capture Script"
echo "======================================"
echo ""
echo "This script will:"
echo "1. Start the web server"
echo "2. Open browser for manual screenshot capture"
echo "3. Provide instructions for each screen"
echo ""
echo "Required Screenshots (8):"
echo "  1. Main Menu"
echo "  2. Level Selection"
echo "  3. Daily Quests"
echo "  4. Gameplay (Level 1)"
echo "  5. Rewards Screen"
echo "  6. Tournament"
echo "  7. Guild War"
echo "  8. Seasonal Event"
echo ""
echo "Recommended size: 1080x1920 (portrait) or 1920x1080 (landscape)"
echo ""

# Change to game directory
cd "$(dirname "$0")/../"

# Start web server in background
echo "🚀 Starting web server..."
echo "   Open http://localhost:8080 in your browser"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Check if python is available
if command -v python3 &> /dev/null; then
    python3 -m http.server 8080 -d build/web
elif command -v python &> /dev/null; then
    python -m http.server 8080 -d build/web
else
    echo "❌ Python not found. Please install Python or use a different web server."
    echo "   You can manually serve build/web with any web server."
    exit 1
fi
