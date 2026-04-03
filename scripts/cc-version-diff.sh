#!/usr/bin/env bash
# cc-version-diff.sh — Claude Code 版本差异分析脚本
#
# 用法:
#   ./scripts/cc-version-diff.sh <old.tgz> <new.tgz>
#   ./scripts/cc-version-diff.sh <new.tgz>                  # 自动与 v2.1.88 基线对比
#   ./scripts/cc-version-diff.sh <old.tgz> <new.tgz> -o report.md
#
# 输出: 结构化 Markdown 差异报告

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ──────────────────────────────────────────────
# 参数解析
# ──────────────────────────────────────────────

OLD_TGZ=""
NEW_TGZ=""
OUTPUT_FILE=""
BASELINE_TGZ="$PROJECT_DIR/claude-code-2.1.88.tgz"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    -h|--help)
      echo "用法: $0 <old.tgz> <new.tgz> [-o output.md]"
      echo "   或: $0 <new.tgz>              (自动与 v2.1.88 基线对比)"
      echo ""
      echo "生成两个 Claude Code 版本之间的结构化差异报告"
      echo ""
      echo "选项:"
      echo "  -o, --output <file>   输出到指定文件（默认 stdout）"
      echo "  -h, --help            显示帮助"
      exit 0
      ;;
    *)
      if [[ -z "$OLD_TGZ" ]]; then
        OLD_TGZ="$1"
      elif [[ -z "$NEW_TGZ" ]]; then
        NEW_TGZ="$1"
      else
        echo "错误: 参数过多" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

# 单参数模式：用基线作为 old
if [[ -n "$OLD_TGZ" && -z "$NEW_TGZ" ]]; then
  NEW_TGZ="$OLD_TGZ"
  OLD_TGZ="$BASELINE_TGZ"
  if [[ ! -f "$OLD_TGZ" ]]; then
    echo "错误: 基线文件不存在: $OLD_TGZ" >&2
    echo "请提供两个 tarball 路径，或确保项目根目录有 claude-code-2.1.88.tgz" >&2
    exit 1
  fi
fi

if [[ -z "$OLD_TGZ" || -z "$NEW_TGZ" ]]; then
  echo "错误: 请提供至少一个 tarball 路径" >&2
  echo "用法: $0 <old.tgz> <new.tgz> [-o output.md]" >&2
  exit 1
fi

for f in "$OLD_TGZ" "$NEW_TGZ"; do
  if [[ ! -f "$f" ]]; then
    echo "错误: 文件不存在: $f" >&2
    exit 1
  fi
done

# ──────────────────────────────────────────────
# 工作目录准备
# ──────────────────────────────────────────────

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

OLD_DIR="$WORK_DIR/old"
NEW_DIR="$WORK_DIR/new"
mkdir -p "$OLD_DIR" "$NEW_DIR"

echo "解压 old: $(basename "$OLD_TGZ")..." >&2
tar xzf "$OLD_TGZ" -C "$OLD_DIR"
echo "解压 new: $(basename "$NEW_TGZ")..." >&2
tar xzf "$NEW_TGZ" -C "$NEW_DIR"

# 定位 package 目录（tarball 内通常是 package/）
OLD_PKG="$OLD_DIR/package"
NEW_PKG="$NEW_DIR/package"

if [[ ! -d "$OLD_PKG" ]]; then
  echo "错误: old tarball 中未找到 package/ 目录" >&2
  exit 1
fi
if [[ ! -d "$NEW_PKG" ]]; then
  echo "错误: new tarball 中未找到 package/ 目录" >&2
  exit 1
fi

# ──────────────────────────────────────────────
# 版本信息提取
# ──────────────────────────────────────────────

