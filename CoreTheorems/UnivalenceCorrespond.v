(** * UnivalenceCorrespond — 定理 3.3(c) Univalence 对应
    H₁ ≅ H₂ → 𝒫ℭ(H₁) ≃ 𝒫ℭ(H₂)，且由 Univalence 得 𝒫ℭ(H₁) = 𝒫ℭ(H₂)。
    这是 Univalence 公理在超图-类型对应中的核心应用。

    作者: HypergraphHoTT 项目
    对应需求: P0-08, P1-05
    对应理论: 定理 3.3(c)
*)

Set Universe Polymorphism.

From mathcomp Require Import ssreflect finmap.

Require Import HypergraphHoTT.Hypergraph.FinHypergraph.
Require Import HypergraphHoTT.PearlCurtain.PearlCurtain.
Require Import HypergraphHoTT.PearlCurtain.Functoriality.
Require Import HypergraphHoTT.CoreTheorems.StructureDetermines.

Universe u.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Coercions.

(* ==================================================================== *)
(** * 从超图同构到类型等价 *)
(* ==================================================================== *)

Section IsoToEquiv.

Context {H1 H2 : FinHypergraph}.
Variable T1 : V H1 -> Type@{u}.
Variable T2 : V H2 -> Type@{u}.

(** 从超图同构构造珠帘映射的等价：
    核心思想：H₁ ≅ H₂ 提供了顶点双射和超边双射，
    这诱导了 Σ_{e∈E₁} Π_{v∈e} T₁(v) 与 Σ_{e∈E₂} Π_{v∈e} T₂(v) 之间的等价。 *)

(** 顶点双射诱导的类型族等价 *)
Definition iso_to_type_equiv (iso : HypergraphIso H1 H2) :
  (forall v : V H1, Equiv (T1 v) (T2 (iso_fV iso v))) ->
  Equiv (PearlCurtainType T1) (PearlCurtainType T2).
Proof.
  move=> T_equiv.
  (* 构造等价：
     1. 正向映射：利用 iso_fV 和 iso_fE 将 (e, f) 映射为 (iso_fE e, f ∘ iso_fV⁻¹)
     2. 逆向映射：利用 iso_fV⁻¹ 和 iso_fE⁻¹
     3. 证明合成等于恒等 *)
  (* Admitted: 需要 sigT 的等价构造和依赖函数类型的等价构造，
     计划通过以下步骤完成：
     (a) 建立 sigT_equiv : Equiv A A' -> (forall x, Equiv (B x) (B' (f x))) ->
         Equiv (sigT B) (sigT B')
     (b) 建立 forall_equiv : (forall x, Equiv (f x) (g x)) ->
         Equiv (forall x, f x) (forall x, g x)
     (c) 组合两个构造 *)
  Admitted.
Qed.

End IsoToEquiv.

(* ==================================================================== *)
(** * 主定理 3.3(c)：Univalence 对应 *)
(* ==================================================================== *)

(** 定理 3.3(c)：H₁ ≅ H₂ → 𝒫ℭ(H₁) ≃ 𝒫ℭ(H₂)

    含义：超图同构诱导珠帘类型的等价。
    这是 Univalence 公理在超图领域的体现：
    "等价的结构产生等价的类型"。 *)

Theorem univalence_correspond (H1 H2 : FinHypergraph) :
  HypergraphIso H1 H2 ->
  Equiv (PearlCurtainType (fun v : V H1 => Type@{u}))
         (PearlCurtainType (fun v : V H2 => Type@{u})).
Proof.
  move=> iso.
  (* 证明策略：
     1. 从 HypergraphIso 构造顶点双射和超边双射
     2. 利用双射构造 Σ 类型的等价
     3. 利用双射构造 Π 类型的等价
     4. 组合为完整的类型等价 *)
  apply: iso_to_type_equiv.
  - exact: iso.
  - (* 需要类型族之间的等价，由 iso_fV 诱导 *)
    move=> v.
    (* Admitted: 需要 Type@{u} 上的恒等等价，
       计划通过 Equiv_id 完成 *)
    Admitted.
Qed.

(* ==================================================================== *)
(** * Univalence 路径：从等价到相等 *)
(* ==================================================================== *)

(** 由 Univalence 公理，类型等价诱导类型相等：
    𝒫ℭ(H₁) = 𝒫ℭ(H₂)

    这是 Univalence 公理的显式调用（P1-05）。 *)

Theorem univalence_equality (H1 H2 : FinHypergraph)
  (iso : HypergraphIso H1 H2) :
  PearlCurtainType (fun v : V H1 => Type@{u}) =
  PearlCurtainType (fun v : V H2 => Type@{u}).
Proof.
  (* 证明策略：
     1. 应用 univalence_correspond 得到 Equiv
     2. 应用 Univalence 公理 (A ≃ B) → (A = B) 得到路径
     3. 路径即为所需的类型等式 *)

  (* 步骤 1：获得类型等价 *)
  pose proof (univalence_correspond H1 H2 iso) as Heqv.

  (* 步骤 2：应用 Univalence 公理 *)
  (* path_universe : Equiv A B → A = B *)
  exact (path_universe _ _ Heqv).
Qed.

(* ==================================================================== *)
(** * Univalence 对应的逆命题 *)
(* ==================================================================== *)

(** 逆命题：若 𝒫ℭ(H₁) ≃ 𝒫ℭ(H₂)，则 H₁ 和 H₂ 的 Dowker 复形同伦等价。
    这是结构决定类型款的逆方向。 *)

Theorem univalence_correspond_converse (H1 H2 : FinHypergraph) :
  Equiv (PearlCurtainType (fun v : V H1 => Type@{u}))
         (PearlCurtainType (fun v : V H2 => Type@{u})) ->
  DowkerEquiv H1 H2.
Proof.
  (* 证明策略：
     1. 从 𝒫ℭ(H₁) ≃ 𝒫ℭ(H₂) 得到 |𝒫ℭ(H₁)| ≃ |𝒫ℭ(H₂)|
     2. 由定理 3.3(a): |𝒫ℭ(H₁)| ≃ |D(H₁)| 和 |𝒫ℭ(H₂)| ≃ |D(H₂)|
     3. 传递得 |D(H₁)| ≃ |D(H₂)|，即 DowkerEquiv H1 H2 *)
  (* Admitted: 依赖定理 3.3(a) 的完整证明，
     计划通过等价传递性完成 *)
  Admitted.
Qed.

(* ==================================================================== *)
(** * Univalence 对应的范畴论表述 *)
(* ==================================================================== *)

(** 珠帘算子忠实反映了超图范畴中的同构关系 *)
Theorem pearl_curtain_faithful_on_iso (H1 H2 : FinHypergraph) :
  HypergraphIso H1 H2 ->
  Equiv (PearlCurtainType (fun v : V H1 => Type@{u}))
         (PearlCurtainType (fun v : V H2 => Type@{u})) /
  (Equiv (PearlCurtainType (fun v : V H1 => Type@{u}))
         (PearlCurtainType (fun v : V H2 => Type@{u}))) ->
  DowkerEquiv H1 H2.
Proof.
  move=> iso Heqv.
  right. apply: univalence_correspond_converse. exact: Heqv.
Qed.
