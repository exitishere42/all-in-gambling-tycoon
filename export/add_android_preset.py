with open(r"C:\Users\timo\Downloads\cube's-adventure\cube's-adventure\export_presets.cfg", 'r', encoding='utf-8') as f:
    cube_cfg = f.read()

preset1_idx = cube_cfg.find('[preset.1]')
preset1 = cube_cfg[preset1_idx:].strip()

# Adjust for All In: Gambling Tycoon
preset1 = preset1.replace('export_path="Export/Cube\'s Adventure.apk"', 'export_path="export/android/all-in-gambling-tycoon.apk"')
preset1 = preset1.replace('package/unique_name="com.example.$genname"', 'package/unique_name="de.exit.all_in_gambling_tycoon"')
preset1 = preset1.replace('package/name=""', 'package/name="All In: Gambling Tycoon"')
preset1 = preset1.replace('application/product_name="Cube\'s Adventure"', 'application/product_name="All In: Gambling Tycoon"')
preset1 = preset1.replace('architectures/armeabi-v7a=false', 'architectures/armeabi-v7a=true')

with open('export_presets.cfg', 'r', encoding='utf-8') as f:
    current = f.read()

new_cfg = current.strip() + '\n\n' + preset1 + '\n'

with open('export_presets.cfg', 'w', encoding='utf-8') as f:
    f.write(new_cfg)

print('Added Android preset to export_presets.cfg successfully!')
