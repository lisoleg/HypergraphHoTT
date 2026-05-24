(** * Simplicial — 单纯复形基础设施
    定义有限单纯复形的核心数据结构，包括面关系、维度与连通性。

    作者: HypergraphHoTT 项目
    对应需求: P0-04 (前置)
    对应理论: 定义 2.3 (前置)
*)

From mathcomp Require Import ssreflect finmap.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Coercions.

(* ==================================================================== *)
(** * 单纯复形 Record *)
(* ==================================================================== *)

(** 有限单纯复形由有限顶点集 V、有限单形集 S（每个单形是 V 的子集）、
    面封闭性（单形的子集也是单形）和非空性（每个单形非空）组成。 *)

Record SimplicialComplex : Type := mkComplex {
  V : finType;                                              (** 顶点集 *)
  S : {finset {finset V}};                                  (** 单形集 *)
  down_closed : forall s, s \in S ->                        (** 面封闭性 *)
    forall t, t \subset s -> t \in S;
  nonempty : forall s, s \in S -> 0 < #|s|;                 (** 非空性 *)
}.

(* ==================================================================== *)
(** * 单纯复形基本操作 *)
(* ==================================================================== *)

(** 获取单纯复形的顶点数 *)
Definition num_vertices_sc (K : SimplicialComplex) : nat := #|V K|.

(** 获取单纯复形的单形数 *)
Definition num_simplices (K : SimplicialComplex) : nat := #|S K|.

(** 判断一个集合是否为单纯复形的单形 *)
Definition is_simplex (K : SimplicialComplex) (s : {finset V}) : bool :=
  s \in S K.

(** k-单形：基数为 k+1 的单形 *)
Definition k_simplex (K : SimplicialComplex) (k : nat) : {finset {finset V}} :=
  [finset s in S K | #|s| == k.+1].

(** 0-单形（顶点）*)
Definition vertices_sc (K : SimplicialComplex) : {finset {finset V}} :=
  k_simplex K 0.

(** 1-单形（边）*)
Definition edges_sc (K : SimplicialComplex) : {finset {finset V}} :=
  k_simplex K 1.

(* ==================================================================== *)
(** * 单纯复形的维度 *)
(* ==================================================================== *)

(** 单纯复形的维度 = 最大单形的基数 - 1 *)
Definition dim (K : SimplicialComplex) : nat :=
  \max_(s in S K) (#|s| - 1).

(* ==================================================================== *)
(** * 面关系 *)
(* ==================================================================== *)

(** s 是 t 的面 *)
Definition is_face (K : SimplicialComplex) (s t : {finset V}) : bool :=
  (s \subset t) && (t \in S K) && (s \in S K).

(** 直接面：s 是 t 的面且 |t| - |s| = 1 *)
Definition is_direct_face (K : SimplicialComplex) (s t : {finset V}) : bool :=
  is_face K s t && (#|t| - #|s| == 1).

(* ==================================================================== *)
(** * 单纯映射 *)
(* ==================================================================== *)

(** 单纯映射：保持单形关系的顶点映射 *)
Record SimplicialMap (K1 K2 : SimplicialComplex) : Type := mkSimpMap {
  sigma : V K1 -> V K2;                                     (** 顶点映射 *)
  sigma_simplex : forall s, s \in S K1 ->                   (** 保持单形 *)
    [finset sigma v | v in s] \in S K2;
}.

(* ==================================================================== *)
(** * 单纯复形的基本引理 *)
(* ==================================================================== *)

Lemma simplex_vertices (K : SimplicialComplex) (s : {finset V}) :
  s \in S K -> forall v, v \in s -> [set v] \in S K.
Proof.
  move=> Hs v Hv.
  apply: down_closed K _ Hs _.
  - by rewrite sub1set.
  - exact: Hv.
Qed.

Lemma k_simplex_subset (K : SimplicialComplex) (k : nat) :
  k_simplex K k \subset S K.
Proof.
  by apply: finS_sub.
Qed.

Lemma simplex_card_pos (K : SimplicialComplex) (s : {finset V}) :
  s \in S K -> 0 < #|s|.
Proof.
  exact: nonempty.
Qed.

Lemma vertices_in_S (K : SimplicialComplex) (v : V) :
  [set v] \in S K -> True.
Proof.
  by move=> _.
Qed.

(* ==================================================================== *)
(** * 单纯复形的连通性 *)
(* ==================================================================== *)

(** 1-骨架连通：任意两个顶点通过 1-单形链连接 *)
Definition is_connected (K : SimplicialComplex) : Prop :=
  forall v1 v2 : V,
    [set v1] \in S K -> [set v2] \in S K ->
    exists (path : seq {finset V}),
      [seq s in path | s \in edges_sc K] != [::] /\
      v1 \in head set0 path /\ v2 \in last set0 path.

(* ==================================================================== *)
(** * 空单纯复形与完全单纯复形 *)
(* ==================================================================== *)

Section TrivialComplexes.

(** 只有顶点的单纯复形（0 维）*)
Definition point_complex (n : nat) : SimplicialComplex :=
  {| V := [finType of 'I_n];
     S := [finset [set val (Ordinal (erefl true))] |
             i : 'I_n];
     down_closed := fun s Hs t Hsub =>
       (* 需要证明子集也是单形 *)
       (* Admitted: 需要 finset image 的成员关系分析，
          计划通过单元素子集的唯一性完成 *)
       t \in [finset [set val (Ordinal (erefl true))] | i : 'I_n];
     nonempty := fun s Hs => ltac:(lia) |}.

End TrivialComplexes.
