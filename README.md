# NemoClaw on DGX Spark

# Choosing a model (for 128GB DGX Spark)

## Best starting point for NemoClaw

```
ollama pull gpt-oss:20b
```

This is the sweet spot for the DGX Spark — NVIDIA's own open model, purpose-built for agentic tasks,
and runs in MXFP4 format with full FP4 hardware acceleration on the GB10 Blackwell chip.
You'll get around **58 tok/s decode** which is fast and responsive for an always-on assistant.

However, the Spark's real superpower over the Orin is that it has enough memory to run much larger
models. If you want higher quality reasoning, step up to `gpt-oss:120b` — the entire 120B model fits
in the Spark's 128GB unified memory and still delivers **~41 tok/s**, which is remarkable for a model
that size. If `gpt-oss:20b` feels slow or you want something snappier, drop down to `llama3.1:8b`
which hits **~38 tok/s** and is extremely responsive. And if you just want to smoke-test your NemoClaw
setup before pulling a large model, grab `gemma3:12b` — good quality and fast to pull.

---

## What runs well on DGX Spark

> ⚠️ **Dense models are slow on Spark.** The bottleneck is memory bandwidth (273 GB/s LPDDR5x),
> not compute. MoE models (gpt-oss, qwen3:30b-a3b, nemotron-3-nano:30b) activate only a fraction
> of their parameters per token and run dramatically faster than equivalently-sized dense models.
> A 120B MoE can easily outrun a 27B dense model on this hardware.

| Model | Pull Command | Size | Decode tok/s | Notes |
|---|---|---|---|---|
| `gpt-oss:20b` | `ollama pull gpt-oss:20b` | 13 GB | ~58 | ⭐ Best NemoClaw default — fast, agentic, MXFP4 |
| `gpt-oss:120b` | `ollama pull gpt-oss:120b` | 65 GB | ~41 | ⭐ Spark's killer feature — full 120B in memory, still fast |
| `llama3.1:8b` | `ollama pull llama3.1:8b` | 4.9 GB | ~38 | Fastest option, great for quick tasks |
| `deepseek-r1:14b` | `ollama pull deepseek-r1:14b` | 9 GB | ~20 | Good reasoning/thinking model |
| `gemma3:12b` | `ollama pull gemma3:12b` | 8 GB | ~24 | Good general assistant, fast to pull |
| `nemotron-3-nano:30b` | `ollama pull nemotron-3-nano:30b` | 24 GB | est. ~35–45 | MoE, only activates ~3B params/token, 1M context |
| `nemotron-3-nano:30b-a3b-q8_0` | `ollama pull nemotron-3-nano:30b-a3b-q8_0` | 34 GB | est. ~25–35 | Higher quality quant of the 30B |
| `qwen3:14b` | `ollama pull qwen3:14b` | 9 GB | est. ~30–40 | Strong reasoning and tool use |
| `qwen3:30b-a3b` | `ollama pull qwen3:30b-a3b` | 19 GB | est. ~35–45 | MoE, efficient, great for agents |
| `phi4:14b` | `ollama pull phi4:14b` | 9 GB | est. ~30–40 | Microsoft, strong reasoning for its size |
| `llama3.1:70b` | `ollama pull llama3.1:70b` | 40 GB | ~4.4 | ⚠️ Fits but slow — dense model hits bandwidth wall |
| `gemma3:27b` | `ollama pull gemma3:27b` | 17 GB | ~11 | ⚠️ Dense model, slower than size suggests |
| `qwen3:32b` | `ollama pull qwen3:32b` | 20 GB | ~9.4 | ⚠️ Dense, slow — prefer qwen3:30b-a3b instead |

---

## Models to avoid on Spark (or use with expectations set)

| Model | Reason |
|---|---|
| `deepseek-r1:32b` | Dense — will be slow (~8–10 tok/s estimated) |
| `gemma3:27b-q8_0` | Dense q8 — drops to ~7 tok/s per official benchmarks |
| `llama3.1:70b-q8_0` | Too large and dense — will crawl |
| Any dense model >30B at q8_0 | LPDDR5x bandwidth is the hard ceiling |

---

## Best picks for NemoClaw on DGX Spark

**Daily driver (fast + capable):**
```
ollama pull gpt-oss:20b
```

**Step up (best quality that still fits in memory, Spark's unique advantage):**
```
ollama pull gpt-oss:120b
```

**Snappy/lightweight:**
```
ollama pull llama3.1:8b
```

---

> Decode tok/s figures marked with official Ollama benchmarks are from firmware 580.95.05 + Ollama v0.12.6.
> Figures marked "est." are extrapolated from llama.cpp community benchmarks and may vary with firmware updates.
> Make sure your firmware is up to date — NVIDIA's CES 2026 update delivered up to 2.5× improvement
> on some workloads via TensorRT-LLM and speculative decoding optimizations.