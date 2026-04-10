# Spec: 版本更新 v2.1.92 → v2.1.100 书籍内容升级

继承: `specs/project.spec.md`

## 目标

将 Claude Code v2.1.92→v2.1.100 的 6 个高影响变化写入书籍对应章节的"版本演化"小节，并更新附录 E。

## 背景

- 差异报告: `docs/version-diffs/v2.1.88-vs-v2.1.100.md`
- 影响分析: `docs/version-diffs/v2.1.88-vs-v2.1.100-book-impact.md`
- 各章节已有 v2.1.91 和部分 v2.1.92 版本演化小节
- 新增内容基于 v2.1.100 bundle 信号对比 + v2.1.88 源码辅助推断

## 任务分解

### 任务 1: 附录 E — 新增 v2.1.92→v2.1.100 版本条目

**文件**: `book/src/appendix/e-version-evolution.md`

**验收标准**:
- [ ] 新增 `## v2.1.92 → v2.1.100` 节
- [ ] 概览表格: cli.js 大小变化、事件增量、环境变量增量
- [ ] 高影响变化表: Dream 系统扩展、Bedrock/Vertex 向导、Autofix PR、Bridge REPL 重构、Tool Result Dedup、toolStats
- [ ] 中影响变化表: Advisor 工具、Team Onboarding、Perforce 支持、Mantle 认证
- [ ] 低影响变化: 新实验代号、环境变量
- [ ] 新功能详解（至少 3 个）: Dream/Kairos Dream、Bedrock/Vertex 升级向导、Autofix PR
- [ ] 实验代码名事件列表

**约束**:
- 字数: 1500-2500 词
- 格式与 v2.1.88→v2.1.91 节保持一致
- 区分"有 v2.1.88 源码佐证"和"纯信号推测"

### 任务 2: ch24 记忆系统 — Dream 扩展

**文件**: `book/src/part6/ch24.md`

**变化内容**:
- v2.1.100 新增 `tengu_kairos_dream` — KAIROS 后台定时 dream，通过 cron 调度
- v2.1.100 新增 `tengu_auto_dream_skipped` — 显式记录跳过原因（sessions 不足、lock 被占）
- v2.1.100 新增 `tengu_dream_invoked` — 手动 `/dream` 调用的追踪
- Dream UI 增强：dream 作为独立任务类型（与 remote_agent、monitor_mcp 并列）

**验收标准**:
- [ ] 在现有 `版本演化：v2.1.91 记忆系统变化` 后追加 v2.1.100 小节
- [ ] 分析 kairos_dream 的 cron 调度机制
- [ ] 记录 auto_dream_skipped 的两种跳过原因（sessions/lock）
- [ ] 分析 dream_invoked 手动触发与 auto_dream 自动触发的区别
- [ ] 关联 v2.1.88 源码中 DreamTask.ts 的 UI 架构

**约束**: 500-800 词

### 任务 3: ch09 自动压缩 — 冷压缩细节补充

**文件**: `book/src/part3/ch09.md`

**变化内容**:
- v2.1.100 中 cold_compact 的 Feature Flag 驱动 (`GPY()` + `S8("tengu_cold_compact", !1)`)
- 冷压缩参数作为第 8 个参数传入核心压缩函数 `QS6`
- rapid_refill_breaker 的 consecutiveRapidRefills 计数器
- 用户交互：autocompact_command 和 autocompact_dialog_opened

**验收标准**:
- [ ] 在现有 v2.1.91 版本演化后追加 v2.1.100 小节
- [ ] 解释冷压缩与热压缩的区别（延迟 vs 紧急）
- [ ] 分析快速回填熔断器的触发条件和作用
- [ ] 记录 `/compact` 命令和确认对话框 UX

**约束**: 400-600 词

### 任务 4: ch10 文件状态保留 — Tool Result Dedup

**文件**: `book/src/part3/ch10.md`

**变化内容**:
- v2.1.100 新增 tool_result_dedup 机制：检测重复工具结果，用短 ID (r1, r2) 替换
- 引用模板："refer to that output"
- 追踪 originalBytes/savedBytes
- toolStats 统计字段（sdk-tools.d.ts 新增）

**验收标准**:
- [ ] 在现有 v2.1.91 版本演化后追加 v2.1.100 小节
- [ ] 解释去重机制的工作原理（seen Map + counter）
- [ ] 分析对上下文预算的影响
- [ ] 记录 toolStats 字段的 7 个统计维度

**约束**: 400-600 词

### 任务 5: ch06b API 通信层 — Bedrock/Vertex 向导 + API 重试

**文件**: `book/src/part2/ch06b.md`

**变化内容**:
- 18 个 Bedrock/Vertex 事件覆盖完整的设置和升级生命周期
- api_retry_after_too_long — 新的重试限制信号
- 模型探测机制（probe_result）
- 自动升级检测和用户确认流程
- 已拒绝升级的持久化跟踪

**验收标准**:
- [ ] 在章节末尾追加 v2.1.100 版本演化小节
- [ ] 分析 Bedrock/Vertex 交互式设置向导流程
- [ ] 解释模型自动升级检测和用户确认机制
- [ ] 记录 api_retry_after_too_long 的含义

**约束**: 500-700 词

### 任务 6: ch21 Effort/Thinking — Advisor 工具

**文件**: `book/src/part6/ch21.md`

**变化内容**:
- Advisor 是服务端工具（server_tool_use），使用更强模型审阅当前工作
- 无参数调用——自动转发对话历史
- 明确的调用规则：实质性工作前、提交前
- Feature gate: `advisor-tool-2026-03-01`
- advisorModel 配置字段

**验收标准**:
- [ ] 在章节末尾追加 v2.1.100 版本演化小节
- [ ] 解释 Advisor 工具的设计理念（强模型审阅弱模型工作）
- [ ] 分析 Advisor 的调用规则和时机
- [ ] 记录 advisorModel 配置和 Feature Gate

**约束**: 500-700 词

## 边界

- 不修改章节主体内容，只追加版本演化小节
- 附录 E 的新增内容独立于章节内版本演化小节（附录是概览，章节是深入分析）
- 不添加新章节
- 不修改 SUMMARY.md
- 不修改 restored-src/ 下任何文件

## 交叉引用

- ch24 的 Dream 分析引用 v2.1.88 源码 `services/autoDream/autoDream.ts`
- ch09 的冷压缩引用 v2.1.88 源码 `services/compact/autoCompact.ts`
- ch10 的去重引用 v2.1.88 源码中的文件状态缓存机制
- ch06b 的 Bedrock/Vertex 引用 v2.1.88 源码 `services/api/bedrock.ts`
- ch21 的 Advisor 引用 v2.1.88 源码中的工具系统架构
