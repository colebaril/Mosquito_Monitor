import tweepy
import os
import requests
import time
from datetime import datetime

time.sleep(60)

# ----------------------------
# Load credentials (same as before)
# ----------------------------
consumer_key = os.getenv("CONSUMER_TOKEN")
consumer_secret = os.getenv("CONSUMER_TOKEN_SECRET")
access_token = os.getenv("ACCESS_TOKEN")
access_token_secret = os.getenv("ACCESS_TOKEN_SECRET")

if not all([consumer_key, consumer_secret, access_token, access_token_secret]):
    raise ValueError("Missing Twitter credentials")

# ----------------------------
# OAuth1 for media upload (still required)
# ----------------------------
auth = tweepy.OAuth1UserHandler(
    consumer_key,
    consumer_secret,
    access_token,
    access_token_secret
)

api_v1 = tweepy.API(auth)

# ----------------------------
# v2 client for tweeting
# ----------------------------
client_v2 = tweepy.Client(
    consumer_key=consumer_key,
    consumer_secret=consumer_secret,
    access_token=access_token,
    access_token_secret=access_token_secret
)

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
    raise Exception(f"Failed to download image: {response.status_code}")

# ----------------------------
# Upload media (v1.1 still required)
# ----------------------------
media = api_v1.media_upload(filename=local_image_path)
media_id = media.media_id_string  # IMPORTANT: string is safer for v2

# ----------------------------
# Build tweet
# ----------------------------
current_date = datetime.now().strftime("%Y-%m-%d")

message = (
    "City of Winnipeg mosquito trap counts have been updated. "
    "See a detailed update here: https://shorturl.at/MGzTL. "
    "\n#Winnipeg #Mosquitoes #Mosquito #CityOfWinnipeg #HealthAlert"
)

# ----------------------------
# Post tweet (v2)
# ----------------------------
response = client_v2.create_tweet(
    text=message,
    media_ids=[media_id]
)

print("Tweeted!")
print(response)
