(** * PearlCurtain — 珠帘算子 𝒫ℭ 定义
    珠帘算子是超图到 HoTT 类型空间的映射，是本库的核心桥接模块。
    𝒫ℭ(H) = Σ_{e ∈ E} Π_{v ∈ e} T_v
    即：选择一条超边 e，然后对该超边中每个节点 v 提供 T_v 的元素。

    作者: HypergraphHoTT 项目
    对应需求: P0-05
    对应理论: 定义 2.6

    注意：此模块是 MathComp 与 Coq-HoTT 的唯一交汇点，
    需要处理 Universe 边界。
*)

Set Universe Polymorphism.

From mathcomp Require Import ssreflect finmap.

Require Import HypergraphHoTT.Hypergraph.FinHypergraph.

Universe u.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Coercions.

(* ==================================================================== *)
(** * Coq-HoTT 兼容层 *)
(* ==================================================================== *)

(** 若 Coq-HoTT 不可用，使用以下兼容公理。
    这些公理在 Coq-HoTT 可用时应由库提供。 *)

Module HoTTCompat.

  (** Univalence 公理：(A ≃ B) → A = B *)
  Axiom univalence : forall (A B : Type@{u}), Equiv A B -> A = B.

  (** 类型等价 *)
  Record Equiv (A B : Type@{u}) : Type@{u} := mkEquiv {
    equiv_fun : A -> B;
    equiv_inv : B -> A;
    equiv_section : forall b, equiv_fun (equiv_inv b) = b;
    equiv_retraction : forall a, equiv_inv (equiv_fun a) = a;
  }.

  (** 路径类型（恒等类型）*)
  Inductive Id {A : Type@{u}} (x : A) : A -> Type@{u} :=
  | idpath : Id x x.

  Notation "x = y" := (Id x y) : type_scope.

  (** 路径归纳（J 规则）*)
  Axiom path_ind : forall (A : Type@{u}) (x : A)
    (P : forall y : A, x = y -> Type@{u}),
    P x idpath -> forall (y : A) (p : x = y), P y p.

  (** 传输 *)
  Axiom transport : forall (A : Type@{u}) (P : A -> Type@{u})
    (x y : A) (p : x = y), P x -> P y.

  (** 命题截断（n-截断）*)
  Axiom Trunc : nat -> Type@{u} -> Type@{u}.

  (** 截断层级谓词：IsTrunc n A 表示 A 是 n-截断的（即 n-型）*)
  Axiom IsTrunc : nat -> Type@{u} -> Type@{u}.

  (** 类型等价由 Univalence 诱导路径 *)
  Axiom path_universe : forall (A B : Type@{u}),
    Equiv A B -> A = B.

End HoTTCompat.

Export HoTTCompat.

(* ==================================================================== *)
(** * 有限集到 HoTT 类型的桥接 *)
(* ==================================================================== *)

(** 将 MathComp 的 finType 转为 HoTT 可用的 Type *)
Definition finType_to_Type (F : finType) : Type@{u} := F.

(** 将有限子集的成员关系转为 HoTT 可用的依赖类型 *)
Definition member_sig {V : finType} (e : {finset V}) : Type@{u} :=
  {v : V | v \in e}.

(* ==================================================================== *)
(** * 珠帘算子定义 *)
(* ==================================================================== *)

Section PearlCurtainDef.

Context {H : FinHypergraph}.
Variable T : V H -> Type@{u}.

(** 步骤 1：超边 → 依赖积
    对每条超边 e，构造依赖积 Π_{v ∈ e} T(v) *)
Definition DepEdge (e : {finset V}) : Type@{u} :=
  forall v : member_sig e, T (projT1 v).

(** 步骤 2：整体 → Σ_{e ∈ E} Π_{v ∈ e} T(v)
    珠帘类型 = 选择超边 × 该超边中每个节点的类型值 *)
Definition PearlCurtainType : Type@{u} :=
  { e : {finset (V H)} & DepEdge e }.

End PearlCurtainDef.

(* ==================================================================== *)
(** * 珠帘算子的基本性质 *)
(* ==================================================================== *)

Section PearlCurtainProperties.

Context {H : FinHypergraph}.
Variable T : V H -> Type@{u}.

(** 珠帘类型的投射函数 *)
Definition pearl_curtain_edge (x : PearlCurtainType T) : {finset V} :=
  projT1 x.

Definition pearl_curtain_val (x : PearlCurtainType T)
  (v : member_sig (pearl_curtain_edge x)) : T (projT1 v) :=
  projT2 x v.

(** 珠帘类型上的相等关系 *)
Definition pearl_curtain_eq (x y : PearlCurtainType T) : Prop :=
  pearl_curtain_edge x = pearl_curtain_edge y /\
  forall v, pearl_curtain_val x v = pearl_curtain_val y v.

(** 珠帘类型的元素构造 *)
Definition mk_pearl_curtain (e : {finset V})
  (Hei : e \in E H) (f : DepEdge T e) : PearlCurtainType T :=
  existT (DepEdge T) e f.

End PearlCurtainProperties.

(* ==================================================================== *)
(** * 珠帘算子作为超图态射的映射 *)
(* ==================================================================== *)

Section PearlCurtainMap.

Context {H1 H2 : FinHypergraph}.
Variable T1 : V H1 -> Type@{u}.
Variable T2 : V H2 -> Type@{u}.
Variable phi : HypergraphMorphism H1 H2.

(** 珠帘映射：从 H1 的珠帘类型到 H2 的珠帘类型 *)
Definition PearlCurtainMap : PearlCurtainType T1 -> PearlCurtainType T2 :=
  fun (x : PearlCurtainType T1) =>
    let e1 := projT1 x in
    let f1 := projT2 x in
    let e2 := fE phi e1 in
    (* 构造新超边上的依赖积：对 e2 中的每个顶点 w，
       需要从 e1 中的某个 v 使得 phi.fV v = w 来提供 T2(w) *)
    (* 注意：这里需要 T1 与 T2 之间的关系 *)
    existT (DepEdge T2) e2
      (fun w : member_sig e2 =>
        (* 简化假设：T1 和 T2 通过 phi 关联 *)
        (* 完整的函子性需要 T2 (phi.fV v) ≃ T1 v *)
        T2 (projT1 w)).

End PearlCurtainMap.

(* ==================================================================== *)
(** * 珠帘算子与 Dowker 复形的关联 *)
(* ==================================================================== *)

Section PearlCurtainDowker.

Context {H : FinHypergraph}.
Variable T : V H -> Type@{u}.

(** 珠帘类型到 Dowker nerve 的映射（组合部分）*)
Definition pearl_to_nerve (x : PearlCurtainType T) : {finset {finset V}} :=
  let e := projT1 x in
  [finset e].

(* 这建立了 𝒫ℭ(H) → Nerve(D(H)) 的初步映射，
   完整的拓扑等价证明在 CoreTheorems/TopologicalEquiv.v 中 *)

End PearlCurtainDowker.
