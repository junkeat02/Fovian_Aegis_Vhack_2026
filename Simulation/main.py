import pygame
import random
from map.drone import Drone
from map.map import Map
from map.survivor import Survivor
from map import input
from fastapi import FastAPI
import threading
import uvicorn
import asyncio
import websocket_clients.screen_streamer as screen_streamer
import websocket_clients.drone_status as drone_status


NO_OF_DRONES = 2
NO_OF_SURVIVORS = 5
WIDTH = 720
HEIGHT = 720
GRID = 10

x_drone_pos = [x for x in range(GRID)]
y_drone_pos = [y for y in range(GRID)]
drone_img = "images\drone.png"
drone_img_transform = (WIDTH / GRID, HEIGHT / GRID)
drones = [Drone(drone_img, GRID, i, random.randrange(40, 91), x_drone_pos.pop(random.randrange(0, len(x_drone_pos))), y_drone_pos.pop(random.randrange(0, len(y_drone_pos))), drone_img_transform) for i in range(NO_OF_DRONES)]

x_survivor_pos = [x for x in range(GRID)]
y_survivor_pos = [y for y in range(GRID)]
survivor_img = "images\survivor.png"
survivor_img_transform = drone_img_transform
survivors = [Survivor(survivor_img, x_survivor_pos.pop(random.randrange(0, len(x_survivor_pos))), y_survivor_pos.pop(random.randrange(0, len(y_survivor_pos))), survivor_img_transform) for i in range(NO_OF_SURVIVORS)]

map = Map(WIDTH, HEIGHT, GRID, GRID, [x.get_xy() for x in drones])

# clock = pygame.time.Clock() # NOW USE ASYNC

app = FastAPI()

@app.post("/go_left/{drone_id}")
def go_left(drone_id:int, x: int):
    drones[drone_id].go_left(x)

@app.post("/go_right/{drone_id}")
def go_right(drone_id:int, x: int):
    drones[drone_id].go_right(x)

@app.post("/go_up/{drone_id}")
def go_up(drone_id:int, y: int):
    drones[drone_id].go_up(y)
    
@app.post("/go_down/{drone_id}")
def go_down(drone_id:int, y: int):
    drones[drone_id].go_down(y)

@app.get("/get_battery/{drone_id}")
def get_battery(drone_id:int):
    battery_level = drones[drone_id].get_battery_level()
    return f"Drone {drone_id} bat: {battery_level}"

def run_api():
    uvicorn.run(app, host="127.0.0.1", port=8000)

async def game_loop(screen, map, survivors, drones):
    interval = 1/60  # 60FPS
    running = True
    while running:
        # to get the event happening in within the window
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN:
                input.key_down.add(event.key)
                # print(event.key)
            elif event.type == pygame.KEYUP:
                input.key_down.remove(event.key)

        screen.fill("purple")

        map.draw_grid(screen)

        for survivor in survivors:
            survivor.update(screen)

        drones[0].manual_move()
        for drone in drones:
            drone.update(screen)

        
        pygame.display.flip()  # apply changes to the screen
        await asyncio.sleep(interval)

async def main():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    api_thread = threading.Thread(target=run_api, daemon=True)
    api_thread.start()
    await asyncio.gather(
        game_loop(screen, map, survivors, drones),
        screen_streamer.send_screen(screen, screen.get_size()),
        drone_status.send_status(drones)
    )


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pygame.quit()