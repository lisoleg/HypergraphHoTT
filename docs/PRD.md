# HypergraphHoTT — 产品需求文档 (PRD)

> 项目代号：`hypergraph_hott`
> 语言：中文
> 编程语言：Coq 8.18+ (依赖 Coq-HoTT, MathComp)
> 产品经理：许清楚 (Xu)
> 创建日期：2026-05-25
> 状态：初版

---

## 1. 项目信息

- **项目名称**：HypergraphHoTT
- **项目定位**：Coq 形式化验证库，将超图理论与同伦类型论（HoTT）之间"珠帘合璧"对应关系进行严格形式化
- **原始需求**：基于"超图↔同伦类型论珠帘合璧统合框架"理论，构建可编译、可验证、可扩展的 Coq 库，使核心定理获得机器检验证明，并为跨学科应用提供形式化基石

---

## 2. 产品定义

### 2.1 产品目标

| # | 目标 | 衡量标准 |
|---|------|----------|
| G1 | **形式化核心对应**：将珠帘算子 𝒫ℭ 与超图-类型等价定理完整形式化，获得 QED | 定理 3.3（含三款）全部通过 Coq 检查 |
| G2 | **建立可组合的证明基础设施**：超图、Dowker 复形、HoTT 类型层各自独立模块化，可被下游项目复用 | 模块间依赖清晰，无循环引用，MathComp/Coq-HoTT 兼容 |
| G3 | **为跨学科应用提供形式化入口**：天/地/人/机四域应用可基于本库进行扩展验证 | 至少 1 个应用域（组织超图）拥有可编译的形式化骨架 |

### 2.2 目标用户

| 用户画像 | 核心诉求 | 使用方式 |
|----------|----------|----------|
| 形式化验证研究者 | 获得可复用的超图/HoTT 证明组件 | Import 模块、复用引理 |
| HoTT 社区成员 | 验证 Univalence 与超图结构的深层联系 | 定理 3.3 Univalence 对应款的形式化 |
| 超图理论研究者 | 将拓扑直觉转化为机器可检验的定理 | Dowker 复形、关联矩阵的形式定义 |
| AGI / AI 系统设计者 | 超图重写 + HoTT 证明器的组合框架 | 重写-β归约对应定理的应用 |

### 2.3 用户故事

1. **As a** 形式化验证研究者，**I want** 导入 `PearlCurtain` 模块并直接使用珠帘算子定义，**so that** 我可以在自己的研究中复用 𝒫ℭ 而无需从零构建超图基础设施。

2. **As a** HoTT 社区成员，**I want** 查看定理 3.3 的完整 Coq 证明（含 Univalence 对应款），**so that** 我能确信超图同构确实通过 Univalence 公理诱导类型等价。

3. **As a** 超图理论研究者，**I want** 在 Coq 中定义有限超图并计算其 Dowker 复形的单纯同调群，**so that** 我可以将手算结果与机器验证对齐。

4. **As an** AGI 系统设计者，**I want** 使用超图重写-β归约对应定理的形式化，**so that** 我可以在证明辅助系统中实现基于超图重写的自动推理策略。

5. **As a** 组织科学研究者，**I want** 基于本库的组织超图模块形式化 Cult Brand 类型等价，**so that** 我能为组织韧性分析提供可验证的类型论基础。

---

## 3. 需求池

### P0 — 必须有（MVP 闭环）

| ID | 需求 | 验收标准 | 对应理论 |
|----|------|----------|----------|
| P0-01 | 有限超图定义 `Hypergraph` | `V : FinSet`, `E : FinSet (FinSet V)`, `∀ e ∈ E, \|e\| ≥ 2` 可表达 | 定义 2.1 |
| P0-02 | 关联矩阵定义 `IncidenceMatrix` | `M : Matrix Bool \|V\| \|E\|`, `M(i,j) = 1 ↔ v_i ∈ e_j` 可表达 | 定义 2.2 |
| P0-03 | 对偶超图定义 `DualHypergraph` | 给定 H 可构造 H*，且 `H** = H` 可证明 | 定义 2.2 |
| P0-04 | Dowker 复形定义 `DowkerComplex` | `D(H)` 的 k-单形为 V' ⊆ V 使得 ∃e, V' ⊆ e | 定义 2.3 |
| P0-05 | 珠帘算子 𝒫ℭ 定义 `PearlCurtain` | 节点→和类型、超边→依赖积、整体→ Σ_e Π_v T_v 均可构造 | 定义 2.6 |
| P0-06 | 主定理 3.3 — 拓扑等价款 | `|𝒫ℭ(H)| ≃ |D(H)|` 获 QED | 定理 3.3(a) |
| P0-07 | 主定理 3.3 — 结构决定类型款 | `D(H₁) ≃ D(H₂) → 𝒫ℭ(H₁) ≃ 𝒫ℭ(H₂)` 获 QED | 定理 3.3(b) |
| P0-08 | 主定理 3.3 — Univalence 对应款 | `H₁ ≅ H₂ → 𝒫ℭ(H₁) ≃ 𝒫ℭ(H₂)` 并由 Univalence 得 `𝒫ℭ(H₁) = 𝒫ℭ(H₂)` | 定理 3.3(c) |

