# 🏗️ Sovereign Infra

<div align="center">
  <img src="https://raw.githubusercontent.com/kj-hilger/sovereign-agentic-orchestration-stack/main/docs/architecture/target_architecture.png" alt="Target Architecture Diagram" width="100%">
  <p><i>Architecture Overview: Deterministic Orchestration meets Intelligent Execution.</i></p>
</div>

## 🛑 Role
*   This repository acts as the Sovereign Foundation layer (K3s/Helm/PostgreSQL), representing the dashed boundary in the Target Architecture. It provides the physical and virtual environment for the cluster-gitops layer. By using architecture-specific bootstrap scripts, it enforces strict resource boundaries and ensures 100% data sovereignty on-premises.

*   **Status:** 🚧 Work in Progress

## ⚙️ Resource-Aware Deployment Environments

| Environment | Specs (Tested)                  | Infrastructure Focus                                                       |
| :--- |:--------------------------------|:---------------------------------------------------------------------------|
| **High-Power Desktop** | 64 GB RAM / 16 GB VRAM (RTX)    | Full utilization for Heavy Load Testing, Large LLMs, Minikube with Web UI. |
| **Edge AI (Jetson)** | 8 GB Unified Memory (Orin Nano) | Strict RAM limits, Core Mode ArgoCD, Optimized Java Heap, K3s.             |
| **Minimal / Laptop** | 16 GB RAM (CPU only)            | Resource pooling for Proof of Concept & Local Testing, K3s.                |

## 🚀 Installation (Bootstrap)

### Preparation
Ensure a Linux OS with package manager apt-get is installed on your device. Verify `curl`, `git`, and (for GPU nodes) NVIDIA drivers are present.

### Execution
Download and execute the architecture-specific bootstrap script. This initializes K3s, injects ArgoCD Core Mode, and applies CPU/GPU constraints.

🔹 x86_64 (Desktop)
```bash
chmod +x install-x64-desktop.sh
./install-x64-desktop.sh
```

🔹 Jetson / ARM64 (Edge Devices)
```bash
chmod +x install-arm64-k3s.sh
./install-arm64-k3s.sh
```

🔹 x86_64 (Laptop)
```bash
chmod +x install-x64-laptop.sh
./install-x64-laptop.sh
```

### 🔧 Infrastructure Guarantees
* Sovereignty: Local Kubernetes & RDBMS (PostgreSQL) without cloud leaks.
* Hardware Efficiency: Adaptive resource profiling (CPU/GPU/RAM) based on the selected bootstrap profile.

### ⚠️ Critical Constraints
* GPU Acceleration: Requires NVIDIA CUDA toolkit installation prior to cluster bootstrap.

## 🏗️ Hardware Architecture: Sovereign-Edge-Node

To achieve full digital sovereignty and air-gapped autonomy for the **Sovereign-Agentic-Orchestration-Stack**, the following hardware specification is utilized. This setup is optimized for mobile field-testing and local AI inference.

### 💻 Core Compute Module
* **Processor:** NVIDIA Jetson Orin Nano Super Developer Kit (67 TOPS AI Performance).
* **Memory:** 8GB 128-bit LPDDR5 (Unified Memory Architecture).
* **Networking:** Air-Gapped by design (No WAN/Cloud dependency).
* **Cooling:** Active PWM-Fan (Mandatory for concurrent VGG16 & Ollama workloads).
* **Power:** CR1220 Battery for local RTC timestamp persistence in air-gapped environments.

### 🔋 Mobile Power Solution
* **Power Source:** High-Capacity Powerbank (USB-C PD 3.0 / 45W+ recommended).
    * *Purpose:* Sustaining high-peak AI inference loads.
    * *Connectivity:* DC-Jack or USB-C Power Delivery to ensure stable voltage for the Orin Nano.
    * *Mobility:* Enables 100% untethered operation.

### 👁️ Vision & Feedback Layer
* **Sensor:** Waveshare IMX219-170 (8MP, 170° Ultra-Wide FOV).
    * *Purpose:* High-resolution group capture and individual cropping for Re-ID.
    * *Interface:* 15-pin FFC (CSI-Port).
* **Interaction:** 2.42" OLED Display (128×64, SPI/I2C).
    * *Purpose:* Real-time agent status and "Walking-Guide" instructions from Camunda.

### ⚡ Performance & Storage
* **Primary Storage:** WD_BLACK™ SN770 250GB NVMe SSD (Gen4, 4000 MB/s Read).
    * *Role:* Critical for high-speed **Swap-File** performance and local image database.
* **Enclosure:** KKSB Jetson Orin Nano Case (Steel, optimized for thermal dissipation and rail-mounting).

---

## 📊 Memory Budget Planning (Edge AI / 8GB)

To run the **Sovereign-Agentic-Orchestration-Stack** on a Jetson Orin Nano (8GB), strict memory limits are applied. Because of the **Unified Memory** architecture, CPU and GPU share the same 8GB pool.

| Component | Est. RAM Usage | Optimization Strategy |
| :--- | :--- | :--- |
| **K3s & OS Base** | 1.0 - 1.2 GB | Disabled Traefik, Service-LB, and local-storage. |
| **ArgoCD (Core)** | 0.4 - 0.6 GB | Running in **Core Mode** (no UI/Redis/Dex). |
| **Camunda 8 (BPMN)**| 2.0 - 2.5 GB | Tuned JVM Heap (`Xmx1.5G`), Task-Workers limited. |
| **VGG16 Classifier**| 0.5 - 0.8 GB | **TensorRT** optimization for edge-specific inference. |
| **AI Engine (Ollama)**| 3.0 - 3.5 GB | Limited to **4-bit Quantized Models** (Phi-3, Moondream2). |

### 🛠️ Critical Performance Tuning
* **NVMe Swap:** A 6GB+ Swapfile on the **WD_BLACK SN770** is mandatory. The high IOPS and PCIe Gen4 speed minimize latency during memory pressure.
* **TensorRT Engine:** Pre-compiling the VGG16 model into a TensorRT engine is required to fit the identification task alongside the Camunda/Ollama stack.
* **Power Management:** Use `nvpmodel -m 0` (MAXN mode) only when connected to the 45W Powerbank to ensure the CPU/GPU don't throttle during identification.
* **Visual Feedback:** The 2.42" OLED display provides critical "OOM-Warnings" before the Linux OOM-Killer terminates K3s pods.

> [!CAUTION]
> Running the 170° camera stream at full resolution (8MP) while Ollama is inferencing will hit the bandwidth limit of the memory bus. Use lower-resolution streams for motion detection and trigger high-res snapshots only for identification.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
