(** * RewriteSystem — 超图重写系统
    定义超图上的重写规则、重写步骤与重写序列。
    重写规则 ρ 将超边集 E 变换为 E'，保持顶点集不变。

    作者: HypergraphHoTT 项目
    对应需求: P1-04
    对应理论: 定义 2.4
*)

From mathcomp Require Import ssreflect finmap.

Require Import HypergraphHoTT.Hypergraph.FinHypergraph.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Coercions.

(* ==================================================================== *)
(** * 重写规则 *)
(* ==================================================================== *)

(** 重写规则：将超边映射为超边的函数，保持基数约束。
    ρ : E → E' 是超边集上的变换，需满足：
    1. ρ(e) ∈ E' 对所有 e ∈ E 成立
    2. |ρ(e)| >= 2 保持基数约束 *)

Record RewriteRule (H : FinHypergraph) : Type := mkRewriteRule {
  rho : {finset (V H)} -> {finset (V H)};               (** 超边变换函数 *)
  rho_preserves : forall e, e \in E H -> rho e \in E H;  (** 保持超边成员关系 *)
  rho_card_min : forall e, e \in E H -> 2 <= #|rho e|;   (** 保持基数约束 *)
}.

(* ==================================================================== *)
(** * 重写步骤 *)
(* ==================================================================== *)

(** 一次重写步骤：将超图 H 通过规则 ρ 变换为新超图 H' *)
Definition apply_rewrite (H : FinHypergraph) (rho : RewriteRule H) : FinHypergraph.
Proof.
  exists (V H) [finset rho.(rho) e | e in E H].
  move=> e Hei.
  (* e ∈ [finset rho e' | e' in E H] 意味着 e = rho e' 对某 e' ∈ E H *)
  rewrite finS_imageP in Hei.
  case: Hei => e' Hei' Heq.
  rewrite -Heq.
  exact: (rho_card_min rho _ Hei').
Defined.

(** 重写步骤的关系：H →_ρ H' *)
Inductive RewriteStep : FinHypergraph -> FinHypergraph -> RewriteRule _ -> Prop :=
| mkRewriteStep : forall H (rho : RewriteRule H),
    RewriteStep H (apply_rewrite H rho) rho.

(* ==================================================================== *)
(** * 重写序列 *)
(* ==================================================================== *)

(** 多步重写：自反传递闭包 *)
Inductive RewriteSequence : FinHypergraph -> FinHypergraph -> Prop :=
| rewrite_seq_refl : forall H, RewriteSequence H H
| rewrite_seq_step : forall H1 H2 H3 (rho : RewriteRule H1),
    RewriteStep H1 H2 rho -> RewriteSequence H2 H3 -> RewriteSequence H1 H3.

(* ==================================================================== *)
(** * 重写系统的汇聚性（局部） *)
(* ==================================================================== *)

Section RewriteConfluence.

Context {H : FinHypergraph}.

(** 两条重写规则的交换性：若 ρ₁ 和 ρ₂ 均可应用于 H，
    则存在 H' 使得 ρ₁;ρ₂ 和 ρ₂;ρ₁ 均到达 H' *)
Definition locally_confluent (rho1 rho2 : RewriteRule H) : Prop :=
  exists H' : FinHypergraph,
    RewriteSequence (apply_rewrite H rho1) H' /\
    RewriteSequence (apply_rewrite H rho2) H'.

(* Admitted: 局部汇聚性的证明需要重写规则的交换性条件，
   计划通过建立临界对分析的形式化完成 *)
End RewriteConfluence.

(* ==================================================================== *)
(** * β-归约步 *)
(* ==================================================================== *)

(** β-归约步：在依赖类型理论中，(λx. t) u →β t[u/x]。
    重写-β归约对应定理（定理 3.5）将建立超图重写步与 β-归约步之间的对应。 *)

Inductive BetaStep : Type -> Type -> Prop :=
| beta_intro : forall (A B : Type) (f : A -> B) (a : A),
    BetaStep ((fun x : A => f x) a) (f a).

(* ==================================================================== *)
(** * 重写规则的基本性质 *)
(* ==================================================================== *)

Section RewriteProperties.

Context {H : FinHypergraph} (rho : RewriteRule H).

(** 恒等重写规则：ρ(e) = e *)
Definition id_rewrite : RewriteRule H :=
  {| rho := id; rho_preserves := fun _ => id; rho_card_min := fun e Hei => card_min _ Hei |}.

Lemma id_rewrite_apply : apply_rewrite H id_rewrite = H.
Proof.
  rewrite /apply_rewrite /id_rewrite.
  congr mkHypergraph.
  (* [finset id e | e in E H] = E H *)
  apply: finset_image_id.
Qed.

End RewriteProperties.
