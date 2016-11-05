(* Sets as A → Prop *)

Require Import Utf8 List Relations NPeano Compare_dec Setoid.
Require Import Misc.

Record set A := mkset { setp : A → Prop }.
Arguments mkset [A] _.
Arguments setp [A] _ _.

Class set_model A := mksm { set_eq : set A → set A → Prop }.
Arguments set_eq : simpl never.

Definition empty_set {A} := mkset (λ _ : A, False).

Notation "x '∈' E" := (setp E x) (at level 60).
Notation "x '∉' E" := (¬ setp E x) (at level 60).
Notation "'∅'" := (empty_set).

Definition intersection {A} (E₁ E₂ : set A) :=
  mkset (λ x, x ∈ E₁ ∧ x ∈ E₂).
Definition union {A} (E₁ E₂ : set A) :=
  mkset (λ x, x ∈ E₁ ∨ x ∈ E₂).
Definition union_list {A} (Ei : list (set A)) :=
  fold_right union ∅ Ei.
Definition subtract {A} (E₁ E₂ : set A) :=
  mkset (λ x, x ∈ E₁ ∧ x ∉ E₂).
Definition included {A} (E₁ E₂ : set A) :=
  ∀ x, x ∈ E₁ → x ∈ E₂.

Arguments intersection : simpl never.
Arguments union : simpl never.
Arguments subtract : simpl never.
Arguments included : simpl never.

Delimit Scope set_scope with S.

Notation "a = b" := (set_eq a b) : set_scope.
Notation "a ≠ b" := (¬ set_eq a b) : set_scope.
Notation "E₁ '∩' E₂" := (intersection E₁ E₂)
  (at level 40, left associativity).
Notation "E₁ '∪' E₂" := (union E₁ E₂)
  (at level 50, left associativity).
Notation "E₁ '∖' E₂" := (subtract E₁ E₂) (at level 50).
Notation "E₁ '⊂' E₂" := (included E₁ E₂) (at level 60).
Notation "'⋃' Es" := (union_list Es) (at level 55).
Notation "E .[ i ]" := (List.nth i E ∅)
  (at level 1, format "'[' E '[' .[ i ] ']' ']'").

Definition set_equiv {A} := mksm A (λ (E₁ E₂ : set A), ∀ x, x ∈ E₁ ↔ x ∈ E₂).

Theorem set_eq_refl A : reflexive _ (@set_eq A set_equiv).
Proof. intros P x; split; intros; easy. Qed.

Theorem set_eq_sym A : symmetric _ (@set_eq A set_equiv).
Proof.
intros P₁ P₂ HPP x.
destruct (HPP x) as (H₁, H₂).
split; intros H; [ apply H₂, H | apply H₁, H ].
Qed.

Theorem set_eq_trans A : transitive _ (@set_eq A set_equiv).
Proof.
intros P₁ P₂ P₃ H₁₂ H₂₃ x.
destruct (H₁₂ x) as (H₁, H₂).
destruct (H₂₃ x) as (H₃, H₄).
split; intros H; [ apply H₃, H₁, H | apply H₂, H₄, H ].
Qed.

Add Parametric Relation A : (set A) (@set_eq A set_equiv)
 reflexivity proved by (set_eq_refl A)
 symmetry proved by (set_eq_sym A)
 transitivity proved by (set_eq_trans A)
 as set_eq_rel.

Theorem eq_set_eq : ∀ A (s := set_equiv) (x y : set A), x = y → (x = y)%S.
Proof. intros; subst x; easy. Qed.

Theorem included_trans A : transitive _ (@included A).
Proof.
intros E F G HEF HFG x Hx.
apply HFG, HEF, Hx.
Qed.

Theorem included_in_empty : ∀ A (s := set_equiv) (E : set A),
  E ⊂ ∅
  → (E = ∅)%S.
Proof.
intros * HE.
intros x.
split; intros Hx; [ | easy ].
apply HE in Hx; easy.
Qed.

Add Parametric Morphism {A} : (@intersection A)
  with signature
    (@set_eq _ set_equiv) ==> (@set_eq _ set_equiv) ==> (@set_eq _ set_equiv)
  as intersection_morph.
Proof.
intros E E' HE F F' HF.
unfold intersection; intros p.
split; intros (H₁, H₂).
 split; [ apply HE; easy | apply HF; easy ].
 split; [ apply HE; easy | apply HF; easy ].
Qed.

Add Parametric Morphism {A} : (@union A)
  with signature
    (@set_eq _ set_equiv) ==> (@set_eq _ set_equiv) ==> (@set_eq _ set_equiv)
  as union_morph.
Proof.
intros E E' HE F F' HF.
intros p.
split.
 intros [H₁| H₂]; [ left; apply HE, H₁ | right; apply HF, H₂ ].
 intros [H₁| H₂]; [ left; apply HE, H₁ | right; apply HF, H₂ ].
