import tweepy
import os
import requests
import time
from datetime import datetime

# optional delay (you already had this)
time.sleep(60)

# ----------------------------
# Load credentials
# ----------------------------
consumer_key = os.getenv('CONSUMER_TOKEN')
consumer_secret = os.getenv('CONSUMER_TOKEN_SECRET')
access_token = os.getenv('ACCESS_TOKEN')
access_token_secret = os.getenv('ACCESS_TOKEN_SECRET')

if not all([consumer_key, consumer_secret, access_token, access_token_secret]):
    raise ValueError("Twitter API credentials are not set properly")

# ----------------------------
# Twitter API v1.1 auth ONLY
# ----------------------------
auth = tweepy.OAuth1UserHandler(
    consumer_key,
    consumer_secret,
    access_token,
    access_token_secret
)

api = tweepy.API(auth)

# ----------------------------
# Download image
# ----------------------------
image_url = "https://raw.githubusercontent.com/colebaril/Mosquito_Monitor/main/wpg_mosquito_map_tmp.png"
local_image_path = "wpg_mosquito_map_tmp.png"

response = requests.get(image_url)

if response.status_code == 200:
    with open(local_image_path, "wb") as f:
        f.write(response.content)
    print(f"Image downloaded and saved to {local_image_path}")
else:
    raise Exception(f"Failed to download image. Status code: {response.status_code}")

# ----------------------------
# Upload media (v1.1)
# ----------------------------
media = api.media_upload(filename=local_image_path)
media_id = media.media_id

# ----------------------------
# Build tweet message
# ----------------------------
current_date = datetime.now().strftime('%Y-%m-%d')

message = (
    "City of Winnipeg mosquito trap counts have been updated. "
    "See a detailed update here: https://shorturl.at/MGzTL. "
    "\n#Winnipeg #Mosquitoes #Mosquito #CityOfWinnipeg #HealthAlert"
)

# ----------------------------
# Post tweet (v1.1)
# ----------------------------
api.update_status(
    status=message,
    media_ids=[media_id]
)

print("Tweeted!")
