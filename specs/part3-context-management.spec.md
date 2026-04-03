spec: task
name: "第三篇：上下文管理 — 200K Token 竞技场"
inherits: project
tags: [part3, context-management]
depends: [part1-architecture]
estimate: 3d
---

## 意图

编写第三篇（第8-11章），系统分析 Claude Code 的上下文管理机制：自动压缩、文件状态保留、微压缩、token 预算。这是影响用户实际体验最大的子系统——大部分"Claude Code 变笨了"的抱怨都与上下文管理有关。

## 已定决策

- 第8章核心文件：`services/compact/autoCompact.ts`、`services/compact/compact.ts`、`services/compact/prompt.ts`
- 第9章聚焦压缩前后文件状态的保留和恢复机制
- 第10章核心文件：`services/compact/microCompact.ts`、`services/compact/apiMicrocompact.ts`
- 第11章核心文件：`utils/toolResultStorage.ts`、`constants/toolLimits.ts`、`utils/tokens.ts`、`services/tokenEstimation.ts`
- 每章配一个"用户能做什么"小节，给出实际可操作的建议

### 每章预算

| 章 | 字数 | 深度 | 必需图表 |
|----|------|------|---------|
| ch09 | 6000-8000 | L4（用户痛点章节允许更深） | 阈值计算公式表、9 段压缩模板分析表、PTL 重试流程图 |
| ch10 | 5000-6000 | L3 | token 预算分配表（5 个文件×5K）、"保留 vs 丢弃"决策树 |
| ch11 | 5000-7000 | L3 | 三种微压缩机制对比表、cache_edits 工作原理序列图 |
| ch12 | 5000-7000 | L3 | token 估算规则汇总表、并行工具调用 token 计数示意图、工具结果持久化流程图 |

## 边界

### 允许修改
- docs/chapters/ch08-auto-compaction.md
- docs/chapters/ch09-file-state-preservation.md
- docs/chapters/ch10-microcompact.md
- docs/chapters/ch11-token-budgeting.md

### 禁止
- 不讨论 prompt cache（第四篇内容）
- 不分析压缩提示词的模型行为效果（无数据支撑）

## 验收标准

场景: 第8章包含完整的压缩触发和执行流程
  测试: verify_ch08_compaction_flow
  假设 `docs/chapters/ch08-auto-compaction.md` 已生成
  当 审阅章节内容
  那么 包含阈值计算公式及各常量的具体值
  并且 包含熔断器机制（3 次连续失败停止）和 BQ 数据引用
  并且 包含 9 段压缩模板的完整分析
  并且 包含 `<analysis>` 草稿块的作用解释
  并且 包含 Prompt-too-long 重试策略

场景: 第9章解释清楚"压缩后丢了什么"
  测试: verify_ch09_what_survives
  假设 `docs/chapters/ch09-file-state-preservation.md` 已生成
  当 审阅章节内容
  那么 包含 `POST_COMPACT_MAX_FILES_TO_RESTORE = 5` 的选择逻辑
  并且 包含 token 预算分配表（单文件 5K、技能 5K、总计 50K）
  并且 包含"不重注入"清单及其理由
  并且 包含"用户能做什么"小节，给出至少 3 条实操建议

场景: 第10章区分三种微压缩机制
  测试: verify_ch10_microcompact_types
  假设 `docs/chapters/ch10-microcompact.md` 已生成
  当 审阅章节内容
  那么 明确区分：基于时间的微压缩、缓存微压缩（API 原生）、标准压缩
  并且 包含 `cache_edits` 块的工作原理图
  并且 包含可压缩工具集的完整清单

场景: 第11章的 token 估算规则可直接使用
  测试: verify_ch11_token_rules
  假设 `docs/chapters/ch11-token-budgeting.md` 已生成
  当 审阅章节内容
  那么 包含 token 估算规则汇总表（文本 4B/tok、JSON 2B/tok、图片 2K tok）
  并且 包含并行工具调用的 token 计数陷阱解释
  并且 包含工具结果持久化的完整流程图

## 排除范围

- 提示词缓存机制（第四篇覆盖）
- 缓存中断检测（第四篇覆盖）
