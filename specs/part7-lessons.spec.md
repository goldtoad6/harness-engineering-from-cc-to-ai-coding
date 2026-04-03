spec: task
name: "第七篇：AI Agent 构建者的经验教训"
inherits: project
tags: [part7, lessons, synthesis]
depends: [part1-architecture, part2-prompt-engineering, part3-context-management, part4-prompt-cache, part5-safety-permissions, part6-advanced-subsystems]
estimate: 2d
---

## 意图

编写第七篇（第25-29章）和四个附录。这是全书的综合提炼，将前六篇的具体源码分析升华为可复用的工程原则。第28章是独特价值——客观分析 Claude Code 的设计不足及改进方向。第29章作为横切关注点补充——深度分析 Claude Code 的生产级可观测性体系。

## 已定决策

- 第25章提炼 6 条驾驭工程原则，每条回溯引用前文章节
- 第26章提炼 5 条上下文管理原则
- 第27章提炼 6 条生产级编码模式
- 第28章列出 5 个设计不足，每个配改进建议
- 第29章深度分析可观测性工程（5 层遥测管线、PII 安全、1P Exporter、分布式追踪、优雅关闭）
- 附录 A/B/C/D 为参考索引，不需要叙事

### 每章预算

| 章 | 字数 | 深度 | 必需图表 |
|----|------|------|---------|
| ch25 | 5000-6000 | L2（原则提炼，不深挖） | 6 条原则汇总表（原则/源码回溯/反模式） |
| ch26 | 4000-5000 | L2 | 5 条原则汇总表 |
| ch27 | 5000-6000 | L2 | 6 条模式汇总表（模式/实现方式/源码引用） |
| ch28 | 5000-7000 | L3 | 5 个不足的汇总表（问题/源码证据/改进建议）、三层防御互补图 |
| ch29 | 6000-8000 | L3（1P Exporter 节可到 L4） | 遥测管线 Mermaid 图、优雅关闭时序图、三通道对比表、1P vs 标准 OTel 对比表 |
| 附录 | 各 1000-2000 | — | 附录 A: 文件索引表、附录 B: 环境变量表、附录 C: 术语表、附录 D: 89 flag 分类表 |

## 边界

### 允许修改
- docs/chapters/ch22-harness-principles.md
- docs/chapters/ch23-context-principles.md
- docs/chapters/ch24-production-patterns.md
- docs/chapters/ch25-limitations.md
- book/src/part7/ch29.md（新建）
- docs/chapters/appendix-a-file-index.md
- docs/chapters/appendix-b-env-vars.md
- docs/chapters/appendix-c-glossary.md

### 禁止
- 不做竞品对比
- 不对 Anthropic 做道德或商业评判
- 第28章的"不足"仅限工程设计层面

## 验收标准

场景: 第22章的每条原则有源码回溯
  测试: verify_ch22_principles_backed
  假设 `docs/chapters/ch22-harness-principles.md` 已生成
  当 审阅章节内容
  那么 包含 6 条命名原则
  并且 每条原则引用至少 1 个具体的源码文件和行号
  并且 每条原则包含"反模式"示例（如果不遵循会怎样）

场景: 第28章的不足分析有建设性
  测试: verify_ch28_constructive
  假设 `docs/chapters/ch28-limitations.md` 已生成
  当 审阅章节内容
  那么 包含 5 个具体的设计不足
  并且 每个不足包含：问题描述、源码证据、改进建议
  但是 不包含对 Anthropic 团队能力的负面评价

场景: 附录内容与正文一致
  测试: verify_appendices_consistent
  假设 附录 A/B/C 已生成
  当 对比附录与正文
  那么 附录 A 的文件索引覆盖正文引用的所有关键文件
  并且 附录 B 的环境变量覆盖正文提到的所有变量
  并且 附录 C 的术语覆盖正文中首次出现时加注的所有术语

场景: 第29章可观测性工程覆盖完整遥测体系
  测试: verify_ch29_observability
  假设 `book/src/part7/ch29.md` 已生成
  当 审阅章节内容
  那么 包含遥测管线架构分析（logEvent → sink → Datadog/1P 双路）
  并且 包含 PII 安全架构分析（never 类型标注、_PROTO_ 前缀、sanitizeToolNameForAnalytics）
  并且 包含 1P Exporter 深度分析（磁盘持久化重试、二次退避、401 降级）
  并且 包含调试三通道对比表（debug/diagLogs/errorLogSink）
  并且 包含分布式追踪分析（sessionTracing + perfettoTracing）
  并且 包含优雅关闭分析（级联超时、清理顺序、5 秒硬超时）
  并且 包含至少 2 个 Mermaid 图（遥测管线流程图 + 优雅关闭时序图）
  并且 所有源码引用指向 restored-src/src/ 下真实存在的文件和行号
  并且 缓存效率追踪节简要引用第14章，不重复 >3 行代码
  并且 Feature Flag 引用回溯第23章

场景: 全书完整性检查
  测试: verify_book_completeness
  假设 全部 29 章和 4 个附录已生成
  当 检查 `book/src/` 目录
  那么 包含 33 个 Markdown 文件（29 章 + 4 附录）
  并且 每个文件非空且超过 2000 字（附录除外）
  并且 大纲 `docs/book-outline.md` 中的所有要点在正文中有对应内容

## 排除范围

- 前言和后记（可后续添加）
- 索引页生成（可后续工具化）
