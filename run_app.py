import subprocess
import time
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))


def start_websocket(python_path):
    return subprocess.Popen(
        [python_path, "websocket_server.py"],
        cwd=os.path.join(BASE_DIR, "Simulation")
    )

def start_simulation(python_path):
    return subprocess.Popen(
        [python_path, "main.py"],
        cwd=os.path.join(BASE_DIR, "Simulation")
    )

def start_mcp_server(python_path):
    return subprocess.Popen(
        [python_path, "server.py"],
        cwd=os.path.join(BASE_DIR, "MCP")
    )

def start_mcp_tools(python_path):
    return subprocess.Popen(
        [python_path, "tools.py"],
        cwd=os.path.join(BASE_DIR, "MCP")
    )


def terminate_process(proc, name):
    if proc and proc.poll() is None:
        print(f"Stopping {name}...")
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            print(f"{name} did not terminate in time. Killing...")
            proc.kill()

if __name__ == "__main__":
    print("🚀 Starting Fovian Aegis System...")

    # Use venv python
    sim_path = os.path.join(BASE_DIR, "Simulation", ".venv", "Scripts", "python.exe")
    mcp_path = os.path.join(BASE_DIR, "MCP", ".venv", "Scripts", "python.exe")

    ws = None
    sim = None
    server = None
    tools = None

    try:
        ws = start_websocket(sim_path)
        print("✅ WebSocket started")
        time.sleep(2)

        sim = start_simulation(sim_path)
        print("✅ Simulation started")
        time.sleep(2)

        server = start_mcp_server(mcp_path)
        print("✅ WebSocket started")
        time.sleep(2)

        tools = start_mcp_tools(mcp_path)
        print("✅ WebSocket started")
        time.sleep(2)

        print("\nPress Ctrl+C to stop all services...\n")

        while True:
            time.sleep(1)

    except KeyboardInterrupt:
        print("\n🛑 Ctrl+C detected. Shutting down system...")

    finally:
        terminate_process(ws, "WebSocket Server")
        terminate_process(sim, "Simulation")
        terminate_process(server, "MCP Server")
        terminate_process(tools, "MCP Tools")

        print("✅ All processes stopped. Goodbye!")