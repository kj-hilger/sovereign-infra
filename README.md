# 🧠 Sovereign Infra

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


## 📊 Memory Budget Planning (Edge AI / 8GB)

To run the **Sovereign-Agentic-Orchestration-Stack** on a Jetson Orin Nano (8GB), strict memory limits are applied. Because of the **Unified Memory** architecture, CPU and GPU share the same 8GB pool.

| Component | Est. RAM Usage | Optimization Strategy |
| :--- | :--- | :--- |
| **K3s & OS Base** | 1.0 - 1.2 GB | Disabled Traefik, Service-LB, and local-storage. |
| **ArgoCD (Core)** | 0.4 - 0.6 GB | Running in **Core Mode** (no UI/Redis/Dex). |
| **Camunda 8 (BPMN)** | 2.5 - 3.0 GB | Tuned JVM Heap (`Xmx2G`) and disabled Web Modeler. |
| **AI Engine (Ollama)** | 3.2 - 3.5 GB | Limited to **4-bit Quantized Models** (Phi-3, Mistral q4). |

### 🛠️ Critical Performance Tuning
* **NVMe Swap:** A 4GB+ Swapfile on NVMe is mandatory to prevent OOM (Out-of-Memory) crashes during peak orchestration loads.
* **Z-RAM:** Enabled by default in the bootstrap script to compress memory pages.
* **Model Selection:** recommend is `phi3:mini` (2.2GB) or `mistral:7b-instruct-v0.2-q4_K_M` (4.1GB - borderline).

> [!CAUTION]
> Concurrent execution of complex BPMN workflows and heavy LLM inference can saturate the 8GB limit. Monitor via `jtop` or `kubectl top nodes`.
> 

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
