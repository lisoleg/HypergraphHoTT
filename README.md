# HypergraphHoTT

**超图 ↔ 同伦类型论珠帘合璧统合框架** — Coq 形式化验证库

将超图理论与同伦类型论 (HoTT) 之间的"珠帘合璧"对应关系进行严格形式化验证。

## 核心理论

- **珠帘算子 𝒫ℭ**：超图 → 类型空间的构造性映射
  - 节点 → 和类型（珠）：`v ↦ T_v`，整体 `Σ_v T_v`
  - 超边 → 依赖积（帘）：`e ↦ Π_{v∈e} T_v`
  - 超图整体 → 类型空间：`𝒫ℭ(H) = Σ_{e∈E} Π_{v∈e} T_v`

- **主定理 3.3（超图-类型等价定理）**：
  - (a) 拓扑等价：`|𝒫ℭ(H)| ≃ |D(H)|`
  - (b) 结构决定类型：`D(H₁) ≃ D(H₂) ⇒ 𝒫ℭ(H₁) ≃ 𝒫ℭ(H₂)`
  - (c) Univalence 对应：`H₁ ≅ H₂` 诱导 `𝒫ℭ(H₁) = 𝒫ℭ(H₂)`

## 项目结构

```
HypergraphHoTT/
├── Hypergraph/           # 数据层：超图定义
│   ├── FinHypergraph.v   # 有限超图
│   ├── IncidenceMatrix.v # 关联矩阵与对偶超图
│   └── RewriteSystem.v   # 超图重写系统
├── DowkerComplex/        # 构造层：Dowker复形
│   ├── Simplicial.v      # 单纯复形基础设施
│   └── Dowker.v          # Dowker复形定义
├── PearlCurtain/         # 构造层：珠帘算子
│   ├── PearlCurtain.v    # 珠帘算子定义
│   └── Functoriality.v   # 函子性引理
├── CoreTheorems/         # 定理层：核心定理
│   ├── TopologicalEquiv.v       # 定理3.3(a)
│   ├── StructureDetermines.v    # 定理3.3(b)
│   ├── UnivalenceCorrespond.v   # 定理3.3(c)
│   ├── StructuralInvariant.v    # 推论3.4
│   └── RewriteBeta.v            # 定理3.5
├── Applications/         # 应用层
│   ├── OrganizationHypergraph.v # 组织超图
│   ├── ConsciousnessType.v      # 意识类型
│   ├── Conjectures.v            # 可证伪预言
│   └── NaturalSystems.v         # 自然系统
├── Verification/         # 验证层
│   ├── Examples.v               # 数值验证示例
│   └── GudhiInterface.md        # gudhi接口说明
├── docs/                 # 文档
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   └── QA_REPORT.md
├── _CoqProject
├── dune-project
└── dune
```

## 依赖

- Coq 8.18+
- [coq-hott](https://github.com/HoTT/Coq-HoTT)（Univalence 公理与路径类型）
- [coq-mathcomp-ssreflect](https://math-comp.github.io/)（有限集与矩阵）
- [coq-mathcomp-finmap](https://github.com/math-comp/finmap)（有限映射）
- dune（构建系统）

## 构建与安装

```bash
# 安装依赖
opam install coq-hott coq-mathcomp-ssreflect coq-mathcomp-finmap

# 编译
dune build

# 运行验证示例
dune exec verify_examples
```

## 形式化状态

| 定理 | 状态 | 备注 |
|------|------|------|
| 珠帘算子定义 | ✅ 完整 | Σ_e Π_v T_v 依赖类型嵌套 |
| 函子性 (引理3.2) | ✅ 完整 | id 与复合保持 |
| 拓扑等价 (定理3.3a) | 🔄 Admitted | 需几何实现同伦等价 |
| 结构决定类型 (定理3.3b) | 🔄 Admitted | 函子性推论 |
| Univalence对应 (定理3.3c) | ✅ 完整 | Univalence 公理直接应用 |
| 推论3.4 | 🔄 Admitted | 同伦不变量 |
| 重写-β归约 (定理3.5) | 🔄 Admitted | 自然变换交换图 |

## 参考文献

- 微信公众号"复合体理学"：《超图↔同伦类型论珠帘合璧统合框架》

## 许可证

MIT License
