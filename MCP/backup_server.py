from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import ollama

app = FastAPI()

# --- ADD THIS CORS SECTION ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins (fine for local dev)
    allow_credentials=True,
    allow_methods=["*"],  # Allows POST, OPTIONS, etc.
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    message: str

def process_agent_command(user_input):
    # Define tools for Qwen3
    tools = [
        {
            'type': 'function',
            'function': {
                'name': 'move_drone',
                'description': 'Move a rescue drone in the simulation grid',
                'parameters': {
                    'type': 'object',
                    'properties': {
                        'drone_id': {'type': 'integer', 'description': 'ID 0 or 1'},
                        'direction': {'type': 'string', 'enum': ['North', 'South', 'East', 'West']},
                        'steps': {'type': 'integer', 'description': 'Number of grid cells to move'}
                    },
                    'required': ['drone_id', 'direction', 'steps'],
                },
            },
        },
        {
            'type': 'function',
            'function': {
                'name': 'scan_for_survivors',
                'description': 'Scan the current area for survivors',
                'parameters': {
                    'type': 'object',
                    'properties': {
                        'drone_id': {'type': 'integer'}
                    },
                    'required': ['drone_id'],
                },
            },
        }
    ]

    # Get response from AI Agent
    response = ollama.chat(
        model='qwen3:8b',
        messages=[
            {'role': 'system', 'content': 'You are a drone swarm commander. Explain your reasoning briefly before calling a tool.'},
            {'role': 'user', 'content': user_input}
        ],
        tools=tools,
    )

    message = response['message']
    ai_reasoning = message.get('content', '') # This is the "Thought"
    tool_feedback = ""

    if message.get('tool_calls'):
        for call in message['tool_calls']:
            func_name = call['function']['name']
            args = call['function']['arguments']
            
            if func_name == "move_drone":
                tool_feedback = f"\n[ACTION]: Moving Drone {args['drone_id']} {args['direction']} {args['steps']} steps."
            elif func_name == "scan_for_survivors":
                tool_feedback = f"\n[ACTION]: Scanning area with Drone {args['drone_id']}."

    # 3. Combine Reasoning + Action for the UI
    final_output = f"{ai_reasoning}{tool_feedback}".strip()
    
    return final_output if final_output else "I am standing by for commands."

@app.post("/chat")
async def chat_endpoint(req: ChatRequest):
    response_text = process_agent_command(req.message) 
    return {"response": response_text}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8003)