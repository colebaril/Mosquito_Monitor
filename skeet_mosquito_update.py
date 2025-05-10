from atproto import Client
import os

# Get the Bluesky app password from the environment
bsky_key = os.getenv('BSKY_KEY')

# Ensure it's not None
if not bsky_key:
    raise ValueError("BSKY_KEY environment variable not set")

# Initialize client and login
client = Client()
client.login('mosquitomonitor.bsky.social', bsky_key)

# Post your message
client.send_post('Hello world! I posted this via GitHub Actions (test).')
