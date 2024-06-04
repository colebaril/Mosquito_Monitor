import os
import tweepy

# Authenticate to Twitter using environment variables
client = tweepy.Client(
    consumer_key=os.environ['CONSUMER_KEY'],
    consumer_secret=os.environ['CONSUMER_SECRET'],
    access_token=os.environ['ACCESS_TOKEN'],
    access_token_secret=os.environ['ACCESS_TOKEN_SECRET']
)

# Define the tweet message
tweet_message = "Hello, World!"

# Upload the image to Twitter
try:
    # Tweet the message
    response = client.create_tweet(text=tweet_message)
    print("Tweeted successfully!")
except Exception as e:
    print(f"Error: {e}")
