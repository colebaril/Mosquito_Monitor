import tweepy
import os
import requests
from PIL import Image
from io import BytesIO


consumer_key = os.getenv('CONSUMER_TOKEN')
consumer_secret = os.getenv('CONSUMER_TOKEN_SECRET')
access_token = os.getenv('ACCESS_TOKEN')
access_token_secret = os.getenv('ACCESS_TOKEN_SECRET')

client = tweepy.Client(consumer_key=consumer_key,consumer_secret=consumer_secret,access_token=access_token,access_token_secret=access_token_secret)

if not all([consumer_key, consumer_secret, access_token, access_token_secret]):
    raise ValueError("Twitter API credentials are not set properly")

 # Upload the image
    media = api.media_upload('https://raw.githubusercontent.com/colebaril/Mosquito_Monitor/main/wpg_mosquito_map_tmp.png')

    # Get the media_id
    media_id = media.media_id_string
    
# Create a tweet
message="Hello from GitHub Actions. This is a test."
client.create_tweet(media_ids=[media_id], text=message)
print("Tweeted!")
