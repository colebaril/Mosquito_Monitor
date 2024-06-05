import tweepy
import os
import requests
from datetime import datetime


consumer_key = os.getenv('CONSUMER_TOKEN')
consumer_secret = os.getenv('CONSUMER_TOKEN_SECRET')
access_token = os.getenv('ACCESS_TOKEN')
access_token_secret = os.getenv('ACCESS_TOKEN_SECRET')

def get_twitter_conn_v1(consumer_key, consumer_secret, access_token, access_token_secret) -> tweepy.API:
    """Get twitter conn 1.1"""

    auth = tweepy.OAuth1UserHandler(consumer_key, consumer_secret)
    auth.set_access_token(
        access_token,
        access_token_secret,
    )
    return tweepy.API(auth)

def get_twitter_conn_v2(consumer_key, consumer_secret, access_token, access_token_secret) -> tweepy.Client:
    """Get twitter conn 2.0"""

    client = tweepy.Client(
        consumer_key=consumer_key,
        consumer_secret=consumer_secret,
        access_token=access_token,
        access_token_secret=access_token_secret,
    )

    return client

client_v1 = get_twitter_conn_v1(consumer_key, consumer_secret, access_token, access_token_secret)
client_v2 = get_twitter_conn_v2(consumer_key, consumer_secret, access_token, access_token_secret)

if not all([consumer_key, consumer_secret, access_token, access_token_secret]):
    raise ValueError("Twitter API credentials are not set properly")

# URL of the image
image_url = 'https://raw.githubusercontent.com/colebaril/Mosquito_Monitor/main/wpg_mosquito_map_tmp.png'
local_image_path = 'wpg_mosquito_map_tmp.png'

# Download the image
response = requests.get(image_url)
if response.status_code == 200:
    with open(local_image_path, 'wb') as file:
        file.write(response.content)
    print(f"Image downloaded and saved to {local_image_path}")
else:
    print(f"Failed to download image. Status code: {response.status_code}")

media_path = local_image_path
media = client_v1.media_upload(filename=media_path)
media_id = media.media_id

# Get the current date
current_date = datetime.now().strftime('%Y-%m-%d')

# Create a tweet
message = f"City of Winnipeg mosquito trap counts have been updated as of {current_date}. See a detailed update here: https://github.com/colebaril/Mosquito_Monitor. #Mosquito #Winnipeg #CityOfWinnipeg #InsectControl"
client_v2.create_tweet(media_ids=[media_id], text=message)
print("Tweeted!")