### P1 — 应该有（核心扩展）

| ID | 需求 | 验收标准 | 对应理论 |
|----|------|----------|----------|
| P1-01 | 函子性引理 3.2 | `𝒫ℭ(id) = id` 与 `𝒫ℭ(g∘f) = 𝒫ℭ(g)∘𝒫ℭ(f)` 均获 QED | 引理 3.2 |
| P1-02 | 超图结构不变量推论 3.4 | 连通超图同伦型是珠帘类型空间的同伦不变量获 QED | 推论 3.4 |
| P1-03 | 重写-β归约对应定理 3.5 | 超图重写步与 β-归约步存在自然变换使图交换获 QED | 定理 3.5 |
| P1-04 | 超图重写系统定义 `HypergraphRewrite` | 规则 ρ: E → E'，应用 ρ 将 E 变为 E' 可表达 | 定义 2.4 |
| P1-05 | Univalence 公理显式调用 | 在定理 3.3(c) 证明中显式使用 `univalence` 引理 | 定理 3.3(c) |
| P1-06 | 简单数值验证示例 | 提供小型超图（≤5 节点）的 𝒫ℭ 计算示例，可编译运行 | 验证支撑 |

### P2 — 可以有（远期愿景）

| ID | 需求 | 验收标准 | 对应理论 |
|----|------|----------|----------|
| P2-01 | 组织超图与 Cult Brand 类型等价 | 组织超图 → 类型空间映射可定义 | 应用域·地 |
| P2-02 | 自指类型不动点（意识模型） | 不动点构造子在 Coq 中可表达（需警惕一致性） | 应用域·人 |
| P2-03 | 可证伪预言 P-TY-I 形式化陈述 | `π_k(𝒫ℭ(H)) ≅ H_k(D(H))` 作为 `Axiom` 或 `Conjecture` 声明 | 预言 I |
| P2-04 | 可证伪预言 P-TY-III 形式化陈述 | 信息熵减与计算复杂度成正比作为 `Conjecture` 声明 | 预言 III |
| P2-05 | gudhi 数值验证接口 | Coq 内提取 Dowker 复形参数，外部 Python/gudhi 计算对比 | 验证支撑 |
| P2-06 | 自然系统超图建模模块 | 分子/生态/气候系统超图的形式化模板 | 应用域·天 |

---

## 4. 模块划分

```
HypergraphHoTT/
├── Hypergraph/               # P0-01, P0-02, P0-03, P1-04
│   ├── FinHypergraph.v       # 有限超图定义、超边基数约束
│   ├── IncidenceMatrix.v     # 关联矩阵、对偶超图
│   └── RewriteSystem.v       # 超图重写系统 (P1-04)
│
├── DowkerComplex/            # P0-04
│   ├── Simplicial.v          # 单纯复形基础设施
│   └── Dowker.v              # Dowker 复形定义与基本性质
│
├── PearlCurtain/             # P0-05
│   ├── PearlCurtain.v        # 珠帘算子 𝒫ℭ 定义
│   └── Functoriality.v       # 函子性引理 (P1-01)
│
├── CoreTheorems/             # P0-06, P0-07, P0-08, P1-02, P1-03, P1-05
│   ├── TopologicalEquiv.v     # 定理 3.3(a) 拓扑等价
│   ├── StructureDetermines.v  # 定理 3.3(b) 结构决定类型
│   ├── UnivalenceCorrespond.v# 定理 3.3(c) Univalence 对应
│   ├── StructuralInvariant.v # 推论 3.4 (P1-02)
│   └── RewriteBeta.v          # 定理 3.5 重写-β归约对应 (P1-03)
│
├── Applications/             # P2-01 ~ P2-06
│   ├── OrganizationHypergraph.v  # 组织超图 (P2-01)
│   ├── ConsciousnessType.v       # 意识类型 (P2-02)
│   ├── Conjectures.v             # 可证伪预言陈述 (P2-03, P2-04)
│   └── NaturalSystems.v          # 自然系统建模 (P2-06)
│
└── Verification/             # P1-06, P2-05
    ├── Examples.v                 # 小型超图计算示例
    └── GudhiInterface.md          # gudhi 对接说明文档
```

### 模块依赖关系

```
Hypergraph ──────→ DowkerComplex
    │                    │
    │                    ↓
    └──────→ PearlCurtain ←─── HoTT (Coq-HoTT / MathComp)
                    │
                    ↓
              CoreTheorems
                    │
                    ↓
              Applications
```

---

