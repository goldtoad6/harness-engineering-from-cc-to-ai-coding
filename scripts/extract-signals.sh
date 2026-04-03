#!/usr/bin/env bash
# extract-signals.sh — 从 Claude Code cli.js bundle 中提取可观测信号
#
# 用法:
#   ./scripts/extract-signals.sh <cli.js> [--json]
#   ./scripts/extract-signals.sh <cli.js> --section tengu|env|growthbook|tools|api
#
# 输出: 结构化文本报告（默认）或 JSON
#
# 可提取的信号类型：
#   1. tengu_* 事件名（遥测事件）
#   2. CLAUDE_CODE_* 环境变量
#   3. GrowthBook 配置名（tengu_*_config）
#   4. 工具名（从工具注册代码中提取）
#   5. API 端点路径
#   6. 版本元数据（VERSION, BUILD_TIME）

set -euo pipefail

# ──────────────────────────────────────────────
# 参数解析
# ──────────────────────────────────────────────

CLI_JS=""
OUTPUT_FORMAT="text"
SECTION="all"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      OUTPUT_FORMAT="json"
      shift
      ;;
    --section)
      SECTION="$2"
      shift 2
      ;;
    -h|--help)
      echo "用法: $0 <cli.js> [--json] [--section tengu|env|growthbook|tools|api|meta]"
      echo ""
      echo "从 Claude Code bundle 中提取可观测信号"
      echo ""
      echo "选项:"
      echo "  --json              输出 JSON 格式"
      echo "  --section <name>    只提取指定类型的信号"
      echo "  -h, --help          显示帮助"
      exit 0
      ;;
    *)
      CLI_JS="$1"
      shift
      ;;
  esac
done

if [[ -z "$CLI_JS" ]]; then
  echo "错误: 请提供 cli.js 文件路径" >&2
  echo "用法: $0 <cli.js> [--json] [--section tengu|env|growthbook|tools|api|meta]" >&2
  exit 1
fi

if [[ ! -f "$CLI_JS" ]]; then
  echo "错误: 文件不存在: $CLI_JS" >&2
  exit 1
fi

# ──────────────────────────────────────────────
# 提取函数
# ──────────────────────────────────────────────

extract_tengu_events() {
  grep -oE 'tengu_[a-z_]+' "$CLI_JS" | sort -u
}

extract_env_vars() {
  grep -oE 'CLAUDE_CODE_[A-Z_]+' "$CLI_JS" | sort -u
}

extract_growthbook_configs() {
  # GrowthBook 配置名通常在引号中，以 _config 结尾
  grep -oE '"tengu_[a-z_]+_config"' "$CLI_JS" | tr -d '"' | sort -u
}

extract_tool_names() {
  # 工具名模式：类名以 Tool 结尾，或在工具注册中出现
  # 模式1: "name":"ToolName" 风格的工具注册
  grep -oE '"(Bash|Read|Write|Edit|Glob|Grep|Agent|WebSearch|WebFetch|Skill|MCP|Task[A-Za-z]*|EnterPlanMode|ExitPlanMode|EnterWorktree|ExitWorktree|AskUserQuestion|SendMessage|NotebookEdit|LSP|REPL|Config|Sleep|Team[A-Za-z]*|Cron[A-Za-z]*|Workflow|Monitor|ToolSearch|PowerShell|TestingPermission)[A-Za-z]*"' "$CLI_JS" | tr -d '"' | sort -u
  # 模式2: Tool 后缀的类定义
  grep -oE '[A-Z][a-zA-Z]+Tool\b' "$CLI_JS" | sort -u | grep -v 'baseTool\|mcpTool'
}

extract_api_endpoints() {
  # API 路径模式
  grep -oE '"/v[0-9]/[a-z_/]+"' "$CLI_JS" | tr -d '"' | sort -u
  grep -oE '"/api/[a-z_/]+"' "$CLI_JS" | tr -d '"' | sort -u
}

