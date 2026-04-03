spec: task
name: "书籍结构与内容改进"
inherits: project
tags: [book, structure, content, quality]
depends: [version-evolution]
estimate: 3d
---

## 意图

基于全书深度审阅，执行 8 项结构性和内容性改进，提升可读性、完整性和实用性。

## 批次安排

### 批次 1：结构重组（最高影响）

**1.1 拆分 ch20**

当前 ch20 承载过重（~900 行 + Ultraplan ~400 行 + Teams ~200 行），需要拆分为三个独立章节：

| 新章节 | 内容 | 来源 |
|--------|------|------|
| ch20 Agent 派生与编排 | 子代理/Fork/Coordinator/验证 Agent/`/btw`/设计洞察 | 现 20.1-20.4 + 20.7-20.8 |
| ch20b Teams 与多进程协作 | Swarms 概述 + 通信 + Teams 实现细节 | 现 20.3 + 20.5-20.6 + 20.9 |
| ch20c Ultraplan 远程规划 | 完整 Ultraplan 分析 | 现版本演化 Ultraplan 部分 |

需要同步更新 `SUMMARY.md`。

**1.2 附录 E 双向链接**

为附录 E 每条变化添加章节锚链接，同时在各章版本演化小节添加"完整速查见附录 E"的反向引用。

### 批次 2：缺失内容补充

**2.1 新增章节：API 通信层**

覆盖 CC 的 API 通信工程，当前散落在多个章节中未系统化：

- `withRetry.ts`：10 次重试、529 过载降级（FallbackTriggeredError）、持久重试模式
- `claude.ts`：流式处理（idle timeout、stall 检测）、非流式回退
- 错误分类（CannotRetryError vs 可重试错误）
- 心跳机制（持久重试期间 30 秒 keep-alive）

建议编号 ch06b 或移动到 Part 1 作为 ch05。

**2.2 新增章节：构建你自己的 Agent 实战指南**

从分析视角到应用视角的桥梁。用一个具体的 mini-Agent 项目演示本书核心模式：

- 提示词即控制面（ch25 原则 1）
- 分层 Token 预算（ch26 原则 1）
- 编辑前先读取（ch27 模式 1）
- 失败关闭默认值（ch25 原则 3）
- 从轻到重的分层恢复（ch03 模式 3）

建议编号 ch29b 或作为第八篇。

### 批次 3：现有内容深化

**3.1 ch13-15 补充"用户能做什么"**

缓存篇源码分析扎实但可操作建议偏少。补充：
- 如何保持系统提示词稳定以提升缓存命中
- 避免频繁切换模型导致缓存前缀失效
- 利用 `cache_read_input_tokens` 监控缓存健康

**3.2 ch23 Feature Flags 深化**

现有 89 个 flag 列表可补充：
- 按发布阶段分类（实验 → 灰度 → 全量 → 废弃）
- 与 v2.1.91 对照：哪些 flag 的实验已结束（如 TREE_SITTER_BASH_SHADOW）
- GrowthBook 配置的动态评估机制源码分析

**3.3 ch24 跨会话记忆深化**

补充 v2.1.91 新增的：
- `memory_toggled` 事件（记忆功能开关）
- 团队记忆（Team Memory）机制
- `extract_memories_skipped_no_prose`（无散文跳过）

### 批次 4：写作质量

**4.1 清理机械化模式提炼**

审查所有章节的"模式提炼"小节，合并/删除弱模式，保留真正有洞察的。

**4.2 补充双向跨章引用**

在前向引用（"详见第 N 章"）的对应位置添加反向引用（"本章被第 M 章在 X 上下文中引用"）。

## 验收标准

- [ ] ch20 拆分为 3 个独立章节，SUMMARY.md 更新
- [ ] 附录 E 有双向章节链接
- [ ] API 通信层章节完成，含 withRetry 完整分析
- [ ] 实战指南章节完成，含可运行的 mini-Agent 示例
- [ ] ch13-15 每章有"用户能做什么"小节
- [ ] ch23 有发布阶段分类和 v2.1.91 对照
- [ ] ch24 补充团队记忆和 v2.1.91 变化
- [ ] 模式提炼小节无机械化填充
- [ ] `mdbook build` 通过
