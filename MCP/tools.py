from mcp.server.fastmcp import FastMCP
import httpx
import asyncio

# 1. Initialize FastMCP - This is the core "Server" object
mcp = FastMCP("Fovian Aegis Command")

# Base URL for your Pygame FastAPI simulation
SIM_PORT = 8002
SIM_URL = f"http://127.0.0.1:{SIM_PORT}"

# --- DRONE TOOLS ---

@mcp.tool()
async def move_drone(drone_id: int, direction: str, steps: int = 1) -> str:
    """
    Moves a specific rescue drone in the grid.
    Args:
        drone_id: The ID of the drone (0 or 1).
        direction: Direction to move ('North', 'South', 'East', 'West').
        steps: Number of grid units to move.
    """
    # Map the directions to your simulation's FastAPI endpoints
    endpoints = {
        "North": "go_up",
        "South": "go_down",
        "West": "go_left",
        "East": "go_right"
    }
    
    action = endpoints.get(direction)
    if not action:
        return "Invalid direction. Use North, South, East, or West."

    async with httpx.AsyncClient() as client:
        # Match your main.py query parameters (x for horiz, y for vert)
        param_name = "y" if direction in ["North", "South"] else "x"
        url = f"{SIM_URL}/{action}/{drone_id}?{param_name}={steps}"
        
        try:
            response = await client.post(url)
            if response.status_code == 200:
                return f"Successfully moved Drone {drone_id} {direction}."
            return f"Simulation error: {response.status_code}"
        except Exception as e:
            return f"Failed to connect to simulation: {str(e)}"

@mcp.tool()
async def scan_for_survivors(drone_id: int) -> str:
    """
    Triggers the drone's proximity sensors to detect survivors in the current grid cell.
    """
    async with httpx.AsyncClient() as client:
        try:
            # Assumes you add a @app.get("/scan/{drone_id}") to main.py
            response = await client.get(f"{SIM_URL}/scan/{drone_id}")
            data = response.json()
            return f"Scan complete. Survivors found: {data.get('found', 0)}"
        except Exception as e:
            return f"Sensor failure: {str(e)}"

@mcp.tool()
async def get_system_report() -> str:
    """
    Returns the current battery levels and mission progress for the entire fleet.
    """
    async with httpx.AsyncClient() as client:
        # Aggregating data from your get_battery endpoints
        report = []
        for i in range(2): # For 2 drones
            res = await client.get(f"{SIM_URL}/get_battery/{i}")
            report.append(res.text)
        return " | ".join(report)

if __name__ == "__main__":
    # Use 'sse' transport for web/dashboard integration
    mcp.run(transport="sse")