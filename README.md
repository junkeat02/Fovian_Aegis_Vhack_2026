# 🚁 Fovian Aegis — VHack 2026

Fovian Aegis is a decentralized swarm intelligence system designed for autonomous disaster response. This project simulates a multi-drone coordination system powered by agentic AI, capable of operating in communication blackout scenarios.

---

## 🧩 Project Structure

The repository is organized into three main components:



---

## 🌐 Frontend

The **Frontend** directory contains a Flutter-based application designed for web and desktop platforms.

### Features:
- Real-time visualization of drone movements
- Agent reasoning and mission logs display
- Interactive dashboard for monitoring system behavior

---

## 🧠 MCP (Model Context Protocol)

The **MCP** module represents the core backend logic for agent-based decision-making.

> ⚠️ Status: Not yet implemented (planned for next development phase)

### Planned Features:
- Tool abstraction layer for drone control
- Integration with AI agent for task planning
- Dynamic drone discovery and coordination

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

## 🚀 Getting Started

### Prerequisites
- Python 3.10
- Flutter SDK

---

## 📌 Future Work

- MCP server implementation
- AI agent integration (planning + reasoning)
- ROS2 integration for real-world deployment
- Advanced computer vision for survivor detection

---

## ▶️ Running the System

You can launch the entire system (WebSocket server, simulation, and frontend) using a single command:

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

In new terminal:
```bash
cd Simulation
python main.py
```

In another new terminal:
```bash
cd Frontend/flutter_application
flutter run -d chrome
```
---

## 👨‍💻 Author

Developed by **Fovian Aegis Team**  
VHack 2026 Submission