"""
Generate app icon for Focus To Do
Run: python generate_icon.py
Requires: pip install Pillow
"""

from PIL import Image, ImageDraw
import os
import math

def create_clock_icon(size, output_path):
    """Create a clock icon with green background and white clock"""
    # Create image with green background
    img = Image.new('RGBA', (size, size), (34, 197, 94, 255))  # #22C55E
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    radius = int(size * 0.35)
    
    # Clock circle outline
    circle_width = max(3, size // 30)
    draw.ellipse(
        [center - radius, center - radius, center + radius, center + radius],
        outline=(255, 255, 255, 255),
        width=circle_width
    )
    
    # Hour markers
    marker_length = int(radius * 0.12)
    marker_width = max(2, size // 50)
    for hour in [0, 3, 6, 9]:
        angle = math.radians(hour * 30 - 90)
        x1 = center + int((radius - marker_length) * math.cos(angle))
        y1 = center + int((radius - marker_length) * math.sin(angle))
        x2 = center + int(radius * math.cos(angle))
        y2 = center + int(radius * math.sin(angle))
        draw.line([(x1, y1), (x2, y2)], fill=(255, 255, 255, 255), width=marker_width)
    
    # Hour hand (pointing to ~10 o'clock)
    hour_length = int(radius * 0.5)
    hour_width = max(3, size // 25)
    hour_angle = math.radians(-60)  # 10 o'clock
    hx = center + int(hour_length * math.cos(hour_angle))
    hy = center + int(hour_length * math.sin(hour_angle))
    draw.line([(center, center), (hx, hy)], fill=(255, 255, 255, 255), width=hour_width)
    
    # Minute hand (pointing to ~2 o'clock)
    minute_length = int(radius * 0.7)
    minute_width = max(2, size // 35)
    minute_angle = math.radians(-30)  # 2 o'clock
    mx = center + int(minute_length * math.cos(minute_angle))
    my = center + int(minute_length * math.sin(minute_angle))
    draw.line([(center, center), (mx, my)], fill=(255, 255, 255, 255), width=minute_width)
    
    # Center dot
    dot_radius = max(3, size // 40)
    draw.ellipse(
        [center - dot_radius, center - dot_radius, center + dot_radius, center + dot_radius],
        fill=(255, 255, 255, 255)
    )
    
    # Ensure directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    # Save
    img.save(output_path, 'PNG')
    print(f"Created: {output_path}")

def main():
    base_path = os.path.dirname(os.path.abspath(__file__))
    project_path = os.path.dirname(base_path)
    
    # Android icon sizes
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    
    android_res_path = os.path.join(project_path, 'android', 'app', 'src', 'main', 'res')
    
    for folder, size in android_sizes.items():
        output_path = os.path.join(android_res_path, folder, 'ic_launcher.png')
        create_clock_icon(size, output_path)
    
    # Create a high-res version for app assets
    assets_path = os.path.join(project_path, 'assets', 'images', 'app_icon.png')
    create_clock_icon(1024, assets_path)
    
    # Create foreground only (for adaptive icon on older devices)
    print("\nIcon generation complete!")
    print("Now run: flutter build apk --release")

if __name__ == '__main__':
    main()
