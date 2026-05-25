From mathcomp Require Import ssreflect fintype finset.
Set Implicit Arguments.

Lemma test : forall (T : finType) (A : {set T}) (x : T), x \in A -> True.
Proof. move=> ? ? ? _. exact: I. Qed.
