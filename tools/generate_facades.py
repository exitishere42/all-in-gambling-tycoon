from PIL import Image, ImageDraw

def create_shop_facade(path):
    img = Image.new('RGBA', (96, 80), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Brick wall (dark reddish brown)
    d.rectangle([0, 10, 95, 79], fill=(68, 38, 34, 255))
    for y in range(12, 79, 6):
        d.line([(0, y), (95, y)], fill=(45, 25, 22, 255))
    
    # Roof trim / cornice
    d.rectangle([0, 8, 95, 12], fill=(85, 50, 42, 255))
    d.rectangle([0, 6, 95, 8], fill=(120, 75, 60, 255))
    
    # Awning (Green & White stripes)
    for i, x in enumerate(range(8, 88, 8)):
        col = (25, 110, 60, 255) if (i % 2 == 0) else (235, 235, 240, 255)
        d.polygon([(x, 18), (x + 8, 18), (x + 6, 28), (x - 2, 28)], fill=col)
    d.line([(6, 28), (86, 28)], fill=(15, 60, 35, 255), width=2)
    
    # Sign above awning: "VINNIE'S SUPPLIES"
    d.rectangle([8, 10, 88, 18], fill=(22, 24, 30, 255), outline=(212, 175, 55, 255))
    d.text((12, 9), "VINNIE'S SHOP", fill=(255, 215, 60, 255))
    
    # Display Window on left (34x36)
    d.rectangle([10, 34, 46, 70], fill=(20, 25, 38, 255), outline=(130, 85, 45, 255), width=2)
    d.rectangle([12, 36, 44, 68], fill=(35, 65, 95, 180))
    d.line([(16, 38), (38, 62)], fill=(120, 180, 230, 100), width=2)
    # Mini slot machine silhouette in window
    d.rectangle([20, 48, 34, 66], fill=(180, 140, 50, 255))
    d.rectangle([23, 52, 31, 58], fill=(255, 240, 180, 255))
    # Neon "OPEN" sign in window
    d.rectangle([18, 39, 38, 46], fill=(10, 15, 20, 255))
    d.text((20, 37), "OPEN", fill=(0, 255, 180, 255))
    
    # Wooden Door on right (28x46)
    d.rectangle([54, 34, 84, 79], fill=(85, 45, 28, 255), outline=(45, 22, 12, 255), width=2)
    d.rectangle([58, 38, 80, 54], fill=(45, 75, 105, 200), outline=(55, 30, 18, 255))
    d.line([(60, 40), (76, 52)], fill=(150, 200, 250, 120), width=1)
    d.ellipse([57, 58, 60, 61], fill=(212, 175, 55, 255))
    d.rectangle([58, 68, 80, 76], fill=(180, 140, 50, 255))
    
    img.save(path)
    print("Created shop facade:", path)

def create_casino_facade(path):
    # Casino exterior front: 128 x 96 px
    img = Image.new('RGBA', (128, 96), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Dark grand casino wall
    d.rectangle([0, 16, 127, 95], fill=(38, 22, 28, 255))
    # Wall stone panels
    for y in range(20, 95, 12):
        d.line([(0, y), (127, y)], fill=(25, 14, 18, 255))
    
    # Grand Cornice & Gold Roof molding
    d.rectangle([0, 10, 127, 16], fill=(70, 40, 50, 255))
    d.line([(0, 10), (127, 10)], fill=(212, 175, 55, 255), width=2)
    d.line([(0, 16), (127, 16)], fill=(212, 175, 55, 255), width=1)
    
    # Grand Neon Marquee: "LUCKY DIAMOND"
    d.rectangle([14, 18, 114, 32], fill=(15, 12, 20, 255), outline=(212, 175, 55, 255), width=2)
    # Diamond crest in center of marquee
    d.polygon([(64, 20), (70, 25), (64, 30), (58, 25)], fill=(255, 215, 60, 255))
    d.text((20, 21), "LUCKY", fill=(255, 50, 80, 255))
    d.text((76, 21), "CASINO", fill=(255, 50, 80, 255))
    
    # Grand Double Entrance Doors
    d.rectangle([44, 46, 84, 95], fill=(55, 25, 18, 255), outline=(212, 175, 55, 255), width=2)
    d.line([(64, 46), (64, 95)], fill=(212, 175, 55, 255), width=2) # door split
    # Glass in doors
    d.rectangle([48, 50, 60, 72], fill=(40, 65, 90, 200), outline=(30, 15, 10, 255))
    d.rectangle([68, 50, 80, 72], fill=(40, 65, 90, 200), outline=(30, 15, 10, 255))
    # Brass door handles
    d.rectangle([61, 68, 63, 76], fill=(255, 215, 60, 255))
    d.rectangle([65, 68, 67, 76], fill=(255, 215, 60, 255))
    # Red Welcome Carpet extending outside
    d.polygon([(46, 95), (82, 95), (88, 96), (40, 96)], fill=(160, 20, 30, 255))
    
    # Golden Wall Sconces / Lamps on sides
    for lx in [24, 104]:
        d.rectangle([lx - 3, 50, lx + 3, 62], fill=(212, 175, 55, 255))
        d.ellipse([lx - 5, 45, lx + 5, 55], fill=(255, 235, 120, 255)) # glowing light
    
    img.save(path)
    print("Created casino facade:", path)

create_shop_facade('assets/sprites/city/shop_facade_vinnie.png')
create_casino_facade('assets/sprites/city/casino_facade.png')
