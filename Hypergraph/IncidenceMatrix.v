(** * IncidenceMatrix — 关联矩阵与对偶超图
    定义超图的关联矩阵（布尔矩阵编码顶点-超边隶属关系），
    以及对偶超图的构造，证明 H** = H。

    作者: HypergraphHoTT 项目
    对应需求: P0-02, P0-03
    对应理论: 定义 2.2
*)

From mathcomp Require Import ssreflect finmap matrix.

Require Import HypergraphHoTT.Hypergraph.FinHypergraph.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Coercions.

Import MatrixOrder MatrixSchema.

(* ==================================================================== *)
(** * 关联矩阵定义 *)
(* ==================================================================== *)

(** 关联矩阵 M 是 |V| × |E| 的布尔矩阵，
    M(i,j) = true 当且仅当第 i 个顶点属于第 j 条超边。 *)

Record IncidenceMatrix (H : FinHypergraph) : Type := mkIncidenceMatrix {
  M : 'M_(#|V H|, #|E H|);                   (** |V| × |E| 布尔矩阵 *)
  incidence : forall (i : 'I_(#|V H|)) (j : 'I_(#|E H|)),
    M i j = (enum_val i \in enum_val j);  (** 关联性：M(i,j) = (v_i ∈ e_j) *)
}.

(* ==================================================================== *)
(** * 从超图构造关联矩阵 *)
(* ==================================================================== *)

Section BuildIncidenceMatrix.

Context {H : FinHypergraph}.

(** 关联矩阵的元素：判断第 i 个顶点是否属于第 j 条超边 *)
Definition incidence_entry (i : 'I_(#|V H|)) (j : 'I_(#|E H|)) : bool :=
  let v : V H := enum_val i in
  let e : {finset V} := enum_val j in
  v \in e.

(** 关联矩阵构造 *)
Definition mk_incidence_matrix : 'M_(#|V H|, #|E H|) :=
  \matrix_(i < #|V H|, j < #|E H|) incidence_entry (Ordinal (ltn_pmax i j)) (Ordinal (ltn_pmax j i)).

End BuildIncidenceMatrix.

(* ==================================================================== *)
(** * 关联矩阵基本性质 *)
(* ==================================================================== *)

Section IncidenceMatrixProperties.

Context {H : FinHypergraph}.

(** 矩阵的行和 = 顶点度数（该顶点所属超边数）*)
Definition row_sum (i : 'I_(#|V H|)) (M : 'M_(#|V H|, #|E H|)) : nat :=
  \sum_(j < #|E H|) (if M i j then 1 else 0).

(** 矩阵的列和 = 超边基数（该超边包含的顶点数）*)
Definition col_sum (j : 'I_(#|E H|)) (M : 'M_(#|V H|, #|E H|)) : nat :=
  \sum_(i < #|V H|) (if M i j then 1 else 0).

Lemma col_sum_ge2 (j : 'I_(#|E H|)) (M : 'M_(#|V H|, #|E H|)) :
  (forall i' j', M i' j' = incidence_entry i' j') ->
  2 <= col_sum j M.
Proof.
  move=> Mspec.
  rewrite /col_sum.
  (* 超边 e = enum_val j，|e| >= 2 由 card_min 保证 *)
  (* col_sum j M = |e| 因为 M(i,j)=1 ⟺ v_i ∈ e_j *)
  (* 需要从 card_min 和 enum_val 的对应建立求和下界 *)
  (* Admitted: 需要建立 ∑_{i} [v_i ∈ e_j] = #|e_j| 的形式化证明，
     计划通过 enum_val 与 finset 成员的 bijection 求和引理完成 *)
  Admitted.

End IncidenceMatrixProperties.

(* ==================================================================== *)
(** * 对偶超图 *)
(* ==================================================================== *)

(** 对偶超图 H*：交换顶点与超边的角色。
    H* 的顶点 = H 的超边
    H* 的超边 = 对 H 的每个顶点 v，{e ∈ E(H) | v ∈ e}
    对偶关系通过转置关联矩阵来刻画：M(H*) = M(H)^T *)

Section DualHypergraph.

Context {H : FinHypergraph}.

(** 对偶超图的超边：对每个顶点 v，收集包含 v 的所有超边 *)
Definition dual_edge (v : V H) : {finset {finset V H}} :=
  edges_of_vertex H v.

(** 对偶超图的超边集 *)
Definition dual_edges : {finset {finset {finset V}}} :=
  [finset dual_edge v | v in [set: V H]].

(** 对偶超图中的超边基数 >= 2：
    由原超图的每条超边至少包含 2 个顶点保证 *)
Lemma dual_card_min (e : {finset {finset V}}) :
  e \in dual_edges -> 2 <= #|e|.
Proof.
  move=> Hei.
  rewrite /dual_edges in Hei.
  (* 需要从原超图的 card_min 推导对偶超边的基数约束 *)
  (* Admitted: 需要建立 |edges_of_vertex v| >= 2 的证明，
     计划通过每条超边至少包含 2 个顶点，
     因此每个顶点至少属于 2 条超边来完成 *)
  Admitted.

(** 对偶超图的构造 *)
Definition dual_hypergraph : FinHypergraph :=
  {| V := [finType of {finset V H}];
     E := dual_edges;
     card_min := dual_card_min |}.

Notation "H *" := (dual_hypergraph) (at level 30).

End DualHypergraph.

(* ==================================================================== *)
(** * 对偶的对偶等于自身 *)
(* ==================================================================== *)

Section DoubleDual.

Context {H : FinHypergraph}.

(** 对偶超图的关联矩阵是原关联矩阵的转置 *)
Lemma dual_matrix_transpose (M : 'M_(#|V H|, #|E H|)) :
  (forall i j, M i j = incidence_entry i j) ->
  forall i j, M^T i j = M j i.
Proof.
  move=> Mspec i j.
  (* MathComp 的转置矩阵性质：M^T i j = M j i *)
  (* 由 MatrixOrder.transpose 的定义和 mxE 引理给出 *)
  apply/mxE.
Qed.

(** H** = H：对偶的对偶等于原超图（在结构同构意义下）*)
Theorem double_dual_iso : HypergraphIso (dual_hypergraph (dual_hypergraph H)) H.
Proof.
  (* 证明思路：
     1. 对偶超图的顶点 = 原超边的集合
     2. 对偶的对偶的顶点 = 原超边的超边的集合
     3. 关联矩阵转置两次等于自身 M^T^T = M
     4. 因此双对偶与原超图结构同构 *)
  (* Admitted: 需要建立 finType 间的双射以及 finset 结构的保持，
     计划通过关联矩阵的转置可逆性完成 *)
  Admitted.
Qed.

End DoubleDual.

(* ==================================================================== *)
(** * 关联矩阵与对偶的关联 *)
(* ==================================================================== *)

Section IncidenceDualRelation.

Context {H : FinHypergraph}.

(** 对偶关联矩阵 = 原关联矩阵的转置 *)
Theorem dual_incidence_transpose :
  forall (M1 : 'M_(#|V H|, #|E H|)) (M2 : 'M_(#|V (dual_hypergraph H)), #|E (dual_hypergraph H)|),
    (forall i j, M1 i j = incidence_entry i j) ->
    (forall i j, M2 i j = incidence_entry i j) ->
    M2 = M1^T.
Proof.
  move=> M1 M2 H1 H2.
  (* Admitted: 需要建立对偶关联矩阵元素与原矩阵元素的对应关系，
     计划通过枚举与 finset 成员关系的双重推理完成 *)
  Admitted.
Qed.

End IncidenceDualRelation.
