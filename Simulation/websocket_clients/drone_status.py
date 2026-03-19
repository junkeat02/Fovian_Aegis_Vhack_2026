import asyncio
import websockets
import json

HOST = "localhost"
PORT = 8001
URL = f"ws://{HOST}:{PORT}"

async def send_status(drones, url=URL):
    # clock = pygame.time.Clock() # NOW USE ASYNC
    interval = 1/60 # Data transmission rate
    drones_status = {}
    while True:
        try:
            async with websockets.connect(url) as websocket:
                print(f"Connected to the websocket server: {url}")
                await websocket.send("REGISTER PRODUCER")
                while True:
                    drone_status = {}
                    for drone in drones:
                        drone_status['id'] = drone.id
                        drone_status["battery"] = drone.battery_level
                        drone_status["survivors"] = drone.survivor_found
                        drones_status[f"drone{drone.id}"] = drone_status
                        drone_status = {}
                    await websocket.send(json.dumps(drones_status))
                    await asyncio.sleep(interval)
        except Exception as e:
            print(f"URL: {URL}")
            print(f"Status send failed: {e}. Retrying in 2 seconds...")
            await asyncio.sleep(2)



