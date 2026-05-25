From mathcomp Require Import ssreflect fintype finset.
Set Implicit Arguments.

Record FinHypergraph : Type := mkHypergraph {
  V : finType;
  E : set_of (set_of V);
  card_min : forall e, e \in E -> (2 <= #|e|)%N;
}.