Qed.

Add Parametric Morphism {A} : (@subtract A)
  with signature
    (@set_eq _ set_equiv) ==> (@set_eq _ set_equiv) ==> (@set_eq _ set_equiv)
  as subtract_morph.
Proof.
intros E E' HE F F' HF.
unfold subtract; intros p.
split; intros (H₁, H₂).
 split; [ apply HE; easy | intros H; apply H₂, HF; easy ].
 split; [ apply HE; easy | intros H; apply H₂, HF; easy ].
Qed.

Add Parametric Morphism {A} : (@included A)
  with signature (@set_eq _ set_equiv) ==> (@set_eq _ set_equiv) ==> iff
  as included_morph.
Proof.
intros E F HEF E' F' HE'F'.
split; intros HEE' x HF; apply HE'F', HEE', HEF, HF.
Qed.

Theorem fold_set_eq : ∀ A (s := set_equiv) (P Q : set A),
  (∀ x, x ∈ P ↔ x ∈ Q) = (P = Q)%S.
Proof. intros; easy. Qed.

Theorem set_eq_equiv {A} : ∀ (s := set_equiv) (E F : set A),
  (E = F)%S
  → ∀ p, p ∈ E ↔ p ∈ F.
Proof. intros s * HEF; apply HEF. Qed.

Theorem union_empty_r : ∀ A (s := set_equiv) (F : set A),
  (F ∪ ∅ = F)%S.
Proof.
intros.
subst s; intros x.
split; intros H; [ | left; easy ].
destruct H as [H| H]; [ easy | easy ].
Qed.

Theorem intersection_empty_l : ∀ A (s := set_equiv) (F : set A),
  (∅ ∩ F = ∅)%S.
Proof.
intros.
subst s; intros x.
split; intros H; [ destruct H as (H, _); easy | easy ].
Qed.

Theorem intersection_empty_r : ∀ A (s := set_equiv) (F : set A),
  (F ∩ ∅ = ∅)%S.
Proof.
intros.
subst s; intros x.
split; intros H; [ destruct H as (_, H); easy | easy ].
Qed.

Theorem intersection_comm : ∀ A (s := set_equiv) (E F : set A),
  (E ∩ F = F ∩ E)%S.
Proof.
intros; intros x.
split; intros H; destruct H as (HE & HF); split; easy.
Qed.

Theorem union_comm : ∀ A (s := set_equiv) (E F : set A),
  (E ∪ F = F ∪ E)%S.
Proof.
intros; intros x.
split; intros [HE| HF]; [ right | left | right | left ]; easy.
Qed.

Theorem intersection_assoc : ∀ A (s := set_equiv) (E F G : set A),
  (E ∩ (F ∩ G) = (E ∩ F) ∩ G)%S.
Proof.
intros; intros x.
split; intros H.
 destruct H as (HE & (HF & HG)).
 split; [ split; easy | easy ].

 destruct H as ((HE & HF) & HG).
 split; [ easy | split; easy ].
Qed.

Theorem union_assoc : ∀ A (s := set_equiv) (E F G : set A),
  (E ∪ (F ∪ G) = (E ∪ F) ∪ G)%S.
Proof.
intros; intros x.
split; intros H.
 destruct H as [H| [H| H]].
  left; left; easy.
  left; right; easy.
  now right.

 destruct H as [[H| H]| H].
  now left.
  right; left; easy.
  right; right; easy.
Qed.

Theorem intersection_shuffle0 : ∀ A (s := set_equiv) (E F G : set A),
  (E ∩ F ∩ G = E ∩ G ∩ F)%S.
Proof.
intros; intros x.
split; intros H.
 destruct H as ((HE & HF) & HG).
 split; [ split; easy | easy ].

 destruct H as ((HE & HF) & HG).
 split; [ split; easy | easy ].
Qed.

Theorem union_is_empty : ∀ A (s := set_equiv) (E F : set A),
  (E ∪ F = ∅)%S → (E = ∅)%S ∧ (F = ∅)%S.
Proof.
intros * HEF.
split; intros x.
 split; [ intros Hx; apply HEF; left; easy | easy ].
 split; [ intros Hx; apply HEF; right; easy | easy ].
Qed.

Theorem union_list_is_empty_iff : ∀ A (s := set_equiv) (EL : list (set A)),
  (⋃ EL = ∅)%S ↔ Forall (λ E, (E = ∅)%S) EL.
