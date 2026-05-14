# 🧠 Sovereign Infra

<div align="center">
  <img src="https://raw.githubusercontent.com/kj-hilger/sovereign-agentic-orchestration-stack/main/docs/architecture/target_architecture.png" alt="Target Architecture Diagram" width="100%">
  <p><i>Architecture Overview: Deterministic Orchestration meets Intelligent Execution.</i></p>
</div>

## 🛑 Role
*   This repository acts as the Sovereign Foundation layer (K3s/Helm/PostgreSQL), representing the dashed boundary in the Target Architecture. It provides the physical and virtual environment for the cluster-gitops layer. By using architecture-specific bootstrap scripts, it enforces strict resource boundaries and ensures 100% data sovereignty on-premises.

*   **Status:** 🚧 Work in Progress

## ⚙️ Resource-Aware Deployment Environments

| Environment | Specs (Tested) | Infrastructure Focus                                                       |
| :--- | :--- |:---------------------------------------------------------------------------|
| **High-Power Desktop** | 64 GB RAM / 16 GB VRAM (RTX) | Full utilization for Heavy Load Testing, Large LLMs, Minikube with Web UI. |
| **Edge AI (Jetson)** | 16 GB Unified Memory (Orin Nano) | Strict RAM limits, Core Mode ArgoCD, Optimized Java Heap, K3s.             |
| **Minimal / Laptop** | 16 GB RAM (CPU only) | Resource pooling for Proof of Concept & Local Testing, K3s.                |

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

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
