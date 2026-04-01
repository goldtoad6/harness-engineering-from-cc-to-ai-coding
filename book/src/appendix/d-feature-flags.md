# 附录 D：89 个 Feature Flag 完整清单

本附录列出 Claude Code v2.1.88 源码中通过 `feature()` 函数门控的全部 Feature Flag，按功能域分类。引用次数反映该 flag 在源码中出现的频率，可粗略推断实现深度（详见第23章的成熟度推断方法）。

## 自主 Agent 与后台运行（19 个）

| Flag | 引用数 | 功能描述 |
|------|--------|----------|
| `AGENT_MEMORY_SNAPSHOT` | 2 | Agent 记忆快照 |
| `AGENT_TRIGGERS` | 11 | 定时触发器（本地 cron） |
| `AGENT_TRIGGERS_REMOTE` | 2 | 远程定时触发器（云端 cron） |
| `BG_SESSIONS` | 11 | 后台会话管理（ps/logs/attach/kill） |
| `BUDDY` | 15 | 伴侣模式：浮动 UI 气泡 |
| `BUILTIN_EXPLORE_PLAN_AGENTS` | 1 | 内置探索/计划 agent 类型 |
| `COORDINATOR_MODE` | 32 | 协调器模式：跨 agent 任务协调 |
| `FORK_SUBAGENT` | 4 | 子 agent fork 执行模式 |
| `KAIROS` | 84 | 助手模式核心：后台自主 agent、tick 唤醒 |
| `KAIROS_BRIEF` | 17 | 简报模式：向用户发送进度消息 |
| `KAIROS_CHANNELS` | 13 | 频道系统：多通道通信 |
| `KAIROS_DREAM` | 1 | autoDream 记忆整理触发 |
| `KAIROS_GITHUB_WEBHOOKS` | 2 | GitHub Webhook 订阅：PR 事件触发 |
| `KAIROS_PUSH_NOTIFICATION` | 2 | 推送通知：向用户推送状态更新 |
| `MONITOR_TOOL` | 5 | 监控工具：后台进程监控 |
| `PROACTIVE` | 21 | 自主工作模式：终端焦点感知、主动行动 |
| `TORCH` | 1 | Torch 命令 |
| `ULTRAPLAN` | 2 | 超级计划：结构化任务分解 UI |
| `VERIFICATION_AGENT` | 4 | 验证 agent：自动验证任务完成状态 |

## 远程控制与分布式执行（10 个）

| Flag | 引用数 | 功能描述 |
|------|--------|----------|
| `BRIDGE_MODE` | 14 | 桥接模式核心：远程控制协议 |
| `CCR_AUTO_CONNECT` | 3 | Claude Code Remote 自动连接 |
| `CCR_MIRROR` | 3 | CCR 镜像模式：只读远程镜像 |
| `CCR_REMOTE_SETUP` | 1 | CCR 远程设置命令 |
| `CONNECTOR_TEXT` | 7 | 连接器文本块处理 |
| `DAEMON` | 1 | 守护进程模式：后台 daemon worker |
| `DOWNLOAD_USER_SETTINGS` | 5 | 从云端下载用户配置 |
| `LODESTONE` | 3 | 协议注册（lodestone:// handler） |
| `UDS_INBOX` | 14 | Unix Domain Socket 收件箱 |
| `UPLOAD_USER_SETTINGS` | 1 | 上传用户配置到云端 |

## 多媒体与交互（17 个）

| Flag | 引用数 | 功能描述 |
|------|--------|----------|
| `ALLOW_TEST_VERSIONS` | 2 | 允许测试版本 |
| `ANTI_DISTILLATION_CC` | 1 | 反蒸馏保护 |
| `AUTO_THEME` | 1 | 自动主题切换 |
| `BUILDING_CLAUDE_APPS` | 1 | 构建 Claude Apps 技能 |
| `CHICAGO_MCP` | 12 | Computer Use MCP 集成 |
| `HISTORY_PICKER` | 1 | 历史选择器 UI |
| `MESSAGE_ACTIONS` | 2 | 消息操作（复制/编辑快捷键） |
| `NATIVE_CLIENT_ATTESTATION` | 1 | 原生客户端认证 |
| `NATIVE_CLIPBOARD_IMAGE` | 2 | 原生剪贴板图片支持 |
| `NEW_INIT` | 2 | 新版初始化流程 |
| `POWERSHELL_AUTO_MODE` | 2 | PowerShell 自动模式 |
| `QUICK_SEARCH` | 1 | 快速搜索 UI |
| `REVIEW_ARTIFACT` | 1 | 审查工件 |
| `TEMPLATES` | 5 | 任务模板/分类 |
| `TERMINAL_PANEL` | 3 | 终端面板 |
| `VOICE_MODE` | 11 | 语音模式：流式语音转文字 |
| `WEB_BROWSER_TOOL` | 1 | Web 浏览器工具（Bun WebView） |

