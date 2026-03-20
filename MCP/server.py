import os
import json
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from groq import Groq
import httpx
import asyncio

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

GROQ_KEY = os.environ.get("GROQ_API_KEY") or "paste_your_key_here"
client = Groq(api_key=str(GROQ_KEY))

class ChatRequest(BaseModel):
    message: str

async def process_agent_command(user_input):
    # Added battery and XY tools to the list
    tools = [
        {
            "type": "function",
            "function": {
                "name": "move_drone",
                "description": "Move a rescue drone in the simulation grid",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "drone_id": {"type": "integer"},
                        "direction": {"type": "string", "enum": ["North", "South", "East", "West"]},
                        "steps": {"type": "integer"}
                    },
                    "required": ["drone_id", "direction", "steps"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "scan_for_survivors",
                "description": "Scan the current area for survivors",
                "parameters": {
                    "type": "object",
                    "properties": {"drone_id": {"type": "integer"}},
                    "required": ["drone_id"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "get_drone_status",
                "description": "Get the current battery level and XY position of a drone",
                "parameters": {
                    "type": "object",
                    "properties": {"drone_id": {"type": "integer"}},
                    "required": ["drone_id"],
                },
            },
        }
    ]

    response = client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[
            {"role": "system", "content": "You are a drone swarm commander. Use get_drone_status to check battery before moving far."},
            {"role": "user", "content": user_input}
        ],
        tools=tools,
        tool_choice="auto"
    )

    response_message = response.choices[0].message
    ai_reasoning = response_message.content if response_message.content else ""
    tool_feedback = ""

    if response_message.tool_calls:
        async with httpx.AsyncClient() as http_client: 
            for tool_call in response_message.tool_calls:
                func_name = tool_call.function.name
                args = json.loads(tool_call.function.arguments)
                d_id = args.get('drone_id')
                
                if func_name == "move_drone":
                    dir_map = {"North": "go_up", "South": "go_down", "East": "go_right", "West": "go_left"}
                    endpoint = dir_map.get(args['direction'])
                    param = "y" if args['direction'] in ["North", "South"] else "x"
                    url = f"http://127.0.0.1:8002/{endpoint}/{d_id}?{param}={args['steps']}"
                    await http_client.post(url)
                    tool_feedback += f"\n[ACTION]: Moved Drone {d_id} {args['direction']}."

                elif func_name == "scan_for_survivors":
                    try:
                        res = await http_client.get(f"http://127.0.0.1:8002/scan/{d_id}")
                        res.raise_for_status() # Check if the request actually worked (200 OK)
                        
                        scan_data = res.json()
                        found = scan_data.get('found', 0)
                        tool_feedback += f"\n[ACTION]: Scan result for Drone {d_id}: {found} survivors."
                        
                    except Exception as e:
                        tool_feedback += f"\n[ERROR]: Failed to scan with Drone {d_id}. Simulation server might be down or busy."
                        print(f"Scan error: {e}")

                elif func_name == "get_drone_status":
                    # Fetching both battery and position from simulation
                    bat_res = await http_client.get(f"http://127.0.0.1:8002/get_battery/{d_id}")
                    pos_res = await http_client.get(f"http://127.0.0.1:8002/get_xy/{d_id}")
                    tool_feedback += f"\n[STATUS]: {bat_res.text} | {pos_res.text}"

    if not ai_reasoning and tool_feedback:
        ai_reasoning = "Tactical update received."

    return ai_reasoning.strip(), tool_feedback.strip()

@app.post("/chat")
async def chat_endpoint(req: ChatRequest):
    reasoning, action = await process_agent_command(req.message) 
    return {"reasoning": reasoning, "action": action}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8003)