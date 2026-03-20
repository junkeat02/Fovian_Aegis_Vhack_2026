# 🚁 Fovian Aegis — VHack 2026

Fovian Aegis is a decentralized swarm intelligence system designed for autonomous disaster response. This project simulates a multi-drone coordination system powered by agentic AI, capable of operating in communication blackout scenarios.

---

## 🧩 Project Structure



The repository is organized into three core interconnected layers:

- Frontend: Flutter-based Command Dashboard for real-time visualization, telemetry, and manual override.

- MCP (Model Context Protocol): The "nervous system" consisting of a FastAPI tool bridge and a local reasoning engine.

- Simulation: A high-fidelity disaster environment modeled in Pygame with a dedicated FastAPI controller for drone physics and sensors.


---

## 🌐 Frontend

The **Frontend** directory contains a Flutter-based application designed for web and desktop platforms.

### Features:
- Real-time visualization of drone movements
- Agent reasoning and mission logs display
- Interactive dashboard for monitoring system behavior

---

## 🧠 MCP (Model Context Protocol)

The MCP module acts as the bridge between the AI's "thought process" and the simulation's "actions."

### Key Components
- Tool Bridge (server.py): A FastAPI server that interprets natural language, selects appropriate tools using Qwen3:8b, and executes commands.

- Ollama Integration: Runs locally to ensure the system remains functional during internet outages—a critical requirement for disaster response.

- Autonomous Function Calling: Implements tools such as move_drone, scan_for_survivors, and get_system_report.

---

## 🛰️ Simulation

The **Simulation** module models drone behavior and disaster environments using Pygame.

### Features:
- Grid-based disaster environment
- Autonomous drone movement and battery simulation
- Survivor detection simulation
- WebSocket server for real-time communication with frontend

---

## 🔗 System Overview
The system architecture follows a Tri-Server model:

1. Simulation (Port 8002): Handles physics, grid logic, and drone state.

2. MCP Bridge (Port 8003): Processes AI tool calls and routes them to the simulation.

3. Ollama (Local): Provides the reasoning capabilities for the agent.

---
## 🚀 Getting Started

### Prerequisites
- Python 3.10+

- Flutter SDK

- Ollama (Ensure the qwen3:8b model is pulled)

- Groq (For testing due to equipment's constrainst as the AI agent)

---

## 📌 Future Work

- MCP server implementation
- AI agent integration (planning + reasoning)
- ROS2 integration for real-world deployment
- Advanced computer vision for survivor detection

---

## ▶️ Running the System

You can launch the entire system (WebSocket server, simulation, and MCP) using a single command, you still need to run the command in step 5 of the Manual step as flutter required to run under the root of the project:

```bash
python run_app.py
```
---

## ⚠️ Manual Setup (If `run_app.py` Fails)

If the automated launcher (`run_app.py`) does not work, you can manually start each component of the system.

> 💡 Make sure you open **separate terminals** for each component.

---

## 🧩 Step 1 — Start WebSocket Server

Open a terminal:

```bash
cd Simulation
.\.venv\Scripts\activate
python websocket_server.py
```
## 🧩 Step 2 — Start the simulation
In new terminal:
```bash
cd Simulation
.\.venv\Scripts\activate
python main.py

```
## 🧩 Step 3 — Start the MCP Server
In new terminal:
```bash
cd MCP
.\.venv\Scripts\activate
python server.py

```
## 🧩 Step 4 — Start the MCP tools
In new terminal:
```bash
cd MCP
.\.venv\Scripts\activate
python tools.py

```

## 🧩 Step 5 — Start the flutter application
In another new terminal:
```bash
cd Frontend/flutter_application
flutter run -d chrome
```
---

## 👨‍💻 Author

Developed by **Fovian Aegis Team**  
VHack 2026 Submission