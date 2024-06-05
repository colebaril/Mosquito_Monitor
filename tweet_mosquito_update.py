import tweepy
import os
import requests
import imageio as iio
from io import BytesIO


consumer_key = os.getenv('CONSUMER_TOKEN')
consumer_secret = os.getenv('CONSUMER_TOKEN_SECRET')
access_token = os.getenv('ACCESS_TOKEN')
access_token_secret = os.getenv('ACCESS_TOKEN_SECRET')

client = tweepy.Client(consumer_key=consumer_key,consumer_secret=consumer_secret,access_token=access_token,access_token_secret=access_token_secret)

if not all([consumer_key, consumer_secret, access_token, access_token_secret]):
    raise ValueError("Twitter API credentials are not set properly")

# URL of the image in the GitHub repository
image_url = 'https://raw.githubusercontent.com/colebaril/Mosquito_Monitor/main/wpg_mosquito_map_tmp.png'

# Send a GET request to the image URL
response = requests.get(image_url)

# Check if the request was successful
if response.status_code == 200:
    # Open the image from the response content
    image = iio.imread(BytesIO(response.content))
else:
    print(f"Failed to retrieve the image. Status code: {response.status_code}")
    
# Create a tweet
message="Hello from GitHub Actions. This is a test."
media_id = image
client.create_tweet(media_ids = [media_id], text=message)
print("Tweeted!")
