spec: task
name: "第五篇：安全与权限 — 纵深防御"
inherits: project
tags: [part5, safety, permissions]
depends: [part1-architecture, part2-prompt-engineering]
estimate: 3d
---

## 意图

编写第五篇（第15-18章），分析 Claude Code 的安全架构：权限系统、YOLO 自动分类器、Hook 拦截机制、CLAUDE.md 用户指令层。这四章展示了一个生产级 AI agent 如何在"让模型做事"和"防止模型做错事"之间取得平衡。

## 已定决策

- 第15章核心文件：`utils/permissions/` 目录、`types/permissions.ts`
- 第16章核心文件：`utils/permissions/yoloClassifier.ts`、`utils/permissions/denialTracking.ts`
- 第17章核心文件：`utils/hooks.ts`、`utils/hooks/` 目录
- 第18章核心文件：`utils/claudemd.ts`

### 每章预算

| 章 | 字数 | 深度 | 必需图表 |
|----|------|------|---------|
| ch16 | 5000-7000 | L3 | 权限模式列表及切换逻辑表、三阶段管线流程图、通配符匹配示例表 |
| ch17 | 5000-7000 | L3（不暴露完整 prompt） | 分类器架构图、安全白名单完整表、拒绝追踪状态机图 |
| ch18 | 5000-6000 | L3 | Hook 事件类型完整清单表、退出码语义表、2 个 Hook 配置示例 |
| ch19 | 5000-7000 | L3 | 四级加载优先级图、@include 语法表、CLAUDE.md 编写最佳实践清单 |

## 边界

### 允许修改
- docs/chapters/ch15-permission-system.md
- docs/chapters/ch16-yolo-classifier.md
- docs/chapters/ch17-hooks.md
- docs/chapters/ch18-claudemd.md

### 禁止
- 不暴露 YOLO 分类器的完整 prompt template（安全敏感）
- 不包含绕过权限检查的方法
- 不讨论 `auto` 和 `bubble` 权限模式的内部工作原理细节

## 验收标准

场景: 第15章展示完整的权限决策流程
  测试: verify_ch15_permission_flow
  假设 `docs/chapters/ch15-permission-system.md` 已生成
  当 审阅章节内容
  那么 包含权限模式的完整列表和切换逻辑
  并且 包含 "验证→权限→分类" 三阶段管线的流程图
  并且 包含通配符规则匹配的示例

场景: 第16章分析分类器但不泄露 prompt
  测试: verify_ch16_classifier_analysis
  假设 `docs/chapters/ch16-yolo-classifier.md` 已生成
  当 审阅章节内容
  那么 包含分类器的架构分析（二次 API 调用模式）
  并且 包含安全白名单的完整清单
  并且 包含拒绝追踪的阈值和回退机制
  但是 不包含分类器 prompt template 的完整文本

场景: 第17章的 Hook 事件清单完整
  测试: verify_ch17_hook_events
  假设 `docs/chapters/ch17-hooks.md` 已生成
  当 审阅章节内容
  那么 包含所有 Hook 事件类型的清单和触发时机
  并且 包含退出码语义（0=允许、2=阻塞）的解释
  并且 包含至少 2 个实际 Hook 配置示例

场景: 第18章的 CLAUDE.md 加载机制可验证
  测试: verify_ch18_claudemd_loading
  假设 `docs/chapters/ch18-claudemd.md` 已生成
  当 审阅章节内容
  那么 包含四级加载顺序的优先级图
  并且 包含 `@include` 指令的完整语法和限制
  并且 包含 frontmatter `paths:` 范围限定的使用示例
  并且 包含"用户能做什么"小节，给出 CLAUDE.md 编写最佳实践

## 排除范围

- 沙箱实现细节（仅在第15章提及存在）
- MDM 配置和企业管理策略
