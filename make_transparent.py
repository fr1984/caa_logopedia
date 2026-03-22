import sys
import subprocess

def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

try:
    from PIL import Image
except ImportError:
    install('pillow')
    from PIL import Image

def remove_white_bg(img_path, output_path, tolerance=30):
    img = Image.open(img_path).convert("RGBA")
    datas = img.getdata()
    newData = []
    
    # White background removal
    for item in datas:
        # Check if pixel is near-white
        if item[0] > 255 - tolerance and item[1] > 255 - tolerance and item[2] > 255 - tolerance:
            newData.append((255, 255, 255, 0)) # transparent
        else:
            newData.append(item)
            
    img.putdata(newData)
    img.save(output_path, "PNG")

images = [
    r"C:\Users\phemt\.gemini\antigravity\brain\ac5c3afe-f8c2-483e-be30-01fd185cada3\io_arasaac_1774199923741.png",
    r"C:\Users\phemt\.gemini\antigravity\brain\ac5c3afe-f8c2-483e-be30-01fd185cada3\voglio_arasaac_1774199933841.png",
    r"C:\Users\phemt\.gemini\antigravity\brain\ac5c3afe-f8c2-483e-be30-01fd185cada3\mangiare_arasaac_1774199948003.png",
    r"C:\Users\phemt\.gemini\antigravity\brain\ac5c3afe-f8c2-483e-be30-01fd185cada3\bere_arasaac_1774199963745.png"
]

outputs = [
    r"d:\progetto_caa\caa_app\assets\images\io.png",
    r"d:\progetto_caa\caa_app\assets\images\voglio.png",
    r"d:\progetto_caa\caa_app\assets\images\mangiare.png",
    r"d:\progetto_caa\caa_app\assets\images\bere.png"
]

for img, out in zip(images, outputs):
    print(f"Processing {img} -> {out}")
    try:
        remove_white_bg(img, out)
    except Exception as e:
        print(f"Error processing {img}: {e}")

print("Done.")
