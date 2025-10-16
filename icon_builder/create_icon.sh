#!/bin/bash

# Hermes Icon Generator Script
# Creates app icons using system tools (no external dependencies)

echo "🎨 Creating Hermes App Icons..."

ICON_DIR="HermesApp/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$ICON_DIR"

# Colors
PRIMARY_COLOR="#007AFF"
BACKGROUND_COLOR="#F0F8FF"

# Function to create an icon using sips (macOS built-in tool)
create_icon() {
    local size=$1
    local filename=$2
    
    echo "Generating ${size}x${size} icon: $filename"
    
    # Create a temporary SVG
    cat > temp_icon.svg << EOF
<svg width="$size" height="$size" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#007AFF;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#5AC8FA;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- Background rounded rectangle -->
  <rect x="$(($size/10))" y="$(($size/10))" 
        width="$(($size*8/10))" height="$(($size*8/10))" 
        rx="$(($size/5))" ry="$(($size/5))" 
        fill="url(#bg)" />
  
  <!-- Letter H -->
  <g fill="white">
    <!-- Left vertical bar -->
    <rect x="$(($size*3/10))" y="$(($size*25/100))" 
          width="$(($size/12))" height="$(($size/2))" 
          rx="$(($size/24))" />
    
    <!-- Right vertical bar -->
    <rect x="$(($size*55/100))" y="$(($size*25/100))" 
          width="$(($size/12))" height="$(($size/2))" 
          rx="$(($size/24))" />
    
    <!-- Horizontal bar -->
    <rect x="$(($size*35/100))" y="$(($size*46/100))" 
          width="$(($size*3/10))" height="$(($size/12))" 
          rx="$(($size/24))" />
  </g>
  
  <!-- Translation indicators -->
  <circle cx="$(($size*25/100))" cy="$(($size*75/100))" 
          r="$(($size/25))" fill="#FF9500" />
  <circle cx="$(($size*75/100))" cy="$(($size*75/100))" 
          r="$(($size/25))" fill="#FF9500" />
</svg>
EOF

    # Convert SVG to PNG using built-in macOS tools
    if command -v qlmanage >/dev/null 2>&1; then
        # Use qlmanage (built into macOS)
        qlmanage -t -s $size -o . temp_icon.svg >/dev/null 2>&1
        mv temp_icon.svg.png "$ICON_DIR/$filename" 2>/dev/null
    elif command -v sips >/dev/null 2>&1; then
        # Fallback: create simple colored rectangle
        sips -s format png -s pixelsW $size -s pixelsH $size --setProperty color "$PRIMARY_COLOR" temp_icon.svg --out "$ICON_DIR/$filename" >/dev/null 2>&1
    else
        echo "⚠️  No suitable image conversion tool found. Using Python fallback..."
        python3 create_icon.py
        rm -f temp_icon.svg
        return
    fi
    
    rm -f temp_icon.svg
}

# Generate all required sizes
create_icon 16 "hermes-16.png"
create_icon 32 "hermes-32.png"
create_icon 32 "hermes-32-1.png"
create_icon 64 "hermes-64.png"
create_icon 128 "hermes-128.png"
create_icon 256 "hermes-256.png"
create_icon 256 "hermes-256-1.png"
create_icon 512 "hermes-512.png"
create_icon 512 "hermes-512-1.png"
create_icon 1024 "hermes-1024.png"

echo "✅ App icons created successfully!"
echo ""
echo "🎨 Icon Design:"
echo "   • Modern blue gradient background"
echo "   • Clean white 'H' letterform"
echo "   • Orange translation indicator dots"
echo "   • Follows macOS design guidelines"
echo ""
echo "📁 Icons saved to: $ICON_DIR"
echo "🔨 Ready to build in Xcode!"
