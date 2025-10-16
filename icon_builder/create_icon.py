#!/usr/bin/env python3
"""
Hermes App Icon Generator

Creates a modern, clean app icon for the Hermes translation app.
The icon features a stylized "H" with translation elements in a modern design.
"""

import os
import subprocess
from PIL import Image, ImageDraw, ImageFont
import math

def create_hermes_icon(size):
    """Create a Hermes translation app icon at the specified size."""
    
    # Create a new image with transparency
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Color scheme - modern blue gradient
    primary_color = '#007AFF'  # iOS blue
    secondary_color = '#5AC8FA'  # Light blue
    accent_color = '#FF9500'  # Orange accent
    
    # Calculate dimensions based on size
    margin = size * 0.1
    center = size // 2
    
    # Draw rounded rectangle background
    corner_radius = size * 0.2
    bg_rect = [margin, margin, size - margin, size - margin]
    
    # Create gradient background (simplified)
    draw.rounded_rectangle(bg_rect, corner_radius, fill=primary_color)
    
    # Draw the "H" letterform
    h_width = size * 0.12
    h_height = size * 0.5
    h_left = center - size * 0.15
    h_right = center + size * 0.15
    h_top = center - h_height / 2
    h_bottom = center + h_height / 2
    h_middle = center
    
    # Left vertical bar of H
    draw.rounded_rectangle([h_left - h_width/2, h_top, h_left + h_width/2, h_bottom], 
                          h_width/4, fill='white')
    
    # Right vertical bar of H
    draw.rounded_rectangle([h_right - h_width/2, h_top, h_right + h_width/2, h_bottom], 
                          h_width/4, fill='white')
    
    # Horizontal bar of H
    draw.rounded_rectangle([h_left, h_middle - h_width/4, h_right, h_middle + h_width/4], 
                          h_width/8, fill='white')
    
    # Add translation arrows/symbols
    arrow_size = size * 0.08
    arrow_y = center + size * 0.25
    
    # Left arrow (A→)
    arrow_left_x = center - size * 0.2
    draw.ellipse([arrow_left_x - arrow_size/2, arrow_y - arrow_size/2, 
                  arrow_left_x + arrow_size/2, arrow_y + arrow_size/2], 
                 fill=accent_color)
    
    # Right arrow (あ←)
    arrow_right_x = center + size * 0.2
    draw.ellipse([arrow_right_x - arrow_size/2, arrow_y - arrow_size/2, 
                  arrow_right_x + arrow_size/2, arrow_y + arrow_size/2], 
                 fill=accent_color)
    
    # Add subtle shadow/depth effect
    if size >= 64:
        # Inner highlight
        highlight_rect = [margin + 2, margin + 2, size - margin - 2, size - margin - 2]
        draw.rounded_rectangle(highlight_rect, corner_radius - 2, 
                             fill=None, outline='rgba(255,255,255,0.3)', width=2)
    
    return img

def generate_icon_set():
    """Generate all required icon sizes for macOS."""
    
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    icon_dir = "HermesApp/Assets.xcassets/AppIcon.appiconset"
    
    # Create directory if it doesn't exist
    os.makedirs(icon_dir, exist_ok=True)
    
    for size in sizes:
        print(f"Generating {size}x{size} icon...")
        
        # Create the icon
        icon = create_hermes_icon(size)
        
        # Save with appropriate filename
        if size == 32:
            # Special case: we need two 32px icons
            icon.save(f"{icon_dir}/hermes-32.png", "PNG")
            icon.save(f"{icon_dir}/hermes-32-1.png", "PNG")
        elif size == 256:
            # Special case: we need two 256px icons
            icon.save(f"{icon_dir}/hermes-256.png", "PNG")
            icon.save(f"{icon_dir}/hermes-256-1.png", "PNG")
        elif size == 512:
            # Special case: we need two 512px icons
            icon.save(f"{icon_dir}/hermes-512.png", "PNG")
            icon.save(f"{icon_dir}/hermes-512-1.png", "PNG")
        else:
            icon.save(f"{icon_dir}/hermes-{size}.png", "PNG")
    
    print("✅ All icon sizes generated successfully!")
    print("🎨 Icon features:")
    print("   • Modern blue gradient background")
    print("   • Clean 'H' letterform in white")
    print("   • Translation indicator dots in orange")
    print("   • Rounded corners following macOS design guidelines")

def create_simple_icons_fallback():
    """Create simple placeholder icons using basic shapes if PIL is not available."""
    
    icon_dir = "HermesApp/Assets.xcassets/AppIcon.appiconset"
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    print("⚠️  PIL not available. Creating simple placeholder icons...")
    print("💡 For production, install Pillow: pip install Pillow")
    
    # Create simple colored squares as placeholders
    for size in sizes:
        img = Image.new('RGB', (size, size), '#007AFF')
        
        if size == 32:
            img.save(f"{icon_dir}/hermes-32.png", "PNG")
            img.save(f"{icon_dir}/hermes-32-1.png", "PNG")
        elif size == 256:
            img.save(f"{icon_dir}/hermes-256.png", "PNG")
            img.save(f"{icon_dir}/hermes-256-1.png", "PNG")
        elif size == 512:
            img.save(f"{icon_dir}/hermes-512.png", "PNG")
            img.save(f"{icon_dir}/hermes-512-1.png", "PNG")
        else:
            img.save(f"{icon_dir}/hermes-{size}.png", "PNG")

if __name__ == "__main__":
    try:
        generate_icon_set()
    except ImportError:
        print("📦 Installing Pillow for icon generation...")
        try:
            subprocess.check_call(['pip', 'install', 'Pillow'])
            generate_icon_set()
        except:
            create_simple_icons_fallback()
