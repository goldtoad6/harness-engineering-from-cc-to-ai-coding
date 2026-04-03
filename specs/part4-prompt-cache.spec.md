spec: task
name: "第四篇：提示词缓存 — 隐藏的成本优化器"
inherits: project
tags: [part4, prompt-cache]
depends: [part2-prompt-engineering, part3-context-management]
estimate: 2d
---

## 意图

编写第四篇（第12-14章），揭示 Claude Code 中最隐蔽但影响最大的成本优化子系统——提示词缓存。这是连接提示工程（第二篇）和上下文管理（第三篇）的关键桥梁：提示词怎么写、上下文怎么管，最终都通过缓存命中率体现为 API 成本。

## 已定决策

- 第12章核心文件：`services/api/claude.ts`（beta header latching）、`utils/api.ts`（splitSysPromptPrefix）
- 第13章核心文件：`services/api/promptCacheBreakDetection.ts`
- 第14章从源码中提炼 7+ 个可复用的缓存优化模式

### 每章预算

| 章 | 字数 | 深度 | 必需图表 |
|----|------|------|---------|
| ch13 | 5000-7000 | L3 | 三级缓存范围对比表、beta header latching 状态图、缓存 TTL 层级图 |
| ch14 | 5000-7000 | L3 | 两阶段检测时序图、PreviousState 15+ 字段清单表、中断原因归因流程图 |
| ch15 | 6000-8000 | L3 | 7+ 个缓存优化模式汇总表（每行：模式名/问题/解法/通用模式）、agent 列表迁移前后对比 |

## 边界

### 允许修改
- docs/chapters/ch12-cache-architecture.md
- docs/chapters/ch13-cache-break-detection.md
- docs/chapters/ch14-cache-optimization-patterns.md

### 禁止
- 不猜测 Anthropic 服务端的缓存实现（仅分析客户端行为）
- 不给出具体的成本金额估算（缺乏定价数据）

## 验收标准

场景: 第12章解释清楚缓存的三层范围
  测试: verify_ch12_cache_scopes
  假设 `docs/chapters/ch12-cache-architecture.md` 已生成
  当 审阅章节内容
  那么 包含 global/org/null 三级范围的定义和使用场景
  并且 包含 beta header latching 机制的代码分析
  并且 包含"一旦发送就持续发送，避免浪费 50-70K token 缓存"的原理图

场景: 第13章展示完整的缓存中断检测系统
  测试: verify_ch13_detection_system
  假设 `docs/chapters/ch13-cache-break-detection.md` 已生成
  当 审阅章节内容
  那么 包含两阶段检测的时序图
  并且 包含 `PreviousState` 的 15+ 字段清单及用途
  并且 包含"90% 服务端原因"的数据引用和归因逻辑

场景: 第14章的优化模式可直接应用
  测试: verify_ch14_actionable_patterns
  假设 `docs/chapters/ch14-cache-optimization-patterns.md` 已生成
  当 审阅章节内容
  那么 包含至少 7 个命名的缓存优化模式
  并且 每个模式包含：问题描述、源码中的解法、可复用的通用模式
  并且 包含"10.2% fleet cache_creation tokens"的 agent 列表迁移案例

场景: 篇内引用前置篇章而非重复
  测试: verify_part4_cross_references
  假设 第12-14章已全部生成
  当 检查对第二篇和第三篇内容的引用
  那么 使用"详见第N章"格式引用，不重复分析相同源码

## 排除范围

- Anthropic 服务端缓存实现
- 第三方 provider（Bedrock/Vertex）的缓存差异
