"""Draw the 1024x1024 ArXivApp launcher icon (needs Pillow)."""

import sys

from PIL import Image, ImageDraw, ImageFont

S = 1024
img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
# macOS-style rounded square
d.rounded_rectangle((100, 100, S - 100, S - 100), radius=185, fill=(179, 27, 27, 255))
# stacked "paper" sheets
d.rounded_rectangle((330, 250, 730, 770), radius=30, fill=(255, 255, 255, 110))
d.rounded_rectangle((290, 290, 690, 810), radius=30, fill=(255, 255, 255, 255))
for i, y in enumerate(range(560, 760, 50)):
    d.rounded_rectangle((340, y, 640 - (i % 2) * 80, y + 18), radius=9, fill=(179, 27, 27, 160))
try:
    font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Times New Roman Bold.ttf", 230)
except OSError:
    font = ImageFont.load_default()
d.text((490, 420), "χ", font=font, fill=(179, 27, 27, 255), anchor="mm")
img.save(sys.argv[1])
