import tweepy
import os

def create_api():
    consumer_key = os.getenv('CONSUMER_TOKEN')
    consumer_secret = os.getenv('CONSUMER_TOKEN_SECRET')
    access_token = os.getenv('ACCESS_TOKEN')
    access_token_secret = os.getenv('ACCESS_TOKEN_SECRET')

if not all([consumer_key, consumer_secret, access_token, access_token_secret]):
    raise ValueError("Twitter API credentials are not set properly")

    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    
    api = tweepy.Client(auth)
    return api

def tweet(message):
    api = create_api()
    api.create_tweet(text=message)
    print("Tweeted:", message)
