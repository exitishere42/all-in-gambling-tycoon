import os
from PIL import Image, ImageDraw

def create_trash_bag(path):
    img = Image.new('RGBA', (24, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Tied top knot
    d.polygon([(11, 4), (13, 4), (14, 7), (10, 7)], fill=(45, 48, 58, 255))
    d.rectangle([11, 6, 13, 7], fill=(212, 175, 55, 255)) # yellow twist tie
    # Bag body (round, lumpy)
    d.ellipse([4, 7, 20, 22], fill=(30, 32, 40, 255))
    d.ellipse([5, 8, 19, 21], fill=(42, 45, 56, 255))
    # Highlights / wrinkles
    d.line([(7, 11), (11, 15)], fill=(65, 70, 85, 255), width=1)
    d.line([(14, 11), (17, 16)], fill=(65, 70, 85, 255), width=1)
    d.line([(8, 17), (14, 20)], fill=(22, 24, 30, 255), width=1)
    # Outline
    d.arc([4, 7, 20, 22], 0, 360, fill=(15, 16, 22, 255), width=1)
    img.save(path)
    print(f"Created: {path}")

def create_trash_pile(path):
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Cardboard box tilted
    d.polygon([(6, 16), (20, 14), (22, 26), (8, 28)], fill=(160, 114, 70, 255))
    d.polygon([(8, 16), (19, 15), (20, 25), (9, 26)], fill=(185, 136, 88, 255))
    d.line([(14, 15), (15, 26)], fill=(130, 90, 50, 255)) # box seam
    # Discarded soda can (red)
    d.rectangle([18, 22, 27, 26], fill=(200, 40, 40, 255))
    d.rectangle([19, 23, 26, 25], fill=(230, 70, 70, 255))
    d.line([(27, 22), (27, 26)], fill=(180, 180, 190, 255))
    # Crumpled paper
    d.polygon([(3, 22), (7, 20), (8, 25), (4, 26)], fill=(220, 225, 230, 255))
    d.line([(4, 23), (7, 24)], fill=(160, 165, 175, 255))
    # Fishbone / trash scrap
    d.line([(12, 10), (17, 12)], fill=(210, 200, 180, 255))
    d.line([(13, 9), (13, 11)], fill=(210, 200, 180, 255))
    d.line([(15, 10), (15, 12)], fill=(210, 200, 180, 255))
    # Small shadow underneath
    d.ellipse([4, 26, 28, 30], fill=(0, 0, 0, 80))
    img.save(path)
    print(f"Created: {path}")

def create_dirt_stain(path):
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Grimy dust splatter
    d.ellipse([6, 10, 26, 22], fill=(25, 16, 12, 110))
    d.ellipse([10, 8, 22, 24], fill=(35, 22, 16, 140))
    d.ellipse([12, 12, 20, 19], fill=(20, 12, 8, 170))
    d.ellipse([3, 14, 7, 18], fill=(30, 18, 12, 90))
    d.ellipse([24, 18, 29, 22], fill=(30, 18, 12, 90))
    d.point([(5, 12), (26, 11), (22, 25), (9, 23), (17, 7)], fill=(25, 16, 10, 120))
    img.save(path)
    print(f"Created: {path}")

def create_cobweb(path):
    img = Image.new('RGBA', (24, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Corner spiderweb (top-left)
    c = (210, 215, 230, 150)
    c_faint = (180, 190, 210, 90)
    d.line([(0, 0), (22, 0)], fill=c)
    d.line([(0, 0), (0, 22)], fill=c)
    d.line([(0, 0), (20, 20)], fill=c)
    d.line([(0, 0), (11, 22)], fill=c_faint)
    d.line([(0, 0), (22, 11)], fill=c_faint)
    # Arcs
    d.arc([-10, -10, 18, 18], 0, 90, fill=c)
    d.arc([-15, -15, 30, 30], 0, 90, fill=c)
    d.arc([-20, -20, 42, 42], 0, 90, fill=c_faint)
    img.save(path)
    print(f"Created: {path}")

def create_slot_machine_rusty(path):
    # Tier 0 rusty mechanical slot machine (32x48)
    img = Image.new('RGBA', (32, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Shadow
    d.ellipse([2, 44, 30, 47], fill=(0, 0, 0, 120))
    
    # Main Cabinet Body (dull scratched brown-grey with rust spots)
    d.rectangle([4, 6, 28, 44], fill=(70, 52, 42, 255))
    d.rectangle([5, 7, 27, 43], fill=(88, 66, 54, 255))
    
    # Metal trim & chipped chrome
    d.rectangle([4, 6, 28, 9], fill=(130, 115, 105, 255))
    d.rectangle([4, 41, 28, 44], fill=(110, 95, 85, 255))
    
    # Top Marquee (faded yellow/brown with crack)
    d.rectangle([6, 10, 26, 17], fill=(140, 120, 70, 255))
    d.rectangle([7, 11, 25, 16], fill=(180, 155, 90, 255))
    # Crack on glass
    d.line([(10, 11), (13, 14), (16, 13)], fill=(50, 40, 30, 255))
    
    # Reel Window (dirty cream / glass)
    d.rectangle([6, 20, 26, 30], fill=(40, 30, 25, 255))
    d.rectangle([7, 21, 25, 29], fill=(190, 180, 155, 255))
    # Reels (3 columns)
    d.line([(13, 21), (13, 29)], fill=(120, 110, 90, 255))
    d.line([(19, 21), (19, 29)], fill=(120, 110, 90, 255))
    # Faded symbols
    d.rectangle([9, 24, 11, 26], fill=(180, 50, 50, 255)) # cherry
    d.rectangle([15, 24, 17, 26], fill=(180, 150, 40, 255)) # bell
    d.rectangle([21, 24, 23, 26], fill=(50, 90, 160, 255)) # 7
    
    # Coin payout tray (dented rust)
    d.rectangle([8, 34, 24, 39], fill=(55, 40, 32, 255))
    d.rectangle([10, 36, 22, 38], fill=(30, 22, 18, 255))
    
    # Rust patches
    rust = (175, 75, 40, 230)
    d.point([(5, 15), (6, 15), (5, 16), (26, 32), (27, 33), (25, 33), (7, 40), (8, 41), (20, 8)], fill=rust)
    
    # Mechanical Lever on right side
    d.rectangle([29, 22, 31, 25], fill=(90, 80, 75, 255)) # bracket
    d.line([(29, 23), (31, 14)], fill=(160, 160, 165, 255), width=2) # arm
    d.ellipse([29, 11, 32, 14], fill=(200, 40, 30, 255)) # red knob
    
    # Outer 1px black outline
    d.line([(3, 6), (29, 6)], fill=(20, 15, 12, 255))
    d.line([(3, 44), (29, 44)], fill=(20, 15, 12, 255))
    d.line([(3, 6), (3, 44)], fill=(20, 15, 12, 255))
    d.line([(29, 6), (29, 44)], fill=(20, 15, 12, 255))
    
    img.save(path)
    print(f"Created: {path}")

def create_blackjack_table(path):
    # Tier 4 VIP Blackjack table (64x48)
    img = Image.new('RGBA', (64, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Shadow
    d.ellipse([4, 40, 60, 47], fill=(0, 0, 0, 130))
    
    # Wooden Table Legs / Base
    d.rectangle([14, 28, 22, 43], fill=(45, 22, 14, 255))
    d.rectangle([42, 28, 50, 43], fill=(45, 22, 14, 255))
    d.line([(14, 43), (22, 43)], fill=(20, 10, 6, 255))
    d.line([(42, 43), (50, 43)], fill=(20, 10, 6, 255))
    d.rectangle([22, 33, 42, 37], fill=(60, 30, 18, 255)) # support crossbar
    
    # Semi-circular Padded Leather Bumper (Outer Ring)
    d.pieslice([4, 4, 60, 46], 180, 360, fill=(40, 18, 12, 255), outline=(20, 8, 5, 255))
    d.rectangle([4, 25, 60, 29], fill=(40, 18, 12, 255))
    
    # Felt Table Surface (Emerald Green #187a42)
    d.pieslice([7, 7, 57, 43], 180, 360, fill=(24, 122, 66, 255))
    d.rectangle([7, 25, 57, 27], fill=(24, 122, 66, 255))
    # Felt highlight
    d.arc([10, 9, 54, 41], 190, 350, fill=(38, 160, 88, 255), width=1)
    
    # Dealer Area (Flat top edge)
    # Chip Tray / Rack in center top
    d.rectangle([25, 10, 39, 15], fill=(30, 30, 35, 255))
    d.rectangle([26, 11, 38, 14], fill=(212, 175, 55, 255)) # gold chip rack
    # Stacks of chips
    d.rectangle([27, 12, 29, 14], fill=(220, 40, 40, 255))
    d.rectangle([31, 12, 33, 14], fill=(40, 90, 220, 255))
    d.rectangle([35, 12, 37, 14], fill=(30, 30, 30, 255))
    
    # Card Shoe (Shoe on dealer's right)
    d.rectangle([43, 9, 49, 16], fill=(18, 18, 22, 255))
    d.line([(43, 10), (49, 13)], fill=(230, 230, 240, 255))
    
    # Betting Spots (3 yellow arc spots for players)
    spots = [14, 28, 42]
    for sx in spots:
        d.arc([sx, 17, sx + 8, 25], 0, 360, fill=(212, 175, 55, 220), width=1)
    
    # Printed Text curve / arc "BLACKJACK PAYS 3 TO 2"
    d.arc([13, 13, 51, 35], 200, 340, fill=(212, 175, 55, 160), width=1)
    
    # Leather Armrest Highlight
    d.arc([5, 5, 59, 45], 185, 355, fill=(80, 38, 25, 255), width=1)
    
    img.save(path)
    print(f"Created: {path}")

def create_bar_counter(path):
    # Bar Counter unit (32x32)
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Shadow
    d.rectangle([0, 29, 32, 31], fill=(0, 0, 0, 90))
    # Front panelling (Rich Mahogany)
    d.rectangle([1, 6, 31, 29], fill=(62, 32, 20, 255))
    d.rectangle([3, 10, 29, 26], fill=(85, 45, 28, 255))
    # Panelling grooves
    d.line([(3, 10), (29, 10)], fill=(40, 20, 12, 255))
    d.line([(3, 26), (29, 26)], fill=(40, 20, 12, 255))
    d.line([(11, 10), (11, 26)], fill=(40, 20, 12, 255))
    d.line([(21, 10), (21, 26)], fill=(40, 20, 12, 255))
    # Brass foot rail
    d.line([(2, 27), (30, 27)], fill=(212, 175, 55, 255), width=2)
    # Countertop (deep polished dark wood + gold edge)
    d.rectangle([0, 2, 32, 7], fill=(105, 56, 35, 255))
    d.rectangle([0, 2, 32, 4], fill=(145, 80, 50, 255)) # top sheen
    d.line([(0, 7), (32, 7)], fill=(212, 175, 55, 255)) # gold rim
    # Left and right edge outlines
    d.line([(0, 2), (0, 29)], fill=(30, 15, 8, 255))
    d.line([(31, 2), (31, 29)], fill=(30, 15, 8, 255))
    img.save(path)
    print(f"Created: {path}")

def create_bar_stool(path):
    # Bar Stool (16x28)
    img = Image.new('RGBA', (16, 28), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Floor shadow
    d.ellipse([2, 24, 14, 27], fill=(0, 0, 0, 110))
    # Chrome base plate
    d.ellipse([3, 22, 13, 25], fill=(170, 175, 185, 255))
    # Pole stand
    d.rectangle([7, 10, 9, 23], fill=(195, 200, 210, 255))
    # Round footrest ring
    d.ellipse([4, 17, 12, 20], fill=(0, 0, 0, 0), outline=(212, 175, 55, 255), width=1)
    # Round Red Velvet Cushion
    d.ellipse([2, 3, 14, 10], fill=(160, 24, 30, 255))
    d.ellipse([3, 4, 13, 9], fill=(200, 35, 45, 255))
    d.ellipse([5, 4, 11, 7], fill=(235, 65, 75, 255)) # sheen
    # Gold trim on cushion
    d.arc([2, 5, 14, 11], 0, 180, fill=(212, 175, 55, 255), width=1)
    img.save(path)
    print(f"Created: {path}")

def create_atm_machine(path):
    # ATM Machine (24x40)
    img = Image.new('RGBA', (24, 40), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Shadow
    d.ellipse([1, 36, 23, 39], fill=(0, 0, 0, 120))
    # Main Body (Sleek dark blue-grey)
    d.rectangle([3, 4, 21, 37], fill=(32, 38, 52, 255))
    d.rectangle([4, 5, 20, 36], fill=(45, 54, 72, 255))
    # Neon Top Banner "ATM"
    d.rectangle([4, 5, 20, 11], fill=(15, 80, 160, 255))
    d.rectangle([5, 6, 19, 10], fill=(30, 140, 240, 255))
    # ATM letters
    d.line([(7, 7), (9, 7)], fill=(255, 255, 255, 255))
    d.line([(8, 7), (8, 9)], fill=(255, 255, 255, 255))
    d.line([(12, 7), (12, 9)], fill=(255, 255, 255, 255))
    d.line([(15, 7), (15, 9)], fill=(255, 255, 255, 255))
    # Glowing Green Screen
    d.rectangle([6, 14, 18, 22], fill=(10, 40, 25, 255))
    d.rectangle([7, 15, 17, 21], fill=(35, 190, 80, 255))
    d.line([(8, 17), (14, 17)], fill=(180, 255, 200, 255))
    d.line([(8, 19), (12, 19)], fill=(180, 255, 200, 255))
    # Keypad & Card slot
    d.rectangle([6, 25, 12, 29], fill=(180, 185, 195, 255)) # keypad
    d.line([(15, 25), (18, 25)], fill=(15, 15, 20, 255), width=2) # card slot
    # Cash Dispenser
    d.rectangle([7, 31, 17, 34], fill=(20, 25, 35, 255))
    d.line([(9, 32), (15, 32)], fill=(10, 220, 80, 255)) # green light
    # Outline
    d.rectangle([3, 4, 21, 37], outline=(18, 22, 30, 255), width=1)
    img.save(path)
    print(f"Created: {path}")

def create_potted_plant(path):
    # Potted Plant (24x40)
    img = Image.new('RGBA', (24, 40), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Shadow
    d.ellipse([4, 35, 20, 39], fill=(0, 0, 0, 120))
    # Golden Vase / Pot
    d.polygon([(6, 26), (18, 26), (16, 36), (8, 36)], fill=(180, 140, 40, 255))
    d.polygon([(7, 27), (17, 27), (15, 35), (9, 35)], fill=(225, 185, 60, 255))
    d.rectangle([5, 24, 19, 27], fill=(245, 205, 80, 255)) # pot rim
    d.line([(6, 24), (18, 24)], fill=(140, 100, 25, 255))
    # Soil
    d.ellipse([7, 24, 17, 26], fill=(55, 35, 20, 255))
    # Palm Fronds / Leaves (rich greens)
    dark_g = (25, 95, 35, 255)
    mid_g = (40, 145, 55, 255)
    light_g = (80, 195, 85, 255)
    
    # Stem
    d.line([(12, 25), (12, 16)], fill=(70, 50, 30, 255), width=2)
    # Left leaves
    d.polygon([(12, 17), (4, 12), (2, 16), (10, 20)], fill=dark_g)
    d.line([(12, 17), (3, 14)], fill=light_g)
    d.polygon([(12, 15), (3, 6), (5, 4), (11, 13)], fill=mid_g)
    d.line([(12, 15), (4, 5)], fill=light_g)
    # Center / top leaf
    d.polygon([(11, 14), (12, 2), (13, 2), (14, 14)], fill=mid_g)
    d.line([(12, 14), (12, 3)], fill=light_g)
    # Right leaves
    d.polygon([(12, 15), (21, 6), (19, 4), (13, 13)], fill=mid_g)
    d.line([(12, 15), (20, 5)], fill=light_g)
    d.polygon([(12, 17), (20, 12), (22, 16), (14, 20)], fill=dark_g)
    d.line([(12, 17), (21, 14)], fill=light_g)
    img.save(path)
    print(f"Created: {path}")

def create_trash_bin(path):
    # Trash bin (16x24)
    img = Image.new('RGBA', (16, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([2, 19, 14, 23], fill=(0, 0, 0, 110))
    # Brass cylinder
    d.rectangle([3, 7, 13, 20], fill=(190, 150, 50, 255))
    d.rectangle([4, 8, 12, 19], fill=(225, 185, 65, 255))
    # Shiny center strip
    d.line([(7, 8), (7, 19)], fill=(255, 220, 110, 255))
    # Black push lid / hole
    d.ellipse([3, 4, 13, 8], fill=(30, 30, 35, 255))
    d.ellipse([4, 5, 12, 7], fill=(10, 10, 12, 255))
    # Rim
    d.arc([3, 4, 13, 8], 0, 360, fill=(245, 205, 80, 255), width=1)
    img.save(path)
    print(f"Created: {path}")

def create_street_asphalt(path):
    # Seamless road asphalt (32x32)
    img = Image.new('RGBA', (32, 32), (32, 34, 40, 255))
    d = ImageDraw.Draw(img)
    # Noise speckles
    import random
    rng = random.Random(42)
    for x in range(32):
        for y in range(32):
            if rng.random() < 0.2:
                v = rng.randint(24, 45)
                img.putpixel((x, y), (v, v + 2, v + 6, 255))
    # Yellow broken center line
    d.rectangle([14, 4, 18, 16], fill=(230, 180, 40, 255))
    d.rectangle([15, 5, 17, 15], fill=(255, 210, 60, 255))
    img.save(path)
    print(f"Created: {path}")

def create_sidewalk(path):
    # Sidewalk paving slabs (32x32)
    img = Image.new('RGBA', (32, 32), (90, 94, 105, 255))
    d = ImageDraw.Draw(img)
    # Paving stone grid
    d.rectangle([1, 1, 15, 15], fill=(115, 120, 132, 255))
    d.rectangle([17, 1, 31, 15], fill=(105, 110, 122, 255))
    d.rectangle([1, 17, 15, 31], fill=(105, 110, 122, 255))
    d.rectangle([17, 17, 31, 31], fill=(120, 125, 138, 255))
    # Grout lines
    d.line([(0, 16), (32, 16)], fill=(65, 68, 76, 255))
    d.line([(16, 0), (16, 32)], fill=(65, 68, 76, 255))
    # Bottom Curb stone bevel
    d.line([(0, 31), (32, 31)], fill=(50, 52, 60, 255))
    img.save(path)
    print(f"Created: {path}")

def create_street_lamp(path):
    # Street Lamp (24x56)
    img = Image.new('RGBA', (24, 56), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Floor shadow
    d.ellipse([6, 50, 18, 55], fill=(0, 0, 0, 110))
    # Iron Base
    d.polygon([(8, 45), (16, 45), (18, 52), (6, 52)], fill=(40, 42, 50, 255))
    d.rectangle([10, 16, 14, 45], fill=(45, 48, 56, 255))
    d.line([(11, 16), (11, 45)], fill=(65, 70, 80, 255)) # highlight
    # Top Lantern Frame
    d.polygon([(6, 10), (18, 10), (16, 17), (8, 17)], fill=(35, 37, 44, 255))
    # Glowing warm lamp
    d.polygon([(8, 10), (16, 10), (15, 16), (9, 16)], fill=(255, 230, 110, 255))
    d.rectangle([10, 11, 14, 15], fill=(255, 255, 200, 255)) # bulb core
    # Pointed iron roof cap
    d.polygon([(6, 9), (18, 9), (12, 3)], fill=(30, 32, 38, 255))
    d.rectangle([11, 1, 13, 3], fill=(212, 175, 55, 255)) # gold finial tip
    img.save(path)
    print(f"Created: {path}")

def create_street_barrier(path):
    # Construction / Police barrier (32x24)
    img = Image.new('RGBA', (32, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Shadows
    d.ellipse([2, 20, 10, 23], fill=(0, 0, 0, 100))
    d.ellipse([22, 20, 30, 23], fill=(0, 0, 0, 100))
    # Metal A-frame legs
    d.line([(4, 8), (2, 21)], fill=(90, 95, 105, 255), width=2)
    d.line([(8, 8), (10, 21)], fill=(90, 95, 105, 255), width=2)
    d.line([(24, 8), (22, 21)], fill=(90, 95, 105, 255), width=2)
    d.line([(28, 8), (30, 21)], fill=(90, 95, 105, 255), width=2)
    # Barrier Board (White with safety orange stripes)
    d.rectangle([0, 5, 32, 13], fill=(240, 240, 245, 255), outline=(50, 55, 65, 255))
    orange = (255, 85, 0, 255)
    # Diagonal stripes
    for ox in [-4, 6, 16, 26]:
        d.polygon([(ox, 13), (ox + 5, 5), (ox + 8, 5), (ox + 3, 13)], fill=orange)
    # Flashing amber beacon lamp on top
    d.rectangle([14, 2, 18, 5], fill=(255, 180, 0, 255))
    d.rectangle([15, 3, 17, 4], fill=(255, 255, 150, 255))
    img.save(path)
    print(f"Created: {path}")

def create_vinnie_shopkeeper(path):
    # Vinnie the Shopkeeper NPC (24x36)
    img = Image.new('RGBA', (24, 36), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Shadow
    d.ellipse([5, 32, 19, 35], fill=(0, 0, 0, 120))
    # Pants (Dark grey)
    d.rectangle([7, 23, 17, 32], fill=(40, 42, 50, 255))
    d.line([(12, 26), (12, 32)], fill=(20, 22, 28, 255)) # leg split
    d.rectangle([6, 32, 11, 34], fill=(30, 20, 15, 255)) # boots
    d.rectangle([13, 32, 18, 34], fill=(30, 20, 15, 255))
    # Torso (Rolled up white shirt + brown vest + suspenders)
    d.rectangle([6, 13, 18, 23], fill=(225, 225, 230, 255)) # white shirt
    d.rectangle([7, 14, 17, 23], fill=(95, 55, 35, 255)) # brown vest
    d.line([(8, 14), (8, 23)], fill=(40, 20, 12, 255)) # left suspender
    d.line([(16, 14), (16, 23)], fill=(40, 20, 12, 255)) # right suspender
    d.rectangle([10, 15, 14, 23], fill=(225, 225, 230, 255)) # open vest center
    # Arms (rolled up)
    d.rectangle([4, 15, 6, 22], fill=(220, 170, 130, 255)) # skin
    d.rectangle([18, 15, 20, 22], fill=(220, 170, 130, 255))
    # Head & Face
    d.rectangle([8, 6, 16, 13], fill=(225, 175, 135, 255)) # face skin
    d.rectangle([10, 8, 11, 9], fill=(20, 20, 25, 255)) # eyes
    d.rectangle([14, 8, 15, 9], fill=(20, 20, 25, 255))
    d.rectangle([9, 10, 15, 11], fill=(50, 35, 25, 255)) # thick mustache
    # Cigar in mouth
    d.rectangle([15, 10, 19, 11], fill=(110, 60, 30, 255))
    d.point([(19, 10)], fill=(255, 60, 20, 255)) # glowing ash
    # Grey Flat Cap (Newsboy cap)
    d.rectangle([6, 3, 18, 6], fill=(85, 90, 100, 255))
    d.rectangle([5, 5, 19, 7], fill=(60, 65, 75, 255)) # visor
    img.save(path)
    print(f"Created: {path}")

def create_dad_letter(path):
    # Aged parchment background (440x300)
    img = Image.new('RGBA', (440, 300), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Drop shadow
    d.rectangle([10, 10, 430, 290], fill=(0, 0, 0, 160))
    # Aged paper parchment (#f3e5ab)
    d.rectangle([6, 6, 424, 284], fill=(50, 35, 20, 255)) # burnt dark border
    d.rectangle([10, 10, 420, 280], fill=(230, 210, 160, 255))
    d.rectangle([14, 14, 416, 276], fill=(245, 228, 185, 255))
    
    # Elegant gold filigree border
    d.rectangle([18, 18, 412, 272], outline=(180, 140, 60, 255), width=2)
    d.rectangle([22, 22, 408, 268], outline=(200, 160, 70, 200), width=1)
    
    # Red Wax Seal on bottom right
    d.ellipse([345, 210, 395, 260], fill=(160, 25, 25, 255), outline=(110, 15, 15, 255), width=2)
    d.ellipse([350, 215, 390, 255], fill=(195, 35, 35, 255))
    # Diamond crest in wax
    d.polygon([(370, 220), (382, 235), (370, 250), (358, 235)], fill=(140, 20, 20, 255))
    d.polygon([(370, 224), (378, 235), (370, 246), (362, 235)], fill=(225, 185, 60, 255))
    
    img.save(path)
    print(f"Created: {path}")

# Run all generators
create_trash_bag('assets/sprites/cleanup/trash_bag.png')
create_trash_pile('assets/sprites/cleanup/trash_pile.png')
create_dirt_stain('assets/sprites/cleanup/dirt_stain.png')
create_cobweb('assets/sprites/cleanup/cobweb.png')

create_slot_machine_rusty('assets/sprites/props/slot_machine_rusty.png')
create_blackjack_table('assets/sprites/props/blackjack_table.png')

create_bar_counter('assets/sprites/furniture/bar_counter.png')
create_bar_stool('assets/sprites/furniture/bar_stool.png')
create_atm_machine('assets/sprites/furniture/atm_machine.png')
create_potted_plant('assets/sprites/furniture/potted_plant.png')
create_trash_bin('assets/sprites/furniture/trash_bin.png')

create_street_asphalt('assets/sprites/city/street_asphalt.png')
create_sidewalk('assets/sprites/city/sidewalk.png')
create_street_lamp('assets/sprites/city/street_lamp.png')
create_street_barrier('assets/sprites/city/street_barrier.png')

create_vinnie_shopkeeper('assets/sprites/npcs/vinnie_shopkeeper.png')
create_dad_letter('assets/sprites/ui/dad_letter_bg.png')

print("All tycoon sprites generated successfully!")
