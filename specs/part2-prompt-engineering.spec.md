spec: task
name: "第二篇：提示工程 — 系统提示词作为控制面"
inherits: project
tags: [part2, prompt-engineering]
depends: [part1-architecture]
estimate: 3d
---

## 意图

编写第二篇（第4-7章），深入分析 Claude Code 如何通过系统提示词架构、行为引导策略、模型特定调优和工具级提示词来控制模型行为。这是全书最核心的篇章，直接揭示"驾驭工程"的核心方法论。

## 已定决策

- 第4章核心文件：`constants/prompts.ts`、`constants/systemPromptSections.ts`
- 第5章提炼 6 种行为引导模式，每种配 2-3 个源码示例
- 第6章必须覆盖 `@[MODEL LAUNCH]` 注解、Capybara v8 调优、undercover 模式
- 第7章逐工具分析，覆盖 BashTool、FileEditTool、FileReadTool、GrepTool、AgentTool、SkillTool 共 6 个

### 每章预算

| 章 | 字数 | 深度 | 必需图表 |
|----|------|------|---------|
| ch05 | 5000-7000 | L3 | 系统提示词构建流程图、splitSysPromptPrefix 三路径流程图、静态/动态边界示意图 |
| ch06 | 6000-8000 | L3 | 6 种行为引导模式汇总表（模式名/源码原文/可复用模板）、ant-only 实验效果数据表 |
| ch07 | 5000-7000 | L3 | ant-only 门控完整清单表（行号/内容/解除条件）、undercover 工作流程图 |
| ch08 | 6000-8000 | L3 | 6 个工具的提示词对比总结表、每工具一个核心策略流程图 |

## 边界

### 允许修改
- docs/chapters/ch04-system-prompt-arch.md
- docs/chapters/ch05-behavioral-steering.md
- docs/chapters/ch06-model-tuning-ab.md
- docs/chapters/ch07-tool-prompts.md

### 禁止
- 不泄露 Anthropic 内部 Slack channel ID（源码中存在但不引用）
- 不在第6章讨论 GrowthBook 的具体 flag 值（仅讨论模式）

## 验收标准

场景: 第4章展示完整的系统提示词构建流程
  测试: verify_ch04_prompt_arch
  假设 `docs/chapters/ch04-system-prompt-arch.md` 已生成
  当 审阅章节内容
  那么 包含 `systemPromptSection()` 的记忆化机制分析
  并且 包含 `SYSTEM_PROMPT_DYNAMIC_BOUNDARY` 的作用解释和代码引用
  并且 包含 `splitSysPromptPrefix()` 三条路径的流程图
  并且 包含 `DANGEROUS_uncachedSystemPromptSection()` 的使用场景

场景: 第5章提炼可操作的行为引导模式
  测试: verify_ch05_behavioral_patterns
  假设 `docs/chapters/ch05-behavioral-steering.md` 已生成
  当 审阅章节内容
  那么 包含至少 6 种命名的行为引导模式
  并且 每种模式包含：模式名称、源码原文、中文解读、可复用的提示词模板
  并且 包含"数值锚定"模式的 A/B 测试数据（1.2% 输出 token 削减）

场景: 第6章覆盖 ant-only 门控的完整清单
  测试: verify_ch06_ant_gates
  假设 `docs/chapters/ch06-model-tuning-ab.md` 已生成
  当 审阅章节内容
  那么 列出 `prompts.ts` 中所有 `USER_TYPE === 'ant'` 门控的具体内容
  并且 每个门控包含：行号、门控内容摘要、注释中的解除条件
  并且 包含 undercover 模式的完整工作流程

场景: 第7章对每个工具提示词的分析结构一致
  测试: verify_ch07_tool_prompts_structure
  假设 `docs/chapters/ch07-tool-prompts.md` 已生成
  当 审阅章节内容
  那么 6 个工具各有独立小节
  并且 每个工具小节包含：提示词核心内容、引导策略分析、可复用的模式提炼
  并且 包含工具间的对比总结表

场景: 不包含安全敏感信息
  测试: verify_part2_no_secrets
  假设 第4-7章已全部生成
  当 扫描所有章节内容
  那么 不包含 Slack channel ID（C07VBSHV7EV）
  并且 不包含具体的 GrowthBook flag 值或 API endpoint

## 排除范围

- 缓存优化策略（第四篇覆盖）
- 权限模式与 YOLO 分类器（第五篇覆盖）
- Agent 集群编排（第六篇覆盖）