## 上下文与性能优化（16 个）

| Flag | 引用数 | 功能描述 |
|------|--------|----------|
| `ABLATION_BASELINE` | 1 | 消融测试基线 |
| `BASH_CLASSIFIER` | 33 | Bash 命令分类器 |
| `BREAK_CACHE_COMMAND` | 2 | 强制打断缓存命令 |
| `CACHED_MICROCOMPACT` | 12 | 缓存微压缩策略 |
| `COMPACTION_REMINDERS` | 1 | 压缩提醒机制 |
| `CONTEXT_COLLAPSE` | 16 | 上下文折叠：精细化上下文管理 |
| `FILE_PERSISTENCE` | 3 | 文件持久化计时 |
| `HISTORY_SNIP` | 15 | 历史截断命令 |
| `OVERFLOW_TEST_TOOL` | 2 | 溢出测试工具 |
| `PROMPT_CACHE_BREAK_DETECTION` | 9 | Prompt Cache 断裂检测 |
| `REACTIVE_COMPACT` | 4 | 响应式压缩：按需触发 |
| `STREAMLINED_OUTPUT` | 1 | 精简输出模式 |
| `TOKEN_BUDGET` | 4 | Token 预算追踪 UI |
| `TREE_SITTER_BASH` | 3 | Tree-sitter Bash 解析器 |
| `TREE_SITTER_BASH_SHADOW` | 5 | Tree-sitter Bash 影子模式（A/B） |
| `ULTRATHINK` | 1 | 超级思考模式 |

## 记忆与知识管理（13 个）

| Flag | 引用数 | 功能描述 |
|------|--------|----------|
| `AWAY_SUMMARY` | 2 | 离开摘要：离开时生成进度 |
| `COWORKER_TYPE_TELEMETRY` | 2 | 协作者类型遥测 |
| `ENHANCED_TELEMETRY_BETA` | 2 | 增强遥测 Beta |
| `EXPERIMENTAL_SKILL_SEARCH` | 19 | 实验性远程技能搜索 |
| `EXTRACT_MEMORIES` | 7 | 自动记忆提取 |
| `MCP_RICH_OUTPUT` | 3 | MCP 富文本输出 |
| `MCP_SKILLS` | 9 | MCP 服务器技能发现 |
| `MEMORY_SHAPE_TELEMETRY` | 3 | 记忆结构遥测 |
| `RUN_SKILL_GENERATOR` | 1 | 技能生成器 |
| `SKILL_IMPROVEMENT` | 1 | 技能自动改进 |
| `TEAMMEM` | 44 | 团队记忆同步 |
| `WORKFLOW_SCRIPTS` | 6 | 工作流脚本 |
| `TRANSCRIPT_CLASSIFIER` | 69 | 会话记录分类器（auto 模式） |

## 基础设施与遥测（14 个）

| Flag | 引用数 | 功能描述 |
|------|--------|----------|
| `COMMIT_ATTRIBUTION` | 11 | Git 提交归属追踪 |
| `HARD_FAIL` | 2 | 硬失败模式 |
| `IS_LIBC_GLIBC` | 1 | glibc 运行时检测 |
| `IS_LIBC_MUSL` | 1 | musl 运行时检测 |
| `PERFETTO_TRACING` | 1 | Perfetto 性能追踪 |
| `SHOT_STATS` | 8 | 工具调用统计分布 |
| `SLOW_OPERATION_LOGGING` | 1 | 慢操作日志 |
| `UNATTENDED_RETRY` | 1 | 无人值守重试 |

---

## 统计摘要

| 分类 | 数量 | 最高引用 Flag |
|------|------|-------------|
| 自主 Agent 与后台运行 | 19 | KAIROS (84) |
| 远程控制与分布式执行 | 10 | BRIDGE_MODE (14), UDS_INBOX (14) |
| 多媒体与交互 | 17 | CHICAGO_MCP (12) |
| 上下文与性能优化 | 16 | TRANSCRIPT_CLASSIFIER (69) |
| 记忆与知识管理 | 13 | TEAMMEM (44) |
| 基础设施与遥测 | 14 | COMMIT_ATTRIBUTION (11) |
| **总计** | **89** | |

**引用次数 Top 5**：KAIROS (84) > TRANSCRIPT_CLASSIFIER (69) > TEAMMEM (44) > BASH_CLASSIFIER (33) > COORDINATOR_MODE (32)