extract_metadata() {
  local file_size
  file_size=$(wc -c < "$CLI_JS" | tr -d ' ')

  # 尝试提取版本信息：先从同目录的 package.json，再从 cli.js 自身
  local version="unknown"
  local pkg_json="$(dirname "$CLI_JS")/package.json"
  if [[ -f "$pkg_json" ]]; then
    version=$(grep -oE '"version"[[:space:]]*:[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"' "$pkg_json" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
  fi
  if [[ "$version" == "unknown" ]]; then
    version=$(grep -oE '"version":"[0-9]+\.[0-9]+\.[0-9]+"' "$CLI_JS" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
  fi

  # 检查是否有 source map
  local has_sourcemap="no"
  if grep -q 'sourceMappingURL' "$CLI_JS"; then
    has_sourcemap="yes"
  fi

  echo "file_size:$file_size"
  echo "version:$version"
  echo "has_sourcemap:$has_sourcemap"
}

# ──────────────────────────────────────────────
# 分类函数（将 tengu 事件按子系统分类）
# ──────────────────────────────────────────────

categorize_tengu() {
  local events="$1"

  echo "## 按子系统分类"
  echo ""

  local categories=(
    "api:tengu_api_"
    "auth:tengu_auth_|tengu_oauth_|tengu_api_key_"
    "tool:tengu_tool_|tengu_bash_|tengu_file_|tengu_edit_|tengu_glob_|tengu_grep_"
    "agent:tengu_agent_|tengu_forked_agent_|tengu_sub_"
    "mcp:tengu_mcp_"
    "compact:tengu_compact_|tengu_autocompact_|tengu_cold_compact|tengu_sm_compact"
    "cache:tengu_prompt_cache_|tengu_cache_"
    "hook:tengu_hook_|tengu_pre_tool_hook"
    "permission:tengu_permission_|tengu_yolo_"
    "analytics:tengu_event_|tengu_init|tengu_shutdown"
    "session:tengu_session_|tengu_conversation_"
    "ui:tengu_accept_|tengu_dialog_|tengu_feedback_|tengu_survey_"
    "bridge:tengu_bridge_"
    "model:tengu_model_|tengu_rate_limit_"
    "memory:tengu_memory_|tengu_extract_memor"
    "task:tengu_task_"
    "kairos:tengu_kairos_"
    "powerup:tengu_powerup_"
    "git:tengu_git_|tengu_commit_|tengu_pr_"
  )

  local categorized=""

  for cat_pattern in "${categories[@]}"; do
    local cat_name="${cat_pattern%%:*}"
    local pattern="${cat_pattern#*:}"
    local matches
    matches=$(echo "$events" | grep -E "$pattern" || true)
    local count=0
    if [[ -n "$matches" ]]; then
      count=$(echo "$matches" | wc -l | tr -d ' ')
    fi

    if [[ "$count" -gt 0 ]]; then
      echo "### $cat_name ($count)"
      echo "$matches" | sed 's/^/  - /'
      echo ""
      categorized="${categorized}${matches}"$'\n'
    fi
  done

  # 未分类的事件
  local uncategorized
  uncategorized=$(echo "$events" | grep -vF "$(echo "$categorized" | sort -u)" | grep -v '^$' || true)
  local uncat_count=0
  if [[ -n "$uncategorized" ]]; then
    uncat_count=$(echo "$uncategorized" | wc -l | tr -d ' ')
  fi

  if [[ "$uncat_count" -gt 0 ]]; then
    echo "### uncategorized ($uncat_count)"
    echo "$uncategorized" | sed 's/^/  - /'
    echo ""
  fi
}

# ──────────────────────────────────────────────
# 输出
# ──────────────────────────────────────────────

output_text() {
  local meta
  meta=$(extract_metadata)
  local file_size version has_sourcemap
  file_size=$(echo "$meta" | grep 'file_size:' | cut -d: -f2)
  version=$(echo "$meta" | grep 'version:' | cut -d: -f2)
  has_sourcemap=$(echo "$meta" | grep 'has_sourcemap:' | cut -d: -f2)

  echo "# Claude Code 信号提取报告"
  echo ""
  echo "- 文件: $(basename "$CLI_JS")"
  echo "- 大小: $file_size bytes ($(echo "scale=1; $file_size / 1048576" | bc)MB)"
  echo "- 版本: $version"
  echo "- Source Map: $has_sourcemap"
  echo "- 提取时间: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo ""

  if [[ "$SECTION" == "all" || "$SECTION" == "tengu" ]]; then
    local tengu_events
    tengu_events=$(extract_tengu_events)
    local tengu_count
    tengu_count=$(echo "$tengu_events" | wc -l | tr -d ' ')
    echo "---"
    echo ""
    echo "# 1. Tengu 事件 ($tengu_count 个)"
    echo ""
    categorize_tengu "$tengu_events"
  fi

  if [[ "$SECTION" == "all" || "$SECTION" == "env" ]]; then
    local env_vars
    env_vars=$(extract_env_vars)
    local env_count
    env_count=$(echo "$env_vars" | wc -l | tr -d ' ')
    echo "---"
    echo ""
    echo "# 2. 环境变量 ($env_count 个)"
    echo ""
    echo "$env_vars" | sed 's/^/- /'
    echo ""
  fi

  if [[ "$SECTION" == "all" || "$SECTION" == "growthbook" ]]; then
    local gb_configs
    gb_configs=$(extract_growthbook_configs)
    local gb_count
    gb_count=$(echo "$gb_configs" | grep -c . 2>/dev/null || echo "0")
    echo "---"
    echo ""
    echo "# 3. GrowthBook 配置 ($gb_count 个)"
    echo ""
    echo "$gb_configs" | sed 's/^/- /'
    echo ""
  fi

  if [[ "$SECTION" == "all" || "$SECTION" == "tools" ]]; then
    local tools
    tools=$(extract_tool_names)
    local tool_count
    tool_count=$(echo "$tools" | sort -u | wc -l | tr -d ' ')
    echo "---"
    echo ""
    echo "# 4. 工具名 ($tool_count 个)"
    echo ""
    echo "$tools" | sort -u | sed 's/^/- /'
    echo ""
  fi

  if [[ "$SECTION" == "all" || "$SECTION" == "api" ]]; then
    local endpoints
    endpoints=$(extract_api_endpoints)
    local ep_count
    ep_count=$(echo "$endpoints" | grep -c . 2>/dev/null || echo "0")
    echo "---"
    echo ""
    echo "# 5. API 端点 ($ep_count 个)"
    echo ""
    echo "$endpoints" | sed 's/^/- /'
    echo ""
  fi
}

output_json() {
  local meta
  meta=$(extract_metadata)
  local file_size version has_sourcemap
  file_size=$(echo "$meta" | grep 'file_size:' | cut -d: -f2)
  version=$(echo "$meta" | grep 'version:' | cut -d: -f2)
  has_sourcemap=$(echo "$meta" | grep 'has_sourcemap:' | cut -d: -f2)

  echo "{"
  echo "  \"file\": \"$(basename "$CLI_JS")\","
  echo "  \"size_bytes\": $file_size,"
  echo "  \"version\": \"$version\","
  echo "  \"has_sourcemap\": $([ "$has_sourcemap" = "yes" ] && echo "true" || echo "false"),"
  echo "  \"extracted_at\": \"$(date -u '+%Y-%m-%dT%H:%M:%SZ')\","

  if [[ "$SECTION" == "all" || "$SECTION" == "tengu" ]]; then
    echo "  \"tengu_events\": ["
    extract_tengu_events | sed 's/^/    "/;s/$/"/' | paste -sd',' - | sed 's/,/,\n/g'
    echo "  ],"
  fi

  if [[ "$SECTION" == "all" || "$SECTION" == "env" ]]; then
    echo "  \"env_vars\": ["
    extract_env_vars | sed 's/^/    "/;s/$/"/' | paste -sd',' - | sed 's/,/,\n/g'
    echo "  ],"
  fi

  if [[ "$SECTION" == "all" || "$SECTION" == "growthbook" ]]; then
    echo "  \"growthbook_configs\": ["
    extract_growthbook_configs | sed 's/^/    "/;s/$/"/' | paste -sd',' - | sed 's/,/,\n/g'
    echo "  ],"
  fi

  if [[ "$SECTION" == "all" || "$SECTION" == "tools" ]]; then
    echo "  \"tools\": ["
    extract_tool_names | sort -u | sed 's/^/    "/;s/$/"/' | paste -sd',' - | sed 's/,/,\n/g'
    echo "  ],"
  fi

  if [[ "$SECTION" == "all" || "$SECTION" == "api" ]]; then
    echo "  \"api_endpoints\": ["
    extract_api_endpoints | sed 's/^/    "/;s/$/"/' | paste -sd',' - | sed 's/,/,\n/g'
    echo "  ]"
  fi

  echo "}"
}

# ──────────────────────────────────────────────
# 主入口
# ──────────────────────────────────────────────

if [[ "$OUTPUT_FORMAT" == "json" ]]; then
  output_json
else
  output_text
fi
