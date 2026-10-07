import os
from PIL import Image, ImageDraw, ImageFont

os.makedirs('assets/sprites/cards', exist_ok=True)

# Generate Card Back
def create_card_back(path):
    img = Image.new('RGBA', (36, 50), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # White card border
    d.rounded_rectangle([0, 0, 35, 49], radius=3, fill=(245, 245, 250, 255), outline=(30, 30, 40, 255))
    # Red pattern inner
    d.rounded_rectangle([2, 2, 33, 47], radius=2, fill=(150, 25, 35, 255))
    # Diamond pattern
    for y in range(4, 46, 6):
        for x in range(4, 32, 6):
            d.polygon([(x + 3, y), (x + 6, y + 3), (x + 3, y + 6), (x, y + 3)], fill=(212, 175, 55, 200))
    # Outer gold rim
    d.rounded_rectangle([3, 3, 32, 46], radius=2, outline=(212, 175, 55, 255), width=1)
    img.save(path)
    print("Created card back:", path)

# Generate Blank Card Face template
def create_card_front(path):
    img = Image.new('RGBA', (36, 50), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Crisp white card with soft bevel
    d.rounded_rectangle([0, 0, 35, 49], radius=3, fill=(250, 250, 252, 255), outline=(40, 40, 50, 255))
    d.rounded_rectangle([1, 1, 34, 48], radius=2, outline=(220, 222, 230, 255), width=1)
    img.save(path)
    print("Created card front:", path)

create_card_back('assets/sprites/cards/card_back.png')
create_card_front('assets/sprites/cards/card_front.png')