old_version() {
  grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' "$OLD_PKG/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

new_version() {
  grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' "$NEW_PKG/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

OLD_VER=$(old_version)
NEW_VER=$(new_version)

# ──────────────────────────────────────────────
# 信号提取函数
# ──────────────────────────────────────────────

extract_tengu() {
  grep -oE 'tengu_[a-z_]+' "$1" | sort -u
}

extract_env() {
  grep -oE 'CLAUDE_CODE_[A-Z_]+' "$1" | sort -u
}

extract_growthbook() {
  grep -oE '"tengu_[a-z_]+_config"' "$1" | tr -d '"' | sort -u
}

file_size_mb() {
  local bytes
  bytes=$(wc -c < "$1" | tr -d ' ')
  echo "scale=1; $bytes / 1048576" | bc
}

file_size_bytes() {
  wc -c < "$1" | tr -d ' '
}

# ──────────────────────────────────────────────
# 差异计算
# ──────────────────────────────────────────────

echo "提取信号..." >&2

# Tengu 事件差异
OLD_TENGU="$WORK_DIR/old_tengu.txt"
NEW_TENGU="$WORK_DIR/new_tengu.txt"
extract_tengu "$OLD_PKG/cli.js" > "$OLD_TENGU"
extract_tengu "$NEW_PKG/cli.js" > "$NEW_TENGU"

TENGU_ADDED="$WORK_DIR/tengu_added.txt"
TENGU_REMOVED="$WORK_DIR/tengu_removed.txt"
comm -13 "$OLD_TENGU" "$NEW_TENGU" > "$TENGU_ADDED"
comm -23 "$OLD_TENGU" "$NEW_TENGU" > "$TENGU_REMOVED"

# 环境变量差异
OLD_ENV="$WORK_DIR/old_env.txt"
NEW_ENV="$WORK_DIR/new_env.txt"
extract_env "$OLD_PKG/cli.js" > "$OLD_ENV"
extract_env "$NEW_PKG/cli.js" > "$NEW_ENV"

ENV_ADDED="$WORK_DIR/env_added.txt"
ENV_REMOVED="$WORK_DIR/env_removed.txt"
comm -13 "$OLD_ENV" "$NEW_ENV" > "$ENV_ADDED"
comm -23 "$OLD_ENV" "$NEW_ENV" > "$ENV_REMOVED"

# GrowthBook 配置差异
OLD_GB="$WORK_DIR/old_gb.txt"
NEW_GB="$WORK_DIR/new_gb.txt"
extract_growthbook "$OLD_PKG/cli.js" > "$OLD_GB"
extract_growthbook "$NEW_PKG/cli.js" > "$NEW_GB"

GB_ADDED="$WORK_DIR/gb_added.txt"
GB_REMOVED="$WORK_DIR/gb_removed.txt"
comm -13 "$OLD_GB" "$NEW_GB" > "$GB_ADDED"
comm -23 "$OLD_GB" "$NEW_GB" > "$GB_REMOVED"

# 文件大小
OLD_SIZE=$(file_size_bytes "$OLD_PKG/cli.js")
NEW_SIZE=$(file_size_bytes "$NEW_PKG/cli.js")
SIZE_DIFF=$((NEW_SIZE - OLD_SIZE))

# Source map 检查
OLD_HAS_MAP="no"
NEW_HAS_MAP="no"
[[ -f "$OLD_PKG/cli.js.map" ]] && OLD_HAS_MAP="yes"
[[ -f "$NEW_PKG/cli.js.map" ]] && NEW_HAS_MAP="yes"

# sdk-tools.d.ts 差异
SDK_DIFF=""
if [[ -f "$OLD_PKG/sdk-tools.d.ts" && -f "$NEW_PKG/sdk-tools.d.ts" ]]; then
  SDK_DIFF=$(diff "$OLD_PKG/sdk-tools.d.ts" "$NEW_PKG/sdk-tools.d.ts" 2>/dev/null || true)
fi

# package.json 差异
PKG_DIFF=""
if [[ -f "$OLD_PKG/package.json" && -f "$NEW_PKG/package.json" ]]; then
  PKG_DIFF=$(diff "$OLD_PKG/package.json" "$NEW_PKG/package.json" 2>/dev/null || true)
fi

# 文件列表差异
OLD_FILES="$WORK_DIR/old_files.txt"
NEW_FILES="$WORK_DIR/new_files.txt"
(cd "$OLD_PKG" && find . -type f | sort) > "$OLD_FILES"
(cd "$NEW_PKG" && find . -type f | sort) > "$NEW_FILES"

FILES_ADDED="$WORK_DIR/files_added.txt"
FILES_REMOVED="$WORK_DIR/files_removed.txt"
comm -13 "$OLD_FILES" "$NEW_FILES" > "$FILES_ADDED"
comm -23 "$OLD_FILES" "$NEW_FILES" > "$FILES_REMOVED"

# ──────────────────────────────────────────────
# 报告生成
# ──────────────────────────────────────────────

generate_report() {
  local tengu_added_count tengu_removed_count
  tengu_added_count=$(wc -l < "$TENGU_ADDED" | tr -d ' ')
  tengu_removed_count=$(wc -l < "$TENGU_REMOVED" | tr -d ' ')

  local env_added_count env_removed_count
  env_added_count=$(wc -l < "$ENV_ADDED" | tr -d ' ')
  env_removed_count=$(wc -l < "$ENV_REMOVED" | tr -d ' ')

  local gb_added_count gb_removed_count
  gb_added_count=$(wc -l < "$GB_ADDED" | tr -d ' ')
  gb_removed_count=$(wc -l < "$GB_REMOVED" | tr -d ' ')

  local files_added_count files_removed_count
  files_added_count=$(wc -l < "$FILES_ADDED" | tr -d ' ')
  files_removed_count=$(wc -l < "$FILES_REMOVED" | tr -d ' ')

  local old_tengu_count new_tengu_count
  old_tengu_count=$(wc -l < "$OLD_TENGU" | tr -d ' ')
  new_tengu_count=$(wc -l < "$NEW_TENGU" | tr -d ' ')

  local old_env_count new_env_count
  old_env_count=$(wc -l < "$OLD_ENV" | tr -d ' ')
  new_env_count=$(wc -l < "$NEW_ENV" | tr -d ' ')

  cat <<REPORT
# Claude Code 版本差异报告

## v${OLD_VER} → v${NEW_VER}

生成时间: $(date -u '+%Y-%m-%d %H:%M:%S UTC')

---

## 概览

| 指标 | v${OLD_VER} | v${NEW_VER} | 变化 |
|------|-------------|-------------|------|
| cli.js 大小 | $(file_size_mb "$OLD_PKG/cli.js")MB | $(file_size_mb "$NEW_PKG/cli.js")MB | $(if [[ $SIZE_DIFF -ge 0 ]]; then echo "+"; fi)${SIZE_DIFF} bytes |
| Source Map | ${OLD_HAS_MAP} | ${NEW_HAS_MAP} | $(if [[ "$OLD_HAS_MAP" != "$NEW_HAS_MAP" ]]; then echo "⚠ 变化"; else echo "不变"; fi) |
| Tengu 事件数 | ${old_tengu_count} | ${new_tengu_count} | +${tengu_added_count} / -${tengu_removed_count} |
| 环境变量数 | ${old_env_count} | ${new_env_count} | +${env_added_count} / -${env_removed_count} |
| GrowthBook 配置数 | $(wc -l < "$OLD_GB" | tr -d ' ') | $(wc -l < "$NEW_GB" | tr -d ' ') | +${gb_added_count} / -${gb_removed_count} |
| 包文件数 | $(wc -l < "$OLD_FILES" | tr -d ' ') | $(wc -l < "$NEW_FILES" | tr -d ' ') | +${files_added_count} / -${files_removed_count} |

---

## 1. Tengu 事件变化
REPORT

  if [[ $tengu_added_count -gt 0 ]]; then
    echo ""
    echo "### 新增事件 (+${tengu_added_count})"
    echo ""
    while IFS= read -r event; do
      echo "- \`$event\`"
    done < "$TENGU_ADDED"
  fi

  if [[ $tengu_removed_count -gt 0 ]]; then
    echo ""
    echo "### 移除事件 (-${tengu_removed_count})"
    echo ""
    while IFS= read -r event; do
      echo "- ~~\`$event\`~~"
    done < "$TENGU_REMOVED"
  fi

  if [[ $tengu_added_count -eq 0 && $tengu_removed_count -eq 0 ]]; then
    echo ""
    echo "无变化。"
  fi

  cat <<REPORT

---

## 2. 环境变量变化
REPORT

  if [[ $env_added_count -gt 0 ]]; then
    echo ""
    echo "### 新增 (+${env_added_count})"
    echo ""
    while IFS= read -r var; do
      echo "- \`$var\`"
    done < "$ENV_ADDED"
  fi

  if [[ $env_removed_count -gt 0 ]]; then
    echo ""
    echo "### 移除 (-${env_removed_count})"
    echo ""
    while IFS= read -r var; do
      echo "- ~~\`$var\`~~"
    done < "$ENV_REMOVED"
  fi

  if [[ $env_added_count -eq 0 && $env_removed_count -eq 0 ]]; then
    echo ""
    echo "无变化。"
  fi

  cat <<REPORT

---

## 3. GrowthBook 配置变化
REPORT

  if [[ $gb_added_count -gt 0 ]]; then
    echo ""
    echo "### 新增 (+${gb_added_count})"
    echo ""
    while IFS= read -r config; do
      echo "- \`$config\`"
    done < "$GB_ADDED"
  fi

  if [[ $gb_removed_count -gt 0 ]]; then
    echo ""
    echo "### 移除 (-${gb_removed_count})"
    echo ""
    while IFS= read -r config; do
      echo "- ~~\`$config\`~~"
    done < "$GB_REMOVED"
  fi

  if [[ $gb_added_count -eq 0 && $gb_removed_count -eq 0 ]]; then
    echo ""
    echo "无变化。"
  fi

  cat <<REPORT

---

## 4. 包文件变化
REPORT

  if [[ $files_added_count -gt 0 ]]; then
    echo ""
    echo "### 新增文件 (+${files_added_count})"
    echo ""
    while IFS= read -r f; do
      echo "- \`$f\`"
    done < "$FILES_ADDED"
  fi

  if [[ $files_removed_count -gt 0 ]]; then
    echo ""
    echo "### 移除文件 (-${files_removed_count})"
    echo ""
    while IFS= read -r f; do
      echo "- ~~\`$f\`~~"
    done < "$FILES_REMOVED"
  fi

  if [[ $files_added_count -eq 0 && $files_removed_count -eq 0 ]]; then
    echo ""
    echo "无变化。"
  fi

  if [[ -n "$SDK_DIFF" ]]; then
    cat <<REPORT

---

## 5. sdk-tools.d.ts 差异（公开 API 变化）

\`\`\`diff
${SDK_DIFF}
\`\`\`
REPORT
  else
    cat <<REPORT

---

## 5. sdk-tools.d.ts 差异

无变化（或文件不存在）。
REPORT
  fi

  if [[ -n "$PKG_DIFF" ]]; then
    cat <<REPORT

---

## 6. package.json 差异

\`\`\`diff
${PKG_DIFF}
\`\`\`
REPORT
  else
    cat <<REPORT

---

## 6. package.json 差异

无变化。
REPORT
  fi

  cat <<REPORT

---

## 7. 分析建议

REPORT

  # 根据变化生成建议
  if [[ "$OLD_HAS_MAP" == "yes" && "$NEW_HAS_MAP" == "no" ]]; then
    echo "- **Source Map 已移除**: 新版本不再包含 \`cli.js.map\`，需要使用字符串常量挖掘方法进行分析"
  fi

  if [[ $tengu_added_count -gt 10 ]]; then
    echo "- **大量新事件 (+${tengu_added_count})**: 可能有重大功能新增，建议逐一分析新事件对应的子系统"
  fi

  if [[ $tengu_removed_count -gt 0 ]]; then
    echo "- **事件被移除 (-${tengu_removed_count})**: 对应功能可能被废弃或重构"
  fi

  local size_pct
  if [[ $OLD_SIZE -gt 0 ]]; then
    size_pct=$(echo "scale=1; $SIZE_DIFF * 100 / $OLD_SIZE" | bc)
    if [[ $(echo "$size_pct > 5" | bc) -eq 1 || $(echo "$size_pct < -5" | bc) -eq 1 ]]; then
      echo "- **Bundle 大小显著变化 (${size_pct}%)**: 可能有大规模代码增删"
    fi
  fi

  echo ""
  echo "---"
  echo ""
  echo "*由 cc-version-diff.sh 自动生成*"
}

echo "生成报告..." >&2

if [[ -n "$OUTPUT_FILE" ]]; then
  generate_report > "$OUTPUT_FILE"
  echo "报告已保存到: $OUTPUT_FILE" >&2
else
  generate_report
fi