Proof.
intros *.
split; intros HEL.
 apply Forall_forall; intros E HE.
 revert E HE.
 induction EL as [| E₁ EL]; intros; [ easy | ].
 simpl in HEL, HE.
 apply union_is_empty in HEL.
 destruct HEL as (HE₁, HEL).
 destruct HE as [HE| HE]; [ subst E₁; easy | ].
 apply IHEL, HE; apply HEL.

 rewrite Forall_forall in HEL.
 split; [ intros Hx; simpl | easy ].
 revert x Hx.
 induction EL as [| E₁ EL]; intros; [ easy | ].
 simpl in Hx.
 destruct Hx as [Hx| Hx].
  apply HEL in Hx; [ easy | left; easy ].

  eapply IHEL; [ | eassumption ].
  intros E HE; apply HEL; right; easy.
Qed.

Theorem union_list_app : ∀ A s, s = set_equiv → ∀ (P₁ P₂ : list (set A)),
  (⋃ (P₁ ++ P₂) = (⋃ P₁) ∪ (⋃ P₂))%S.
Proof.
intros * Hs *.
revert P₁.
induction P₂ as [| Q]; intros.
 rewrite app_nil_r; simpl; subst s.
 rewrite union_empty_r; easy.

 rewrite cons_comm_app, app_assoc; simpl; subst s.
 rewrite IHP₂.
 unfold union_list; simpl; rewrite union_assoc.
 intros x.
 split; intros H.
  destruct H as [H| H]; [ left | right; easy ].
  unfold union_list in H.
  rewrite fold_right_app in H.
  simpl in H.
  clear - H.
  induction P₁ as [| R P₁].
   simpl in H; simpl.
   destruct H as [H| H]; [ right; easy | easy ].

   simpl in H.
   destruct H as [H| H]; [ simpl; left; left; easy | ].
   apply IHP₁ in H.
   destruct H as [H| H]; [ simpl; left; right; easy | ].
   now right.

  destruct H as [H| H]; [ left | right; easy ].
  unfold union_list.
  rewrite fold_right_app; simpl.
  clear - H.
  induction P₁ as [| R P₁].
   simpl in H; simpl; left.
   destruct H; [ easy | easy ].

   simpl in H; simpl.
   destruct H.
    destruct H; [ left; easy | right ].
    apply IHP₁; left; easy.

    right; apply IHP₁; right; easy.
Qed.

Theorem nth_set_union_list : ∀ A (P : list (set A)) i x,
  i < length P → x ∈ P.[i] → x ∈ ⋃ P.
Proof.
intros A P i x Hi H.
revert P H Hi.
induction i; intros P H Hi.
 destruct P as [| E P]; [ easy | left; easy ].

 destruct P as [| E P]; [ easy | simpl in Hi ].
 apply Nat.succ_lt_mono in Hi.
 right; apply IHi; easy.
Qed.

Theorem nth_set_app : ∀ A (P₁ P₂ : list (set A)) i,
  (P₁ ++ P₂).[i] =
  if lt_dec i (length P₁) then P₁.[i] else P₂.[i-length P₁].
Proof.
intros.
unfold union, set_eq; simpl; intros.
destruct (lt_dec i (length P₁)) as [H₁| H₁].
 now rewrite app_nth1.

 rewrite app_nth2; [ easy | apply Nat.nlt_ge; easy ].
Qed.

Theorem union_list_intersection : ∀ A (S : set A) SL x,
  x ∈ S
  → x ∈ ⋃ SL
  → x ∈ ⋃ map (intersection S) SL.
Proof.
intros A P QL * HP HQL.
induction QL as [| Q QL]; intros; [ easy | simpl ].
destruct HQL as [HQ| HQL]; [ left; split; easy | right ].
apply IHQL, HQL.
Qed.

Theorem union_list_all_included : ∀ A (s := set_equiv) (E : set A) EL,
  (E = ⋃ EL)%S → Forall (λ Ei, Ei ⊂ E) EL.
Proof.
intros * HE.
apply Forall_forall.
intros F HF.
rewrite HE.
clear - HF.
revert F HF.
induction EL as [| E EL]; intros; [ easy | ].
destruct HF as [HF| HF]; [ left; subst E; easy | ].
right; eapply IHEL; eassumption.
Qed.

Theorem union_intersection_self : ∀ A (s:=set_equiv) (E : set A) EL,
  E ⊂ ⋃ EL
  → (E = ⋃ map (intersection E) EL)%S.
Proof.
intros * HEL x.
split; intros Hx.
 generalize Hx; intros Hxl.
 apply HEL in Hxl.
 clear -Hx Hxl.
 induction EL as [| E₁ EL]; intros; [ easy | ].
 destruct Hxl as [Hxl| Hxl]; [ left; split; easy | ].
 right; apply IHEL; easy.

 clear -Hx.
 induction EL as [| E₁ EL]; intros; [ easy | ].
 destruct Hx as [(Hx, _)| Hx]; [ easy | ].
 apply IHEL, Hx.
Qed. 

Add Parametric Morphism {A} : (@setp A)
with signature (@set_eq _ set_equiv) ==> eq ==> iff
as setp_morph.
Proof.
intros E F HEF x.
apply HEF.
Qed.
