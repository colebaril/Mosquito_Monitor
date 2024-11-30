from atproto import Client
import os
import requests
import time
from datetime import datetime



bsky_key = os.getenv('BSKY_KEY')

client = Client()
client.login('@mosquitomonitor.bsky.social', bsky_key)

post = client.send_post('Hello world! I posted this via the Python SDK.')
