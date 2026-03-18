import asyncio
import io
import pygame
from PIL import Image
import websockets

HOST = "localhost"
PORT = 8001
URL = f"ws://{HOST}:{PORT}"

string_format = "RGB"

async def send_screen(screen, screen_size:tuple, url=URL):
    width = screen_size[0]
    height = screen_size[1]
    # clock = pygame.time.Clock() # NOW USE ASYNC
    interval = 1/60 #FPS
    while True:
        try:
            async with websockets.connect(url) as websocket:
                print(f"Connected to the websocket server: {url}")
                await websocket.send("REGISTER PRODUCER")
                while True:
                    raw_str = pygame.image.tostring(screen, string_format)
                    img = Image.frombytes(string_format, (width, height), raw_str)

                    buffer = io.BytesIO()
                    img.save(buffer, format="JPEG", quality=100)
                    img_bytes = buffer.getvalue()

                    await websocket.send(img_bytes)
                    await asyncio.sleep(interval)
        except Exception as e:
            print(f"URL: {URL}")
            print(f"Streaming failed: {e}. Retrying in 2 seconds...")
            await asyncio.sleep(2)



