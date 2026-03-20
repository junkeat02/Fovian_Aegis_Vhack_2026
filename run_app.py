import subprocess
import time
import os
import shutil
import signal

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def find_flutter():
    flutter = shutil.which("flutter")
    if flutter is None:
        raise Exception("Flutter not found in PATH. Please run 'flutter doctor'.")
    return flutter

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

def start_flutter():
    flutter = find_flutter()
    return subprocess.Popen(
        [flutter, "run", "-d", "chrome"],
        cwd=os.path.join(BASE_DIR, "Frontend")
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
    python_path = os.path.join(BASE_DIR, "Simulation", ".venv", "Scripts", "python.exe")

    ws = None
    sim = None
    flutter = None

    try:
        ws = start_websocket(python_path)
        print("✅ WebSocket started")
        time.sleep(2)

        sim = start_simulation(python_path)
        print("✅ Simulation started")
        time.sleep(2)

        flutter = start_flutter()
        print("✅ Flutter frontend started")

        print("\nPress Ctrl+C to stop all services...\n")

        while True:
            time.sleep(1)

    except KeyboardInterrupt:
        print("\n🛑 Ctrl+C detected. Shutting down system...")

    finally:
        terminate_process(ws, "WebSocket Server")
        terminate_process(sim, "Simulation")
        terminate_process(flutter, "Flutter")

        print("✅ All processes stopped. Goodbye!")