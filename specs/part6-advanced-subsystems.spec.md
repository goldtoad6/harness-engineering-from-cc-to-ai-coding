spec: task
name: "第六篇：高级子系统"
inherits: project
tags: [part6, advanced, skills, feature-flags]
depends: [part1-architecture, part2-prompt-engineering]
estimate: 3d
---

## 意图

编写第六篇（第20-23章），分析 Claude Code 的四个高级子系统：Agent 集群与多 Agent 编排、Effort/Fast Mode/Thinking 配置、技能系统（从内置到用户自定义的完整生态）、未发布功能管线（89 个 feature flag 背后的路线图）。这些是 Claude Code 区别于简单 LLM wrapper 的核心特性。

## 已定决策

- 第20章核心文件：`tools/AgentTool/`、`coordinator/coordinatorMode.ts`、`utils/agentContext.ts`、`tools/SendMessageTool/`
- 第21章核心文件：`utils/effort.ts`、`utils/fastMode.ts`、`utils/thinking.ts`
- 第22章核心文件：`skills/bundled/`、`tools/SkillTool/`、`skills/loadSkillsDir.ts`、`skills/mcpSkillBuilders.ts`
- 第23章覆盖 89 个 feature flag 的分类和路线图推断

### 每章预算

| 章 | 字数 | 深度 | 必需图表 |
|----|------|------|---------|
| ch20 | 6000-8000 | L3 | 三种 agent 模式对比表、AsyncLocalStorage 隔离示意图、agent 间通信架构图 |
| ch21 | 5000-6000 | L3 | effort 优先级链图、fast mode 冷却状态机图、thinking 三模式对比表 |
| ch22 | 6000-8000 | L4（技能系统完整生态） | 技能生命周期流程图、三级截断级联图、内置技能清单表、MCP 桥接架构图 |
| ch23 | 6000-8000 | L3 | 89 个 flag 分类表（按功能分 5 类）、核心未发布功能架构图（KAIROS/PROACTIVE/VOICE） |

## 边界

### 允许修改
- docs/chapters/ch20-agent-swarm.md
- docs/chapters/ch21-effort-fast-thinking.md
- docs/chapters/ch22-skill-system.md
- docs/chapters/ch23-feature-flags-roadmap.md

### 禁止
- 不猜测 Anthropic 的商业策略
- 不对未发布功能的发布时间做预测

## 验收标准

场景: 第20章区分三种 agent 模式
  测试: verify_ch20_agent_modes
  假设 `docs/chapters/ch20-agent-swarm.md` 已生成
  当 审阅章节内容
  那么 明确区分：sub-agent（AgentTool）、fork、teammate（协调者模式）
  并且 包含 `AsyncLocalStorage` 的隔离机制解释
  并且 包含 agent 间通信机制（SendMessageTool、UDS_INBOX）
  并且 包含验证 agent 的 PASS/FAIL/PARTIAL 判定流程

场景: 第22章覆盖技能系统的完整生态
  测试: verify_ch22_skill_ecosystem
  假设 `docs/chapters/ch22-skill-system.md` 已生成
  当 审阅章节内容
  那么 包含技能的本质定义（可调用的提示词模板）
  并且 包含内置技能清单（batch、loop、scheduleRemoteAgents 等）
  并且 包含用户自定义技能的发现和加载机制
  并且 包含 MCP 技能桥接（mcpSkillBuilders.ts）的工作原理
  并且 包含技能搜索系统（EXPERIMENTAL_SKILL_SEARCH）的索引和评分机制
  并且 包含三级截断级联的流程图和预算计算公式
  并且 包含技能编写者的实操建议

场景: 第23章对 89 个 feature flag 分类完整
  测试: verify_ch23_feature_flags
  假设 `docs/chapters/ch23-feature-flags-roadmap.md` 已生成
  当 审阅章节内容
  那么 包含 89 个 flag 按功能分类的完整表格
  并且 分类包含：用户功能、基础设施、遥测、实验、安全
  并且 包含 KAIROS、PROACTIVE、VOICE_MODE、WEB_BROWSER_TOOL 等核心未发布功能的源码分析
  并且 包含从 flag 成熟度推断产品路线图的方法论

场景: 不包含商业策略猜测
  测试: verify_ch23_no_speculation
  假设 `docs/chapters/ch23-feature-flags-roadmap.md` 已生成
  当 审阅章节内容
  那么 不包含发布时间预测
  并且 不包含对 Anthropic 战略意图的揣测

场景: ch24 覆盖六个记忆子系统
  测试: verify_ch24_memory_subsystems
  假设 `book/src/part6/ch24.md` 已生成
  当 审阅章节内容
  那么 包含 Memdir 架构分析（MEMORY.md 索引、截断策略、路径解析）
  并且 包含 Extract Memories 的触发机制、权限隔离、互斥设计
  并且 包含 Session Memory 的触发条件（10K/5K/3）和与压缩的关系
  并且 包含 Transcript Persistence 的 JSONL 格式和会话恢复
  并且 包含 Agent Memory 的三作用域模型和 VCS 快照同步
  并且 包含 Auto-Dream 的三层门控、PID 锁、四阶段整合提示词
  并且 包含至少 1 个 Mermaid 流程图
  并且 所有源码引用指向真实存在的文件和行号

场景: ch24 不与现有章节重复
  测试: verify_ch24_no_duplication
  假设 `book/src/part6/ch24.md` 已生成
  当 审阅章节内容
  那么 不包含超过 3 行的与 ch09（自动压缩）重复的源码片段
  并且 不包含超过 3 行的与 ch19（CLAUDE.md）重复的源码片段
  并且 跨章引用使用"详见第N章"格式

## 排除范围

- Bridge 模式（远程控制）的完整协议分析
- KAIROS 的 channel 和 push notification 的 UI 实现细节
