(* Banach-Tarski paradox. *)
(* Inspirations:
   - Stan Wagon: The Banach-Tarski Paradox, Cambridge University Press
   - Wikipedia: Banach–Tarski paradox
   - http://people.math.umass.edu/~weston/oldpapers/banach.pdf *)
(* Coq v8.6 *)

Require Import Utf8 List NPeano Compare_dec Setoid.
Import ListNotations.

Require Import Pset.

Definition is_partition {A} {S : set_model A} E Ep :=
  (E = ⋃ Ep)%S ∧
  ∀ i j, i ≠ j → (Ep.[i] ∩ Ep.[j] = ∅)%S.

Theorem is_partition_group_first_2_together :
  ∀ A (s := set_equiv) (F : set A) P₁ P₂ Pl,
  is_partition F (P₁ :: P₂ :: Pl)
  → is_partition F (P₁ ∪ P₂ :: Pl).
Proof.
intros * Hp.
destruct Hp as (Hu & Hi).
split.
 unfold union_list, union, set_eq in Hu |-*.
 subst s; simpl in Hu |-*.
 intros x.
 pose proof Hu x as H₁.
 destruct H₁ as (H₁ & H₂).
 split; intros H.
  apply H₁ in H.
  destruct H as [H| H]; [ left; left; easy | ].
  destruct H as [H| H]; [ left; right; easy | ].
  now right.

  apply H₂.
  destruct H as [[H| H]| H]; [ left; easy | right; left; easy | ].
  right; right; easy.

 intros i j Hij; subst s.
 destruct i.
  unfold intersection, set_eq; simpl.
  intros x.
  split; [ | easy ].
  intros (H₁, H₂).
  destruct j; [ apply Hij; easy | clear Hij ].
  destruct H₁ as [H₁| H₁].
   eapply Hi with (i := O) (j := S (S j)); [ intros H; easy | ].
   unfold intersection; simpl.
   split; eassumption.

   eapply Hi with (i := 1%nat) (j := S (S j)); [ intros H; easy | ].
   unfold intersection; simpl.
   split; eassumption.

  unfold intersection, union, set_eq; simpl.
  intros x.
  split; [ | easy ].
  intros (H₁ & H₂).
  destruct j.
   destruct H₂ as [H₂| H₂].
    eapply Hi with (i := O) (j := S (S i)); [ intros H; easy | ].
    unfold intersection; simpl.
    split; eassumption.

    eapply Hi with (i := 1%nat) (j := S (S i)).
     intros H; easy.

     unfold intersection; simpl.
     split; eassumption.

  apply Hi with (i := S (S i)) (j := S (S j)) (x := x).
   intros H; apply Hij.
   apply Nat.succ_inj; easy.

   unfold intersection; simpl.
   now split.
Qed.

Theorem is_partition_union_subtract :
  ∀ A (s := set_equiv) (F : set A) P₁ P₂ Pl (B : set A),
  is_partition F (P₁ :: P₂ :: Pl)
  → (B ⊂ P₂)%S
  → (∀ x, Decidable.decidable (x ∈ B))
  → is_partition F (P₁ ∪ B :: P₂ ∖ B :: Pl)%S.
Proof.
intros A s F P₁ P₂ Pl B Hp HB HBdec.
destruct Hp as (Hu & Hi).
split.
 unfold union_list, union, subtract, set_eq in Hu |-*.
 subst s; simpl in Hu |-*.
 intros x.
 split; intros H.
  pose proof Hu x as H₁.
  destruct H₁ as (H₁ & H₂).
  pose proof H₁ H as H₃.
  destruct H₃ as [H₃| H₃]; [ left; left; easy | ].
  destruct H₃ as [H₃| H₃]; [ | right; right; easy ].
  destruct (HBdec x) as [H₄| H₄]; [ left; right; easy | ].
  right; left; split; easy.

  apply Hu.
  destruct H as [[H₁| H₁]| [H₁| H₁]]; [ left; easy | | | ].
   right; left; apply HB; easy.

   right; left; destruct H₁; easy.

   right; right; easy.

 intros i j Hij; subst s.
 destruct i.
  unfold intersection, union, subtract, set_eq; simpl.
  intros x.
  split; [ | easy ].
  intros (H₁, H₂).
  destruct j; [ apply Hij; easy | clear Hij ].
  destruct H₁ as [H₁| H₁].
   eapply Hi with (i := O) (j := S j); [ intros H; easy | ].
   unfold intersection; simpl.
   split; [ eassumption | ].
   destruct j; [ destruct H₂; easy | easy ].

   eapply Hi with (i := 1%nat) (j := S j).
    destruct j; [ destruct H₂; easy | intros H; easy ].

    unfold intersection; simpl.
    split; [ apply HB; eassumption | ].
    destruct j; [ destruct H₂; easy | easy ].

  unfold intersection, union, subtract, set_eq; simpl.
  intros x.
  split; [ | easy ].
  intros (H₁ & H₂).
  destruct j.
   destruct H₂ as [H₂| H₂].
    eapply Hi with (i := O) (j := S i); [ intros H; easy | ].
    unfold intersection; simpl.
    split; [ eassumption | ].
    destruct i; [ destruct H₁; easy | easy ].

    eapply Hi with (i := 1%nat) (j := S i).
     destruct i; [ | intros H; easy ].
     destruct H₁; easy.

     unfold intersection; simpl.
     split; [ apply HB; eassumption | ].
     destruct i; [ apply HB; easy | easy ].

  apply Hi with (i := S i) (j := S j) (x := x).
   intros H; apply Hij; easy.

   unfold intersection; simpl.
   split.
    destruct i; [ destruct H₁; easy | easy ].

    destruct j; [ destruct H₂; easy | easy ].
Qed.

Theorem partition_union :
  ∀ A (s := set_equiv) (F₁ F₂ : set A) P₁ P₂,
  (F₁ ∩ F₂ = ∅)%S
  → is_partition F₁ P₁
  → is_partition F₂ P₂
  → is_partition (F₁ ∪ F₂) (P₁ ++ P₂).
Proof.
intros * HFF HF₁ HF₂.
destruct HF₁ as (HF₁ & HP₁).
destruct HF₂ as (HF₂ & HP₂).
split.
 subst s; rewrite union_list_app; [ | easy ].
 transitivity (F₁ ∪ ⋃ P₂).
  intros x.
  split; intros H.
   destruct H as [H| H]; [ left; easy | right ].
   apply HF₂; easy.

   destruct H as [H| H]; [ left; easy | right ].
   apply HF₂; easy.

  split; intros H.
   destruct H as [H| H]; [ left | right; easy ].
   apply HF₁; easy.

   destruct H as [H| H]; [ left | right; easy ].
   apply HF₁; easy.

 intros * Hij.
 unfold intersection, set_eq; subst s; simpl.
 intros x.
 split; intros H; [ | easy ].
 destruct H as (H₁, H₂).
 rewrite nth_set_app in H₁, H₂.
 destruct (lt_dec i (length P₁)) as [H₃| H₃].
  destruct (lt_dec j (length P₁)) as [H₄| H₄].
   eapply HP₁; [ eassumption | split; eassumption ].

   eapply HFF.
   split.
    apply HF₁.
    eapply nth_set_union_list; eassumption.

    destruct (lt_dec (j - length P₁) (length P₂)) as [H₅| H₅].
     apply HF₂.
     eapply nth_set_union_list; eassumption.

     apply Nat.nlt_ge in H₅.
     rewrite nth_overflow in H₂; [ easy | easy ].

  apply Nat.nlt_ge in H₃.
  destruct (lt_dec j (length P₁)) as [H₄| H₄].
   apply HFF with x.
   split.
    apply HF₁.
    eapply nth_set_union_list; eassumption.

    destruct (lt_dec (i - length P₁) (length P₂)) as [H₅| H₅].
     apply HF₂.
     eapply nth_set_union_list; eassumption.

     apply Nat.nlt_ge in H₅.
     rewrite nth_overflow in H₁; [ easy | easy ].

   apply Nat.nlt_ge in H₄.
   eapply HP₂; [ | split; [ apply H₁ | apply H₂] ].
   intros H.
   apply Nat.add_cancel_l with (p := length P₁) in H.
   rewrite Nat.add_sub_assoc in H; [ | easy ].
   rewrite Nat.add_sub_assoc in H; [ | easy ].
   rewrite Nat.add_comm, Nat.add_sub in H.
   rewrite Nat.add_comm, Nat.add_sub in H.
   easy.
Qed.

Theorem is_partition_single : ∀ A (s := @set_equiv A) E, is_partition E [E].
Proof.
intros.
split; [ symmetry; eapply union_empty_r; easy | ].
intros * Hij.
destruct i.
 destruct j; [ exfalso; apply Hij; easy | ].
 destruct j.
  split; [ intros (_, H); easy | easy ].
  split; [ intros (_, H); easy | easy ].

 split; [ intros (H, _) | easy ].
 destruct i; easy.
Qed.

Theorem is_partition_empty : ∀ A (s := set_equiv) (E : set A),
  is_partition E [] → (E = ∅)%S.
Proof.
intros * HP.
destruct HP as (HE & _).
easy.
Qed.

Add Parametric Morphism {A} : (@is_partition A set_equiv)
 with signature (@set_eq _ set_equiv) ==> eq ==> iff
 as is_partition_morph.
Proof.
intros E F HEF SL.
unfold is_partition.
rewrite <- HEF.
now split.
Qed.
