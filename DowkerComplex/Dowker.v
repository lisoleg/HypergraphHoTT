(** * Dowker — Dowker 复形定义与基本性质
    从超图 H 构造 Dowker 复形 D(H)，
    k-单形 = V' ⊆ V 使得 ∃e ∈ E, V' ⊆ e。
    这是超图到单纯复形的核心构造。

    作者: HypergraphHoTT 项目
    对应需求: P0-04
    对应理论: 定义 2.3
*)

From mathcomp Require Import ssreflect finmap.

Require Import HypergraphHoTT.Hypergraph.FinHypergraph.
Require Import HypergraphHoTT.DowkerComplex.Simplicial.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Coercions.

(* ==================================================================== *)
(** * Dowker 复形构造 *)
(* ==================================================================== *)

Section DowkerConstruction.

Context {H : FinHypergraph}.

(** Dowker 复形的单形判定：
    s 是 D(H) 的单形 ⟺ ∃e ∈ E(H), s ⊆ e *)
Definition is_dowker_simplex (s : {finset V}) : bool :=
  existsb (fun e : {finset V} => s \subset e) (enum (E H)).

(** Dowker 复形的单形集（排除空集：标准 Dowker 复形不含空单形）*)
Definition dowker_simplices : {finset {finset V}} :=
  [finset s in powerset [set: V] | (s != set0) && is_dowker_simplex s].

(** 面封闭性证明：若 s 是 Dowker 单形且 t ⊆ s，则 t 也是 *)
Lemma dowker_down_closed : forall s,
  s \in dowker_simplices -> forall t, t \subset s -> t \in dowker_simplices.
Proof.
  move=> s Hs t Hsub.
  rewrite /dowker_simplices in *.
  apply: finS_in.
  rewrite /is_dowker_simplex in *.
  (* 若 ∃e, s ⊆ e，则 t ⊆ s ⊆ e，故 t 也是 Dowker 单形 *)
  case: (existsb_exists (fun e : {finset V} => s \subset e) _) => [e [Hsub_se Hei]].
  apply: (existsb_exists (fun e : {finset V} => t \subset e)).
  exists e => //.
  exact: (subset_trans Hsub Hsub_se).
  (* 剩余目标：s ∈ dowker_simplices 蕴含 existsb ... *)
  (* 从 finS_in 的前提推导 *)
  move: Hs; rewrite finS_in => /existsb_exists [e' [Hse Hei']].
  by apply: (existsb_exists (fun e0 : {finset V} => t \subset e0)); exists e'.
Qed.

(** 非空性证明：Dowker 单形 s 非空，因为定义排除了空集 *)
Lemma dowker_nonempty : forall s,
  s \in dowker_simplices -> 0 < #|s|.
Proof.
  move=> s Hs.
  rewrite /dowker_simplices in Hs.
  (* s != set0 由过滤条件直接给出 *)
  case: (finS_in Hs) => Hne0 _.
  exact: cards_gt0.
Qed.

(** Dowker 复形 *)
Definition dowker_complex : SimplicialComplex :=
  {| V := V;
     S := dowker_simplices;
     down_closed := dowker_down_closed;
     nonempty := dowker_nonempty |}.

End DowkerConstruction.

(* ==================================================================== *)
(** * Dowker 复形的基本性质 *)
(* ==================================================================== *)

Section DowkerProperties.

Context {H : FinHypergraph}.

(** Dowker 复形包含每条超边作为单形 *)
Lemma edge_is_simplex : forall e,
  e \in E H -> e \in S (dowker_complex).
Proof.
  move=> e Hei.
  rewrite /dowker_complex /dowker_simplices.
  apply: finS_in.
  rewrite /is_dowker_simplex.
  (* e ⊆ e 是显然的，只需在 enum 中找到 e *)
  apply: (existsb_exists (fun e' : {finset V} => e \subset e')).
  exists e => //.
  (* e ∈ enum (E H) 因为 e ∈ E H *)
  by rewrite mem_enum.
