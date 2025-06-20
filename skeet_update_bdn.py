import os
import requests
from datetime import datetime
from atproto import Client, models

# Load Bluesky credentials
bsky_handle = 'mosquitomonitor.bsky.social'  # No @
bsky_key = os.getenv("BSKY_KEY")

if not bsky_key:
    raise ValueError("BSKY_KEY is not set")

# Init and login
client = Client()
client.login(bsky_handle, bsky_key)

# Download image
image_url = 'https://raw.githubusercontent.com/colebaril/Mosquito_Monitor/main/bdn_mosquito_update_table.png'
local_image_path = 'bdn_mosquito_update_table.png'

response = requests.get(image_url)
if response.status_code == 200:
    with open(local_image_path, 'wb') as f:
        f.write(response.content)
    print(f"Image downloaded to {local_image_path}")
else:
    raise Exception(f"Failed to download image: {response.status_code}")

# Upload image to Bluesky
with open(local_image_path, 'rb') as img_file:
    uploaded_img = client.com.atproto.repo.upload_blob(img_file)

# Compose message
current_date = datetime.now().strftime('%Y-%m-%d')
message = (
    f"City of Brandon mosquito trap counts have been updated. "
    "See a detailed update here: https://shorturl.at/MGzTL"
)

# Create post with image
embed = models.AppBskyEmbedImages.Main(images=[
    models.AppBskyEmbedImages.Image(
        alt='Mosquito trap map of Winnipeg',
        image=uploaded_img.blob
    )
])

client.send_post(text=message, embed=embed)
print("Posted to Bluesky!")
