LLMCellType: Automatic cell type annotation with large language models
====

This is a fork of the original [gptcelltype](https://github.com/Winnie09/GPTCelltype) package. Now it supports multiple providers, including OpenAI GPT, Anthropic Claude, Google Gemini, and local models served by Ollama.

## Installation

To install the latest version of the LLMCellType package via Github, run the following commands in R:
```{r eval = FALSE}
remotes::install_github("pwwang/LLMCellType")
```

## 🚀 Quick start with Seurat pipeline

```{r eval = FALSE}

# IMPORTANT! Assign the API key of your provider. See Vignette for details
Sys.setenv(OPENAI_API_KEY = 'your_openai_API_key')          # OpenAI
# Sys.setenv(ANTHROPIC_API_KEY = 'your_anthropic_API_key')   # Anthropic
# Sys.setenv(GOOGLE_API_KEY = 'your_gemini_API_key')         # Google Gemini

# Load packages
library(LLMCellType)

# Assume you have already run the Seurat pipeline https://satijalab.org/seurat/
# "obj" is the Seurat object; "markers" is the output from FindAllMarkers(obj)
# Cell type annotation by an LLM (default provider: OpenAI)
res <- llmcelltype(markers, tissuename = 'human PBMC')
# Other providers, e.g. a local Ollama server:
# res <- llmcelltype(markers, tissuename = 'human PBMC', provider = 'ollama', model = 'llama3.1')

# Assign cell type annotation back to Seurat object
obj@meta.data$celltype <- as.factor(res[as.character(Idents(obj))])

# Visualize cell type annotation on UMAP
DimPlot(obj,group.by='celltype')
```

## Supported providers

| provider      | API key environment variable | Default model (when `model = NULL`)          |
|---------------|------------------------------|----------------------------------------------|
| openai        | `OPENAI_API_KEY`             | OpenAI default (see `ellmer::chat_openai`)   |
| anthropic     | `ANTHROPIC_API_KEY`          | Anthropic default (see `ellmer::chat_anthropic`) |
| gemini        | `GOOGLE_API_KEY` or `GEMINI_API_KEY` | Google default (see `ellmer::chat_google_gemini`) |
| ollama        | none (local server)          | required, e.g. `model = 'llama3.1'`          |

Any OpenAI-compatible endpoint (OpenRouter, DeepSeek, local servers, ...) can be
used with `provider = 'openai'` plus a custom `base_url`. If no API key is
available, the prompt itself is returned, which can be pasted into the chat UI
of your provider.

`gptcelltype()` is retained as an alias for `llmcelltype(provider = 'openai')`.