## 5. 技术规范

### 5.1 技术约束

| 约束 | 说明 |
|------|------|
| Coq 版本 | ≥ 8.18（需支持 Universe 多态性改进） |
| Coq-HoTT | 依赖 `Coq-HoTT` 库（Univalence 公理、路径类型 `Id_A(x,y)`） |
| MathComp | 依赖 `mathcomp`（有限集 `finset`、矩阵 `matrix`、排列 `perm`） |
| 构建系统 | `dune` + `coq_makefile` 或 `nix`（与 Coq-HoTT 构建兼容） |
| 一致性注意 | 自指不动点 (P2-02) 需标记为不保证逻辑一致性的实验性模块 |

### 5.2 关键类型映射

| 超图侧 | HoTT 侧 | Coq 表达 |
|--------|----------|----------|
| 顶点 v | 类型 T_v | `Variable T : V -> Type` |
| 超边 e | 依赖积 Π_{v∈e} T_v | `forall v : e, T v` |
| 超图整体 H | 珠帘类型 Σ_e Π_v T_v | `{e : E & forall v : e, T v}` |
| 超图同构 H₁≅H₂ | 类型等价 𝒫ℭ(H₁)≃𝒫ℭ(H₂) | `Equiv (PearlCurtain H1) (PearlCurtain H2)` |
| 超图同构 H₁≅H₂ | 类型相等 𝒫ℭ(H₁)=𝒫ℭ(H₂) | `path_universe (univalence ...)` |
| Dowker 复形 | 单纯复形 | `SimplicialComplex V` |
| 重写规则 ρ | β-归约步 | 交换图见证 |

### 5.3 UI/交互设计

本产品为 Coq 库，无 GUI。交互方式为：

- **开发时**：CoqIDE / VSCode + VSCoq 编辑器交互
- **验证时**：`coqc` 命令行编译 + `dune build` 自动化
- **文档时**：`coqdoc` 生成 HTML API 文档

---

## 6. 成功指标

| 指标 | 衡量方式 | 目标值 |
|------|----------|--------|
| 编译通过 | `dune build` 零错误 | 100% P0 模块通过 |
| 核心 QED | 定理 3.3 三款均获 `Qed.` | ≥ 3 个 QED |
| 数值验证一致 | 小型超图 𝒫ℭ 计算与 gudhi Dowker 复形同调一致 | ≥ 1 个示例对齐 |
| 代码覆盖率 | P0 需求均有对应 `.v` 文件 | 8/8 |
| 社区可用 | 可通过 `opam install` 或 `nix build` 获取 | 构建脚本就绪 |

---

## 7. 开放问题

| # | 问题 | 影响 | 建议处理 |
|---|------|------|----------|
| Q1 | Coq-HoTT 与 MathComp 的 Universe 兼容性 | 可能导致 P0-08 Univalence 调用失败 | 优先验证最小 Univalence 示例 |
| Q2 | 珠帘算子的计算性质：𝒫ℭ 是否可判定？ | 影响数值验证示例的范围 | 先做不可判定的白盒示例 |
| Q3 | Dowker 复形同伦型的 Coq 表达方式 | 拓扑等价款证明策略的选择 | 调研 `Coq-UNIMATH` 的同伦论基础设施 |
| Q4 | 重写-β归约对应定理的"自然变换使图交换"形式化粒度 | 影响证明复杂度 | 先做 2-范畴层面的陈述，再细化 |
| Q5 | 自指不动点构造子与 Coq 一致性的冲突 | P2-02 可能无法在默认逻辑框架内完成 | 标记为实验性，降级为 Axiom 声明 |

---

## 8. 里程碑规划

| 阶段 | 内容 | 依赖 |
|------|------|------|
| M1：基础定义 | P0-01 ~ P0-05 完成 | Coq-HoTT + MathComp 环境搭建 |
| M2：主定理 | P0-06 ~ P0-08 完成 | M1 |
| M3：核心扩展 | P1-01 ~ P1-06 完成 | M2 |
| M4：应用愿景 | P2-01 ~ P2-06 选做 | M3 |

---

## 附录 A：术语表

| 术语 | 英文 | 定义 |
|------|------|------|
| 珠帘算子 | Pearl Curtain Operator (𝒫ℭ) | 将超图映射为 HoTT 类型空间的函子 |
| Dowker 复形 | Dowker Complex | 由超图诱导的单纯复形 D(H) |
| Univalence 公理 | Univalence Axiom | (A ≃ B) → (A = B)，Voevodsky |
| β-归约 | β-reduction | lambda 演算的计算规则 |
| 超图重写 | Hypergraph Rewriting | 将超边集 E 变换为 E' 的规则系统 |
| 关联矩阵 | Incidence Matrix | 编码顶点-超边隶属关系的布尔矩阵 |

---

*文档结束 — HypergraphHoTT PRD v1.0*
