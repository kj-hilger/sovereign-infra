# 🏗️ Sovereign Infra

<div align="center">
  <img src="https://raw.githubusercontent.com/kj-hilger/sovereign-agentic-orchestration-stack/main/docs/target_architecture.png" alt="Target Architecture Diagram" width="100%">
  <p><i>Architecture Overview: Deterministic Orchestration meets Intelligent Execution.</i></p>
</div>

## 🛑 Role
*   This repository acts as the Sovereign Foundation layer (Kubernetes/Helm/PostgreSQL), representing the dashed boundary in the Target Architecture. It provides the physical and virtual environment for the cluster-gitops layer. By using architecture-specific bootstrap scripts, it enforces strict resource boundaries and ensures 100% data sovereignty on-premises.

### Infrastructure Guarantees
* **Sovereignty**: Local Kubernetes & RDBMS (PostgreSQL) without cloud leaks.
* **Hardware Efficiency**: Adaptive resource profiling (CPU/GPU/RAM) based on the selected bootstrap profile.

## ⚙️ Resource-Aware Deployment Environments

| Environment | Specs (Tested)                  | Infrastructure Focus                                                       |
| :--- |:--------------------------------|:---------------------------------------------------------------------------|
| **High-Power Desktop** | 64 GB RAM / 16 GB VRAM (RTX)    | Full utilization for Heavy Load Testing, Large LLMs, Minikube with Web UI. |
| **Edge AI (Jetson)** | 8 GB Unified Memory (Orin Nano) | Strict RAM limits, Core Mode ArgoCD, Optimized Java Heap, K3s.             |
| **Minimal / Laptop** | 16 GB RAM (CPU only)            | Resource pooling for Proof of Concept & Local Testing, K3s.                |

<img src="docs/sovereign-infra-jetson.jpg" width="400">

## Prerequisites
* **Package Manager:** `apt-get` (script tailored for Debian/Ubuntu-based distributions).
* **Programs:** `curl` and `git`.
* **Network:** Internet access during bootstrap to pull Docker images.

### x86_64 (Desktop)
* **Programs:** `gpg`, `sed`, `git` and `kubectl` (Must be installed natively on the host OS to interact with the cluster during and after execution).
* **NVIDIA Drivers & CUDA Toolkit:** Must be installed and functional on the host system. Verify this by running: `nvidia-smi`.

### Jetson / ARM64 (Edge Devices)
* **NVIDIA Drivers & CUDA Toolkit:** Must be installed and functional on the host system. Verify this by running: `nvidia-smi`.

### x86_64 (Laptop)
🚧 Status: Planned

## 🚀 Installation (Bootstrap)
- Download and execute the architecture-specific bootstrap script. This initializes the Kubernetes cluster, injects ArgoCD Core Mode, and applies CPU/GPU constraints.

### x86_64 (Desktop)

```bash
chmod +x install-x64-desktop.sh
./install-x64-desktop.sh
```

| Step | Description                                                                | Key Challenges                                                                                                                                                   |
|------|----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1    | NVIDIA Driver & CUDA Check                                                 | Drivers and CUDA toolkit must be manually installed on the host OS beforehand.                                                                                   |
| 2    | Installing & Configuring Docker                                            | Non-root user permissions require group modifications (`usermod`), often needing a full system logout/login before the user can interact with the Docker daemon. |
| 3    | NVIDIA Container Toolkit Config                                            | Must target the **host Docker engine** specifically via direct `/etc/docker/daemon.json` configuration, ensuring GPU runtime sharing into downstream containers. |
| 4    | Installing Minikube & Helm                                                 | Requires a separate, native `kubectl` installation on the host OS to prevent command-not-found errors during automated script execution.                         |
| 5    | Bootstrapping Minikube (Tuning)                                            | Enforces Docker runtime internally within the cluster to allow `--gpus=all`.                                                                                     |
| 6    | Installing ArgoCD                                                          | `--server-side` apply required, adds a desktop-specific patch to `NodePort` for direct access via the local web browser.                                         |

### Jetson / ARM64 (Edge Devices)

```bash
chmod +x install-arm64-k3s.sh
./install-arm64-k3s.sh
```

| Step | Description                                                                | Key Challenges                                                                                                                                                     |
|------|----------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0    | Boot Configuration & Cgroups Check                                         | Missing cgroup parameters cause memory crashes; requires reboot.                                                                                                   |
| 1    | Pre-Installation Checks                                                    | Verify Jetson hardware presence.                                                                                                                                   |
| 2    | Installing NVIDIA Container Runtime & Network Config (containerd, flannel) | CRI unblocking and preconfiguring CNI for a stable network; aligning container runtimes with system‑wide containerd + NVIDIA runtime.                              |
| 3    | Installing K3s                                                             | None specific; standard K3s install using containerd endpoint.                                                                                                     |
| 4    | Enabling NVIDIA GPU Support in Kubernetes                                  | The Kubernetes resources for Nvidia Device Plugin fail on Jetson due to PCI‑based affinity and memory management issues, thus patches and enhancements are needed. |
| 5    | Installing ArgoCD                                                          | Annotation limits for large manifests; requires server‑side apply.                                                                                                 |
| 6    | Resource Optimization                                                      | Minimizing log overhead and saving unified memory.                                                                                                                 |
| 7    | Verification                                                               | Final checks; ensure GPU registration and node allocatable resources.                                                                                              |

### x86_64 (Laptop)
```bash
chmod +x install-x64-laptop.sh
./install-x64-laptop.sh
```

🚧 Status: Planned

## Post-Installation
* The installation configures Docker to run without `sudo` for the current user. If you encounter permission issues during the Minikube bootstrap, you may need to **log out and log back in** to apply the user group changes.
* Docker and Nvidia Toolkit will be updated via apt Package Manager.

## Delete All and Reinstall (with latest software versions)

### x86_64 (Desktop)
* Execute: `minikube delete --all --purge`
* Reboot
* run script again

### Jetson / ARM64 (Edge Devices)
* Execute: `sudo /usr/local/bin/k3s-uninstall.sh`
* Reboot
* run script again

### x86_64 (Laptop)
🚧 Status: Planned

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
