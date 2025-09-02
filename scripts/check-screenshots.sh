#!/bin/bash

# MovieVerse Screenshots Script
# This script helps organize and prepare screenshots for the repository

echo "🎬 MovieVerse Screenshots Organizer"
echo "=================================="

# Create screenshots directory if it doesn't exist
mkdir -p docs/screenshots

echo "📁 Screenshots directory ready: docs/screenshots/"
echo ""
echo "📱 Required Screenshots:"
echo "1. home.png - Home screen with trending movies"
echo "2. search.png - Advanced search with filters"  
echo "3. details.png - Movie details screen"
echo "4. favorites.png - Favorites/Watchlist"
echo "5. recommendations.png - AI recommendations"
echo "6. rating.png - Rating system in action"
echo ""
echo "🎨 Tips:"
echo "- Use portrait orientation"
echo "- Capture with actual movie data"
echo "- Use dark theme for professional look"
echo "- Keep file sizes reasonable (< 500KB each)"
echo ""
echo "📋 Checklist:"

# Check if each screenshot exists
screenshots=("home.png" "search.png" "details.png" "favorites.png" "recommendations.png" "rating.png")

for screenshot in "${screenshots[@]}"
do
    if [ -f "docs/screenshots/$screenshot" ]; then
        echo "✅ $screenshot - Found"
    else
        echo "❌ $screenshot - Missing"
    fi
done

echo ""
echo "🚀 After adding all screenshots, run:"
echo "git add docs/screenshots/"
echo "git commit -m \"📱 Add app screenshots for README\""
echo "git push origin main"
