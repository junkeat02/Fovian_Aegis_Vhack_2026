import websockets
import asyncio

HOST = "0.0.0.0"
PORT = 8001

consumers = set()
producers = set()

async def handler(websocket):
    try:
        registeration_msg = await websocket.recv()
        if registeration_msg == "REGISTER PRODUCER":
            print("Producer connected")
            producers.add(websocket)
            try:
                async for message in websocket:
                    if consumers:
                        #  this * in before the list comprehesion is to unpack all the elements as argument
                        await asyncio.gather(*[c.send(message) for c in consumers], return_exceptions=True)  # run send in parallel with error exception as true
            finally:
                producers.remove(websocket)
        
        if registeration_msg == "REGISTER CONSUMER":
            consumers.add(websocket)
            print(f"Viewer connected: {len(consumers)}")
            try:
                await websocket.wait_closed()
            finally:
                consumers.remove(websocket)
    except websockets.exceptions.ConnectionClosed:
        pass

async def main(host=HOST, port=PORT):
    async with websockets.serve(handler, host, port) as websocket:
        print(f"Websocket open to port: {port}")
        # Run forever
        await asyncio.Future()
       

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nServer stopped by user.")