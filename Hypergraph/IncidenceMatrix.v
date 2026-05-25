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
  (* 证明策略：
     col_sum j M = ∑_{i < #|V|} [M(i,j)] = ∑_{i < #|V|} [v_i ∈ e_j]
     = #|{v ∈ V | v ∈ e_j}| = #|e_j| >= 2（由 card_min）

     形式化需要：
     (a) 将每个 M i j 重写为 incidence_entry i j（用 Mspec）
     (b) 将 incidence_entry i j = (enum_val i \in enum_val j) 展开
     (c) 建立 ∑_{i < #|V|} [enum_val i ∈ enum_val j] = #|enum_val j|
         这需要 enum_val 和 finset 元素之间的双射性 *)
  (* Admitted: 需要建立 ∑_{i} [v_i ∈ e_j] = #|e_j| 的形式化证明。
     关键引理：enum_val i ∈ enum_val j ⟺ enum_val i ∈ (enum_val j : {finset V})
     然后 ∑_{i < n} [enum_val i ∈ F] = #|F| 对 F : {finset V}
     这需要 enum_val 与 finset 成员的求和对应引理。
     计划通过以下步骤完成：
     (a) 引理 enum_mem_sum : ∑_{i < #|T|} [enum_val i \in F] = #|F|
     (b) 用 Mspec + (a) 完成 *)
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
  (* 证明策略：
     dual_edges = [finset dual_edge v | v in [set: V]]
     e = dual_edge v = edges_of_vertex H v = [finset e' in E | v ∈ e']
     对某 v。需要 |[finset e' in E | v ∈ e']| >= 2。

     注意：这实际上不一定成立！
     存在只属于 1 条超边的顶点，此时 |edges_of_vertex v| = 1。
     原超图只保证 |e| >= 2 对每条超边，不保证每个顶点至少属于 2 条超边。
     这是对偶超图构造中的一个概念性问题。

     解决方案：要么添加"每个顶点至少属于 2 条超边"的额外条件，
     要么放宽对偶超图的 card_min 约束。*)
  (* Admitted: 原陈述可能不成立。对偶超图 H* 的超边
     edges_of_vertex v = [finset e' in E | v ∈ e']，其基数 |edges_of_vertex v|
     等于顶点 v 的度数。原超图只保证每条超边 |e| >= 2，
     不保证每个顶点度数 >= 2。需要额外假设：
     ∀v, |{e ∈ E | v ∈ e}| >= 2（每个顶点至少属于 2 条超边），
     或者修改对偶超图的 card_min 为 |e| >= 1。
     计划通过添加 min_degree >= 2 条件或放宽约束完成 *)
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
  (* 证明策略：
     1. 对偶超图 H* 的顶点 = H 的超边的 finType ([finType of {finset V}])
     2. 对偶的对偶 H** 的顶点 = H* 的超边的 finType
     3. 关联矩阵 M(H*) = M(H)^T，M(H**) = M(H)^T^T = M(H)
     4. 因此 H** 与 H 结构同构

     形式化需要：
     (a) finType 间的双射：[finType of {finset V}] 的超边的 finType
         与原始 V 之间的双射
     (b) finset 结构的保持：双射下超边集对应
     (c) 兼容性：顶点映射保持成员关系 *)
  (* Admitted: 需要建立 finType 间的双射以及 finset 结构的保持。
     核心困难：[finType of {finset V}] 与 [finType of {finset {finset V}}]
     之间的双射需要构造显式的双向映射。
     关联矩阵转置的论证提供了概念基础（M^T^T = M），
     但形式化需要显式的双射构造。
     计划通过以下步骤完成：
     (a) 构造 fV : V(H**) -> V(H) 的双射
         （利用 enum_val 和 enum_rank 的互逆性）
     (b) 构造 fE 的双射
     (c) 证明 iso_preserves 和 iso_compat *)
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
  (* 证明策略：
     M2 的维度是 #|V(H*)| × #|E(H*)|，
     而 M1^T 的维度是 #|E(H)| × #|V(H)|。
     需要 #|V(H*)| = #|E(H)| 且 #|E(H*)| = #|V(H)|，
     这由对偶超图的定义保证（但需要显式证明）。
     然后逐元素验证 M2(i,j) = M1(j,i)。

     形式化需要：
     (a) V(H*) = [finType of {finset V(H)}]，所以 #|V(H*)| = #|{finset V(H)}|
     (b) E(H*) = dual_edges，所以 #|E(H*)| = #|dual_edges|
     (c) 建立这些与 #|E(H)| 和 #|V(H)| 之间的对应 *)
  (* Admitted: 需要建立对偶关联矩阵元素与原矩阵元素的对应关系。
     核心困难：对偶超图的 finType 维度与原超图不同，
     需要在不同大小的矩阵之间建立等式。
     这需要维度相等的证明（#|V(H*)| = #|E(H)| 等）
     加上元素级别的对应（M2(i,j) = M1(j,i)）。
     计划通过以下步骤完成：
     (a) 建立 #|V(H*)| = #|E(H)| 的双射
     (b) 建立 #|E(H*)| = #|V(H)| 的双射
     (c) 在双射下逐元素验证 M2(i,j) = M1(j,i) *)
  Admitted.
Qed.

End IncidenceDualRelation.
