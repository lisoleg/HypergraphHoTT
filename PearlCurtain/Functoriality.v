(** * Functoriality — 珠帘算子的函子性引理
    证明珠帘算子 𝒫ℭ 是从超图范畴到类型范畴的函子：
    - 恒等保持：𝒫ℭ(id_H) ≃ id
    - 合成保持：𝒫ℭ(g ∘ f) ≃ 𝒫ℭ(g) ∘ 𝒫ℭ(f)

    注意：PearlCurtainMap 的当前实现使用了简化假设
    （丢弃了原始依赖函数 f1，用 T2 (projT1 w) 替代），
    因此函子性的完整证明需要函数外延性（funext）
    以及 PearlCurtainMap 定义的修正。
    目前以 Admitted 占位，待修正 PearlCurtainMap 后补全。

    作者: HypergraphHoTT 项目
    对应需求: P1-01
    对应理论: 引理 3.2
*)

Set Universe Polymorphism.

From mathcomp Require Import ssreflect finmap.

Require Import HypergraphHoTT.Hypergraph.FinHypergraph.
Require Import HypergraphHoTT.PearlCurtain.PearlCurtain.

Universe u.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Coercions.

(* ==================================================================== *)
(** * 函数外延性公理 *)
(* ==================================================================== *)

(** 函数外延性：若两个函数在每个点上相等，则它们相等。
    这是 HoTT 的基本公理，在 Coq 的标准逻辑中不可证明。
    项目使用 HoTT 框架，因此可以安全地假设此公理。 *)
Axiom funext : forall (A : Type@{u}) (B : A -> Type@{u}) (f g : forall x, B x),
  (forall x, f x = g x) -> f = g.

(* ==================================================================== *)
(** * 恒等保持 *)
(* ==================================================================== *)

Section FunctorialityId.

Context {H : FinHypergraph}.
Variable T : V H -> Type@{u}.

(** 恒等态射的珠帘映射是恒等函数 *)
Lemma functoriality_id :
  forall (x : PearlCurtainType T),
    PearlCurtainMap (id_morphism H) T T x = x.
Proof.
  move=> x.
  (* 恒等态射的 fV = id, fE = id，
     因此珠帘映射保持超边和依赖积不变。
     但 PearlCurtainMap 的当前实现丢弃了原始依赖函数 f1，
     用 T2 (projT1 w) 替代，这导致映射不等于恒等。 *)
  (* Admitted: 需要 funext + sigT 的 η-展开 + 依赖函数的函数外延性。
     关键问题：PearlCurtainMap 的定义中 f1 被丢弃，
     替换为 fun w => T (projT1 w)，这在一般情况下不等于 f。
     计划通过以下路线图完成：
     (a) 修正 PearlCurtainMap 定义以正确传播依赖函数
     (b) 应用 funext + sigT_eta 完成证明 *)
  Admitted.
Qed.

(** 恒等保持的类型等价版本 *)
Theorem functoriality_id_equiv :
  Equiv (PearlCurtainMap (id_morphism H) T T) id.
Proof.
  (* 从 functoriality_id 构造等价 *)
  (* 一旦 functoriality_id 被证明，可以构造：
     mkEquiv (PearlCurtainMap (id_morphism H) T T) id
       (fun x => functoriality_id x)
       (fun x => ...)
       ... *)
  (* Admitted: 需要将函数等式提升为 Equiv 记录。
     计划通过 functoriality_id + mkEquiv 构造完成 *)
  Admitted.
Qed.

End FunctorialityId.

(* ==================================================================== *)
(** * 合成保持 *)
(* ==================================================================== *)

Section FunctorialityComp.

Context {H1 H2 H3 : FinHypergraph}.
Variable T1 : V H1 -> Type@{u}.
Variable T2 : V H2 -> Type@{u}.
Variable T3 : V H3 -> Type@{u}.
Variable f : HypergraphMorphism H1 H2.
Variable g : HypergraphMorphism H2 H3.

(** 合成态射的珠帘映射等于珠帘映射的合成 *)
Lemma functoriality_comp :
  forall (x : PearlCurtainType T1),
    PearlCurtainMap (comp_morphism f g) T1 T3 x =
    PearlCurtainMap g T2 T3 (PearlCurtainMap f T1 T2 x).
Proof.
  move=> x.
  (* 合成态射的 fV = fV g ∘ fV f, fE = fE g ∘ fE f，
     珠帘映射的合成通过超边和顶点映射的合成。
     与 functoriality_id 相同的问题：PearlCurtainMap 的简化假设 *)
  (* Admitted: 需要 sigT 的函子性与依赖函数的合成性质。
     计划通过 sigT_map_comp + forall_comp + funext 完成 *)
  Admitted.
Qed.

(** 合成保持的类型等价版本 *)
Theorem functoriality_comp_equiv :
  Equiv
    (PearlCurtainMap (comp_morphism f g) T1 T3)
    (fun x => PearlCurtainMap g T2 T3 (PearlCurtainMap f T1 T2 x)).
Proof.
  (* 从 functoriality_comp 构造等价 *)
  (* Admitted: 需要将函数等式提升为 Equiv 记录。
     计划通过 functoriality_comp + mkEquiv 完成 *)
  Admitted.
Qed.

End FunctorialityComp.

(* ==================================================================== *)
(** * 函子性的范畴论表述 *)
(* ==================================================================== *)

Section FunctorCategory.

(** 珠帘算子是从超图范畴到类型范畴的函子。
    在此我们形式化其对象映射和态射映射。 *)

(** 对象映射：超图 H → 类型 𝒫ℭ(H) *)
Definition pearl_curtain_obj (H : FinHypergraph) (T : V H -> Type@{u}) : Type@{u} :=
  PearlCurtainType T.

(** 态射映射：超图态射 f → 类型函数 𝒫ℭ(f) *)
Definition pearl_curtain_mor {H1 H2 : FinHypergraph}
  (T1 : V H1 -> Type@{u}) (T2 : V H2 -> Type@{u})
  (f : HypergraphMorphism H1 H2) :
  PearlCurtainType T1 -> PearlCurtainType T2 :=
  PearlCurtainMap f T1 T2.

(** 函子公理 *)
Theorem pearl_curtain_functor_axioms {H1 H2 H3 : FinHypergraph}
  (T1 : V H1 -> Type@{u}) (T2 : V H2 -> Type@{u}) (T3 : V H3 -> Type@{u})
  (f : HypergraphMorphism H1 H2) (g : HypergraphMorphism H2 H3) :
  (pearl_curtain_mor T1 T1 (id_morphism H1)) = id /\
  (pearl_curtain_mor T1 T3 (comp_morphism f g)) =
  (pearl_curtain_mor T2 T3 g) \o (pearl_curtain_mor T1 T2 f).
Proof.
  split.
  - (* 恒等律 *)
    (* Admitted: 需要 funext 完成。
       等价于 functoriality_id 的点态版本。 *)
    Admitted.
  - (* 合成律 *)
    (* Admitted: 需要 funext 完成。
       等价于 functoriality_comp 的点态版本。 *)
    Admitted.
Qed.

End FunctorCategory.