Qed.

(** Dowker 复形的维度不超过最大超边基数 - 1 *)
Lemma dowker_dim_bound : dim (dowker_complex) <=
  \max_(e in E H) (#|e| - 1).
Proof.
  rewrite /dim /dowker_complex.
  (* dim K = max_{s in S K} (#|s| - 1) *)
  (* 对每个 Dowker 单形 s, ∃e ∈ E(H), s ⊆ e, 故 #|s| <= #|e| *)
  (* 因此 #|s| - 1 <= #|e| - 1 <= max_e (#|e| - 1) *)
  (* 需要遍历 dowker_simplices 中每个单形建立上界 *)
  (* Admitted: 需要 finset 上的大极大值引理，
     计划通过 bigmax_le 超边基数上界完成 *)
  Admitted.
Qed.

(** 超边不一定是极大 Dowker 单形（除非超图是简单超图）。
    反例：H = ({0,1,2}, {{0,1}, {0,1,2}}) 中 {0,1} ⊂ {0,1,2} ∈ E。
    需要添加"简单超图"条件：所有超边互不包含。 *)

(** 简单超图条件：超边互不包含 *)
Definition is_simple_hypergraph : bool :=
  forallb (fun e1 : {finset V} =>
    forallb (fun e2 : {finset V} =>
      (e1 \subset e2) ==> (e1 == e2)) (enum (E H)))
    (enum (E H)).

(** 简单超图中，超边是极大 Dowker 单形 *)
Lemma edge_maximal_simplex_simple :
  is_simple_hypergraph ->
  forall e,
  e \in E H -> e \in S (dowker_complex) ->
  forall s, e \subset s -> s \notin S (dowker_complex).
Proof.
  move=> Hsimple e Hei Hsi s Hsub.
  (* 在简单超图中，没有超边严格包含 e，
     因此 s 不能被任何超边包含 *)
  rewrite /dowker_complex /dowker_simplices /is_dowker_simplex.
  (* Admitted: 需要从 is_simple_hypergraph 推导不存在包含 e 的超边，
     计划通过 forallb_neg + subset_anti 完成 *)
  Admitted.
Qed.

End DowkerProperties.

(* ==================================================================== *)
(** * Dowker 复形与对偶超图 *)
(* ==================================================================== *)

Section DowkerDualRelation.

Context {H : FinHypergraph}.

(** H 的 Dowker 复形与 H* 的 Dowker 复形之间的关系 *)
Theorem dowker_dual_equiv :
  dim (dowker_complex H) = dim (dowker_complex (dual_hypergraph H)).
Proof.
  (* Dowker 定理：D(H) 和 D(H*) 具有相同的同伦型，
     因此维度相同 *)
  (* Admitted: 需要 Dowker 同伦等价定理的形式化，
     计划通过 nerve 构造与伴随性完成 *)
  Admitted.
Qed.

End DowkerDualRelation.

(* ==================================================================== *)
(** * Dowker 复形的 Nerve 构造 *)
(* ==================================================================== *)

Section NerveConstruction.

Context {H : FinHypergraph}.

(** Nerve 构造：D(H) 的 nerve 是一个单纯复形，
    其 k-单形是 D(H) 的 k+1 个单形的非空交集 *)

Definition nerve_simplex (K : SimplicialComplex) (sigma : {finset {finset V}}) : bool :=
  (sigma != set0) &&
  (forall s : {finset V}, s \in sigma -> s \in S K) &&
  let intersection := \bigcap_(s in sigma) s in
  intersection != set0.

Definition nerve (K : SimplicialComplex) : SimplicialComplex.
  (* Admitted: nerve 构造需要面封闭性和非空性的完整证明，
     计划通过 nerve_simplex 的定义推导 down_closed 和 nonempty 性质完成 *)
Admitted.

End NerveConstruction.
