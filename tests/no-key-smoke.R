library(LLMCellType)

# Never touch the network: clear every provider key first.
Sys.setenv(OPENAI_API_KEY = "", ANTHROPIC_API_KEY = "",
           GOOGLE_API_KEY = "", GEMINI_API_KEY = "")

gs <- list(gs1 = c("CD4", "CD3D"), gs2 = "CD14")
prompt_ok <- function(x) {
  is.character(x) && length(x) == 1 && grepl("^Identify cell types of", x)
}

# No API key: every keyed provider returns the prompt itself.
for (p in c("openai", "anthropic", "gemini")) {
  res <- llmcelltype(gs, tissuename = "PBMC", provider = p)
  if (!prompt_ok(res)) {
    stop("provider ", p, ": no-key run did not return the prompt")
  }
}

# Ollama without a model must stop before any server contact.
err <- tryCatch({
  llmcelltype(gs, provider = "ollama")
  NULL
}, error = function(e) conditionMessage(e))
if (is.null(err) || !grepl("requires a model", err)) {
  stop("provider ollama: expected a clear missing-model error")
}

# gptcelltype() alias returns the byte-identical legacy prompt string.
legacy <- paste0(
  "Identify cell types of PBMC cells using the following markers separately for each\n",
  " row. Only provide the cell type name. Do not show numbers before the name.\n",
  " Some can be a mixture of multiple cell types. ", "\n",
  paste0(names(gs), ":", unlist(lapply(gs, paste, collapse = ",")), collapse = "\n")
)
res_alias <- gptcelltype(gs, tissuename = "PBMC")
if (!identical(res_alias, legacy)) {
  stop("gptcelltype() no longer returns the legacy prompt string")
}
if (!identical(res_alias, llmcelltype(gs, tissuename = "PBMC", provider = "openai"))) {
  stop("gptcelltype() alias does not match llmcelltype(provider = 'openai')")
}

# Seurat marker data.frame input path (list-free) works offline too.
df <- data.frame(
  avg_log2FC = c(2, 1.5, 3, 0.5, -0.2),
  gene = c("CD4", "CD3D", "CD14", "CD8A", "FCGR3A"),
  cluster = c("0", "0", "0", "1", "1")
)
res_df <- llmcelltype(df, tissuename = "PBMC", provider = "openai")
if (!prompt_ok(res_df) || !grepl("0:CD4", res_df) || !grepl("1:CD8A", res_df)) {
  stop("data.frame input: no-key run did not return the expected prompt")
}
