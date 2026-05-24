(** * FinHypergraph — 有限超图定义
    定义有限超图的核心数据结构，包括顶点集、超边集与基数约束。
    这是整个 HypergraphHoTT 库的基础模块。

    作者: HypergraphHoTT 项目
    对应需求: P0-01
    对应理论: 定义 2.1
*)

From mathcomp Require Import ssreflect finmap.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Coercions.

(* ==================================================================== *)
(** * 有限超图 Record *)
(* ==================================================================== *)

(** 有限超图由有限顶点集 V、有限超边集 E（每个超边是 V 的子集）、
    以及基数约束（每条超边至少包含 2 个顶点）组成。 *)

Record FinHypergraph : Type := mkHypergraph {
  V : finType;                                   (** 顶点集：有限类型 *)
  E : {finset {finset V}};                       (** 超边集：有限集的有限集 *)
  card_min : forall e, e \in E -> 2 <= #|e|;     (** 基数约束：|e| >= 2 *)
}.

(* ==================================================================== *)
(** * 超图基本操作 *)
(* ==================================================================== *)

(** 获取超图的顶点数 *)
Definition num_vertices (H : FinHypergraph) : nat := #|V H|.

(** 获取超图的超边数 *)
Definition num_edges (H : FinHypergraph) : nat := #|E H|.

(** 判断顶点 v 是否属于超边 e *)
Definition vertex_in_edge (H : FinHypergraph) (v : V H) (e : {finset V}) : bool :=
  v \in e.

(** 判断顶点 v 是否属于超图的某条超边 *)
Definition vertex_in_hypergraph (H : FinHypergraph) (v : V H) : bool :=
  existsb (fun e : {finset V} => v \in e) (enum (E H)).

(** 获取包含顶点 v 的所有超边 *)
Definition edges_of_vertex (H : FinHypergraph) (v : V H) : {finset {finset V}} :=
  [finset e in E | v \in e].

(** 获取超边 e 的所有顶点（即 e 本身作为集合的枚举）*)
Definition vertices_of_edge (H : FinHypergraph) (e : {finset V}) : {finset V} :=
  e.

(* ==================================================================== *)
(** * 超图态射 *)
(* ==================================================================== *)

(** 超图态射：顶点映射 fV 与超边映射 fE，满足兼容性条件：
    若 v 属于 e，则 fV(v) 属于 fE(e)。 *)
Record HypergraphMorphism (H1 H2 : FinHypergraph) : Type := mkMorphism {
  fV : V H1 -> V H2;                                         (** 顶点映射 *)
  fE : {finset (V H1)} -> {finset (V H2)};                    (** 超边映射 *)
  fE_preserves : forall e, e \in E H1 -> fE e \in E H2;       (** fE 保持超边 *)
  compat : forall (e : {finset (V H1)}) (v : V H1),
    v \in e -> e \in E H1 -> fV v \in fE e;                   (** 兼容性条件 *)
}.

(* ==================================================================== *)
(** * 超图同构 *)
(* ==================================================================== *)

(** 超图同构：双射态射 *)
Record HypergraphIso (H1 H2 : FinHypergraph) : Type := mkIso {
  iso_fV : V H1 -> V H2;                                     (** 顶点双射 *)
  iso_fE : {finset (V H1)} -> {finset (V H2)};                (** 超边双射 *)
  iso_fV_bij : bijective iso_fV;                              (** 顶点双射性 *)
  iso_fE_bij : bijective iso_fE;                              (** 超边双射性 *)
  iso_preserves : forall e, e \in E H1 -> iso_fE e \in E H2; (** 保持超边 *)
  iso_compat : forall (e : {finset (V H1)}) (v : V H1),
    v \in e -> e \in E H1 -> iso_fV v \in iso_fE e;           (** 兼容性 *)
}.

(* ==================================================================== *)
(** * 恒等态射与合成 *)
(* ==================================================================== *)

(** 恒等态射 *)
Definition id_morphism (H : FinHypergraph) : HypergraphMorphism H H :=
  {| fV := id; fE := id;
     fE_preserves := fun _ Hin => Hin;
     compat := fun _ _ Hvin _ => Hvin |}.

(** 态射合成 *)
Definition comp_morphism (H1 H2 H3 : FinHypergraph)
  (g : HypergraphMorphism H2 H3) (f : HypergraphMorphism H1 H2) :
  HypergraphMorphism H1 H3 :=
  {| fV := fV g \o fV f;
     fE := fE g \o fE f;
     fE_preserves := fun e Hin =>
       fE_preserves g _ (fE_preserves f _ Hin);
     compat := fun e v Hvin Hei =>
       compat g _ _ (compat f _ _ Hvin Hei)
                   (fE_preserves f _ Hei) |}.

(* ==================================================================== *)
(** * 超图基本引理 *)
(* ==================================================================== *)

Lemma card_min_ltn0 (H : FinHypergraph) (e : {finset V}) :
  e \in E H -> 0 < #|e|.
Proof.
  move=> Hei; apply: leq_trans (card_min _ Hei) _; lia.
Qed.

Lemma edge_not_empty (H : FinHypergraph) (e : {finset V}) :
  e \in E H -> e != set0.
Proof.
  move=> Hei; apply: contraNneq (card_min _ Hei) => ->.
  by rewrite cards0.
Qed.

Lemma edges_of_vertex_subset (H : FinHypergraph) (v : V H) :
  edges_of_vertex H v \subset E H.
Proof.
  by apply: finS_sub.
Qed.

Lemma num_vertices_pos (H : FinHypergraph) :
  0 < num_vertices H <-> E H != set0.
Proof.
  split=> [/eqnP Heq|/finset_neq0 [e Hei]].
  -  move: Hei; rewrite -Heq cards0 eqxx => /eqP. by case.
  -  apply: contraNneq Hei => /eqnP Hempty.
     move: Hei; rewrite Hempty cards0 eqxx => /eqP. by case.
Qed.

(* ==================================================================== *)
(** * 小型超图构造示例 *)
(* ==================================================================== *)

Section SmallHypergraphExample.

(** 3 顶点、2 超边的示例超图 *)
Let example_V : finType := [finType of 'I_3].
Let example_E : {finset {finset example_V}} :=
  [finset [set val (Ordinal (erefl true) : example_V);
            val (Ordinal (erefl true) : example_V);
            val (Ordinal (erefl true) : example_V)];
        [set val (Ordinal (erefl true) : example_V);
            val (Ordinal (erefl true) : example_V)]].

End SmallHypergraphExample.
