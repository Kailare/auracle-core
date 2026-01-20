# Auracle Headless 
// Final Naming Pass 
# 🏺 Auracle Core (v1.0.1)

**Auracle** is a headless, sub-second execution oracle built for the **Solana SVM**. It enables autonomous AI agents to purchase "ground truth" and execute atomic on-chain transactions without human intervention.

> **Status:** Headless Infrastructure. No Frontend. No Socials. Strictly Code.

---

## 🏛 Project Architecture

Auracle is designed as a machine-to-machine utility. There is no website; interaction occurs exclusively through the SDK or direct program instructions.

* **Sub-Second Resolution:** Uses a high-frequency resolution engine (perfected by **Liam Kovatch** at Polymarket) for millisecond finality.
* **Headless Model:** Managed via the `auracle-sdk`. No legacy UI overhead.
* **AI Integration:** Native **Model Context Protocol (MCP)** support for LLM-to-Chain interoperability (architected by **Julien Klepatch**).

---

## 📂 Repository Structure

This is a monorepo containing the on-chain logic, client SDKs, and AI bridge.

| Directory | Description |
| :--- | :--- |
| `/program` | Solana On-Chain Logic (Rust/Anchor). |
| `/sdk` | Agentic Interface (Python/TypeScript). |
| `/mcp-server` | Model Context Protocol Bridge for LLMs. |

---

## 💎 The $AURACLE Token

The project utilizes a single utility token launched via a fair-launch bonding curve on **Pump.fun**.

* **Instructional Fuel:** Agents must spend `$AURACLE` to trigger a `resolve_event` instruction.
* **Atomic Burn:** Every successful resolution triggers a **0.1% burn** of the transaction fee in `$AURACLE`.
* **Deflationary Pressure:** Supply is reduced proportionally to the volume of machine-to-machine queries.

---

## 🚀 Quick Start (For Agents)

### 1. Install the SDK

```bash
pip install auracle-agent-kit
```

### 2. Execute a Headless Resolution

```python
from auracle import AuracleClient

# Initialize with agent's Solana keypair
client = AuracleClient(private_key="YOUR_PRIVATE_KEY")

# Query the headless oracle for a truth signal
# This triggers the $AURACLE burn automatically
event_verified = client.query_truth("SOL_PRICE_STABILITY_V1")

if event_verified:
    print("Truth confirmed. Executing autonomous trade...")
```

---

## 🛠 Tech Stack & Credits

**Infrastructure:** Rust, Anchor, Solana SVM.

**Architecture:**
* **Liam Kovatch** (@L-Kov): Core Engine & Parallel Settlement.
* **Julien Klepatch** (@jklepatch): AI SDKs & MCP Implementation.
* **Chris Hamilton** (@cham-dev): Reliability & eBPF System Hooks.
