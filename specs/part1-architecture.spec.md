spec: task
name: "第一篇：架构 — Claude Code 如何运作"
inherits: project
tags: [part1, architecture, agent-loop]
depends: []
estimate: 3d
---

## 意图

编写第一篇（第1-4章），从技术栈全景、工具系统、Agent Loop、工具执行编排四个维度，让读者理解 Claude Code 的整体架构。第3章 Agent Loop 是全书的骨架——所有后续篇章（提示词、上下文管理、缓存、权限）都是 Agent Loop 中某个阶段的深入分析。

## 已定决策

- 第1章聚焦 `main.tsx` 入口点、三层架构图、89 个 feature flag 全景
- 第2章聚焦 `Tool.ts` 接口和 `tools.ts` 注册管线
- 第3章聚焦 `query.ts` 的 `queryLoop()` 状态机，是全书最重要的章节之一
- 第4章聚焦 `toolOrchestration.ts`、`toolExecution.ts`、`StreamingToolExecutor`

### 每章预算

| 章 | 字数 | 深度 | 必需图表 |
|----|------|------|---------|
| ch01 | 5000-6000 | L3 | 三层架构图(Mermaid)、feature flag 分类表 |
| ch02 | 5000-7000 | L3 | Tool 接口字段表、工具结果大小对比表、三阶段渲染流程图 |
| ch03 | 6000-8000 | L4（核心章节允许更深） | queryLoop 状态机流程图、State 字段表、Continue 转换枚举表、单次迭代序列图 |
| ch04 | 5000-7000 | L3 | partitionToolCalls 分区逻辑图、单工具生命周期流程图、权限决策链图 |

## 边界

### 允许修改
- docs/chapters/ch01-tech-stack.md
- docs/chapters/ch02-tool-system.md
- docs/chapters/ch03-agent-loop.md
- docs/chapters/ch04-tool-orchestration.md

### 禁止
- 不深入分析 Bun 的 Zig 代码
- 不在第一篇讨论缓存优化（第四篇的内容）
- 不在第一篇讨论压缩机制细节（第三篇的内容）

## 验收标准

场景: 第3章展示完整的 Agent Loop 状态机
  测试: verify_ch03_agent_loop
  假设 `docs/chapters/ch03-agent-loop.md` 已生成
  当 审阅章节内容
  那么 包含 `queryLoop()` 的 `State` 类型 7 个字段的逐一解释
  并且 包含循环转换类型（`Continue`）的完整枚举：工具调用继续、max_output 恢复、budget 继续、reactive compact
  并且 包含单次迭代的完整流程图（Mermaid 格式）
  并且 包含 `MAX_OUTPUT_TOKENS_RECOVERY_LIMIT = 3` 的恢复机制分析
  并且 包含"Agent Loop 与传统 REPL 的区别"对比

场景: 第4章展示工具执行的并发模型
  测试: verify_ch04_tool_orchestration
  假设 `docs/chapters/ch04-tool-orchestration.md` 已生成
  当 审阅章节内容
  那么 包含 `partitionToolCalls` 的分区逻辑（`isConcurrencySafe` 判定）
  并且 包含单工具生命周期的完整流程：validateInput → checkPermissions → classifier → call → hooks
  并且 包含 `MAX_TOOL_USE_CONCURRENCY = 10` 的并发上限及其影响
  并且 包含 Stop hooks 作为工具间中断点的机制

场景: 第3章建立全书引用锚点
  测试: verify_ch03_anchor_points
  假设 `docs/chapters/ch03-agent-loop.md` 已生成
  当 审阅章节中的前向引用
  那么 在 autocompact 阶段注明"详见第9章"
  并且 在 API 调用阶段注明"详见第5章（系统提示词）和第13章（缓存）"
  并且 在权限检查阶段注明"详见第16章"

场景: 章节间无重复内容
  测试: verify_part1_no_duplication
  假设 第1-4章已全部生成
  当 对比四章内容
  那么 同一段源码不在两个章节中重复出现超过 3 行

## 排除范围

- 权限系统细节（第五篇）
- 压缩机制细节（第三篇）
- 提示词内容分析（第二篇）
