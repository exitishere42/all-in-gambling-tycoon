import re

with open('export/template/custom_shell.html', 'r', encoding='utf-8') as f:
    template = f.read()

with open('export/web/index.html', 'r', encoding='utf-8') as f:
    orig = f.read()

m = re.search(r'const GODOT_CONFIG = (\{.*?\});', orig)
if not m:
    raise RuntimeError('Could not extract GODOT_CONFIG')

godot_config_str = m.group(1)
content = template
content = content.replace('$GODOT_PROJECT_NAME', 'All In: Gambling Tycoon')
content = content.replace('$GODOT_URL', 'index.js')
head_inc = '''<script src="https://sdk.crazygames.com/crazygames-sdk-v3.js"></script>
<script>
window.addEventListener("keydown", function(e) { if(["ArrowUp","ArrowDown","Space"].includes(e.code)) e.preventDefault(); }, false);
function resumeAudioOnGesture() {
    try {
        const AudioCtx = window.AudioContext || window.webkitAudioContext;
        if (AudioCtx && typeof AudioCtx === "function") {
            // Find active Godot AudioContext instances if any
            if (window.__godotAudioContext && window.__godotAudioContext.state === "suspended") {
                window.__godotAudioContext.resume();
            }
        }
    } catch(e) {}
}
document.addEventListener("touchend", resumeAudioOnGesture, { passive: true });
document.addEventListener("click", resumeAudioOnGesture, { passive: true });
</script>'''
content = content.replace('$GODOT_HEAD_INCLUDE', head_inc)
content = content.replace('$GODOT_CONFIG', godot_config_str)

with open('export/web/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print('Custom loading screen written cleanly!')
