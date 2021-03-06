(* Banach-Tarski paradox. *)
(* Inspirations:
   - Stan Wagon: The Banach-Tarski Paradox, Cambridge University Press
   - Wikipedia: Banach–Tarski paradox
   - http://people.math.umass.edu/~weston/oldpapers/banach.pdf *)
(* Coq v8.6 *)

Require Import Utf8 List.
Require Import Reals Psatz.

Require Import Words Normalize Reverse MiscReals.

Record matrix A := mkmat
  { a₁₁ : A; a₁₂ : A; a₁₃ : A;
    a₂₁ : A; a₂₂ : A; a₂₃ : A;
    a₃₁ : A; a₃₂ : A; a₃₃ : A }.
Arguments a₁₁ [A] _.
Arguments a₁₂ [A] _.
Arguments a₁₃ [A] _.
Arguments a₂₁ [A] _.
Arguments a₂₂ [A] _.
Arguments a₂₃ [A] _.
Arguments a₃₁ [A] _.
Arguments a₃₂ [A] _.
Arguments a₃₃ [A] _.
Arguments mkmat [A] _ _ _ _ _ _ _ _ _.

Definition mat_map {A B} (f : A → B) m :=
  mkmat
    (f (a₁₁ m)) (f (a₁₂ m)) (f (a₁₃ m))
    (f (a₂₁ m)) (f (a₂₂ m)) (f (a₂₃ m))
    (f (a₃₁ m)) (f (a₃₂ m)) (f (a₃₃ m)).

Definition mt i j :=
  match i with
  | 1%nat => match j with 1%nat => a₁₁ | 2 => a₁₂ | _ => a₁₃ end
  | 2%nat => match j with 1%nat => a₂₁ | 2 => a₂₂ | _ => a₂₃ end
  | _ => match j with 1%nat => a₃₁ | 2 => a₃₂ | _ => a₃₃ end
  end.
Arguments mt i%nat j%nat [A] m.

Definition mkrmat := @mkmat ℝ.

Inductive vector := V : ℝ → ℝ → ℝ → vector.

Definition mat_vec_mul M '(V x y z) :=
  V (a₁₁ M * x + a₁₂ M * y + a₁₃ M * z)
    (a₂₁ M * x + a₂₂ M * y + a₂₃ M * z)
    (a₃₁ M * x + a₃₂ M * y + a₃₃ M * z).

Definition vec_norm '(V x y z) := √ (x² + y² + z²).
Definition vec_opp '(V x y z) := V (-x) (-y) (-z).
Definition vec_add '(V u₁ u₂ u₃) '(V v₁ v₂ v₃) :=
  V (u₁ + v₁) (u₂ + v₂) (u₃ + v₃).
Definition vec_sub u v := vec_add u (vec_opp v).
Definition vec_dot_mul '(V x₁ y₁ z₁) '(V x₂ y₂ z₂) :=
  (x₁ * x₂ + y₁ * y₂ + z₁ * z₂)%R.
Definition vec_cross_mul '(V u₁ u₂ u₃) '(V v₁ v₂ v₃) :=
  V (u₂ * v₃ - u₃ * v₂) (u₃ * v₁ - u₁ * v₃) (u₁ * v₂ - u₂ * v₁).
Definition vec_const_mul k '(V x y z) := V (k * x) (k * y) (k * z).
Definition mat_const_mul k (M : matrix ℝ) :=
  mkrmat
    (k * a₁₁ M) (k * a₁₂ M) (k * a₁₃ M)
    (k * a₂₁ M) (k * a₂₂ M) (k * a₂₃ M)
    (k * a₃₁ M) (k * a₃₂ M) (k * a₃₃ M).

Delimit Scope vec_scope with vec.

Arguments vec_norm _%vec.
Arguments vec_add _%vec _%vec.
Arguments vec_dot_mul _%vec _%vec.
Arguments vec_cross_mul _%vec _%vec.
Arguments vec_const_mul _%R _%vec.

Notation "0" := (V 0 0 0) : vec_scope.
Notation "k ⁎ v" := (vec_const_mul k v) (at level 40).
Notation "M * v" := (mat_vec_mul M v) : vec_scope.
Notation "u + v" := (vec_add u v) : vec_scope.
Notation "u - v" := (vec_sub u v) : vec_scope.
Notation "- v" := (vec_opp v) : vec_scope.
Notation "u · v" := (vec_dot_mul u v) (at level 45, left associativity).
Notation "u × v" := (vec_cross_mul u v) (at level 40, left associativity).
Notation "v ²" := (vec_dot_mul v v) : vec_scope.
Notation "∥ v ∥" := (vec_norm v) (at level 0, v at level 0, format "∥ v ∥").

Definition vos a := V a a a.

(* https://en.wikipedia.org/wiki/Rotation_matrix
   #Rotation_matrix_from_axis_and_angle *)
Definition rot_mat_of_axis_cos '(V x y z) cosθ :=
  let sinθ := √ (1 - cosθ²) in mkrmat
  (cosθ+x²*(1-cosθ))    (x*y*(1-cosθ)-z*sinθ) (x*z*(1-cosθ)+y*sinθ)
  (y*x*(1-cosθ)+z*sinθ) (cosθ+y²*(1-cosθ))    (y*z*(1-cosθ)-x*sinθ)
  (z*x*(1-cosθ)-y*sinθ) (z*y*(1-cosθ)+x*sinθ) (cosθ+z²*(1-cosθ)).

Definition rot_x := mkrmat
  1         0         0
  0         (1/3)     (-2*√2/3)
  0         (2*√2/3)  (1/3).
Definition rot_inv_x := mkrmat
  1         0         0
  0         (1/3)     (2*√2/3)
  0         (-2*√2/3) (1/3).
Definition rot_z := mkrmat
  (1/3)     (-2*√2/3) 0
  (2*√2/3)  (1/3)     0
  0         0         1.
Definition rot_inv_z := mkrmat
  (1/3)     (2*√2/3)  0
  (-2*√2/3) (1/3)     0
  0         0         1.

Definition is_neg_vec '(V x y z) :=
  if Rlt_dec x 0 then true
  else if Rgt_dec x 0 then false
  else if Rlt_dec y 0 then true
  else if Rgt_dec y 0 then false
  else if Rlt_dec z 0 then true
  else if Rgt_dec z 0 then false
  else true.

Arguments is_neg_vec _%vec.

Theorem rot_x_means_rot_x : rot_x = rot_mat_of_axis_cos (V 1 0 0) (1/3).
Proof.
unfold rot_x; simpl.
setoid_rewrite Rsqr_pow2.
f_equal; try lra; ring_simplify.
 replace (1 - (1 / 3) ^ 2)%R with (2 * (2 / 3) ^ 2)%R by field.
 rewrite sqrt_mult; [ rewrite sqrt_pow2; lra | lra | lra ].

 replace (1 - (1 / 3) ^ 2)%R with (2 * (2 / 3) ^ 2)%R by field.
 rewrite sqrt_mult; [ rewrite sqrt_pow2; lra | lra | lra ].
Qed.

Definition mat_of_elem e :=
  match e with
  | ạ => rot_x
  | ạ⁻¹ => rot_inv_x
  | ḅ => rot_z
  | ḅ⁻¹ => rot_inv_z
  end.

Definition rotate e pt := mat_vec_mul (mat_of_elem e) pt.

Definition mat_mul m₁ m₂ :=
  mkrmat
    (a₁₁ m₁ * a₁₁ m₂ + a₁₂ m₁ * a₂₁ m₂ + a₁₃ m₁ * a₃₁ m₂)
    (a₁₁ m₁ * a₁₂ m₂ + a₁₂ m₁ * a₂₂ m₂ + a₁₃ m₁ * a₃₂ m₂)
    (a₁₁ m₁ * a₁₃ m₂ + a₁₂ m₁ * a₂₃ m₂ + a₁₃ m₁ * a₃₃ m₂)
    (a₂₁ m₁ * a₁₁ m₂ + a₂₂ m₁ * a₂₁ m₂ + a₂₃ m₁ * a₃₁ m₂)
    (a₂₁ m₁ * a₁₂ m₂ + a₂₂ m₁ * a₂₂ m₂ + a₂₃ m₁ * a₃₂ m₂)
    (a₂₁ m₁ * a₁₃ m₂ + a₂₂ m₁ * a₂₃ m₂ + a₂₃ m₁ * a₃₃ m₂)
    (a₃₁ m₁ * a₁₁ m₂ + a₃₂ m₁ * a₂₁ m₂ + a₃₃ m₁ * a₃₁ m₂)
    (a₃₁ m₁ * a₁₂ m₂ + a₃₂ m₁ * a₂₂ m₂ + a₃₃ m₁ * a₃₂ m₂)
    (a₃₁ m₁ * a₁₃ m₂ + a₃₂ m₁ * a₂₃ m₂ + a₃₃ m₁ * a₃₃ m₂).

Definition mat_id :=
  mkrmat
    1 0 0
    0 1 0
    0 0 1.

Fixpoint mat_pow M n :=
  match n with
  | O => mat_id
  | S n' => mat_mul M (mat_pow M n')
  end.

Delimit Scope mat_scope with mat.
Notation "m₁ * m₂" := (mat_mul m₁ m₂) : mat_scope.
Notation "M ^ n" := (mat_pow M n) : mat_scope.

Arguments mat_pow M%mat n%nat.
Arguments mat_vec_mul _%mat _%vec.

Theorem eq_vec_dec : ∀ p₁ p₂ : vector, { p₁ = p₂ } + { p₁ ≠ p₂ }.
Proof.
intros (x₁, y₁, z₁) (x₂, y₂, z₂).
destruct (Req_dec x₁ x₂) as [H₁| H₁]; [ subst x₂ | right ].
 destruct (Req_dec y₁ y₂) as [H₁| H₁]; [ subst y₂ | right ].
  destruct (Req_dec z₁ z₂) as [H₁| H₁]; [ now subst z₂; left | right ].
  now intros H; injection H; intros.

 now intros H; injection H; intros.

now intros H; injection H; intros.
Qed.

Arguments eq_vec_dec _%vec _%vec.

Theorem mat_eq_dec : ∀ m₁ m₂ : matrix ℝ, { m₁ = m₂ } + { m₁ ≠ m₂ }.
Proof.
intros.
destruct (Req_dec (a₁₁ m₁) (a₁₁ m₂)) as [H₁₁| H₁₁].
 destruct (Req_dec (a₁₂ m₁) (a₁₂ m₂)) as [H₁₂| H₁₂].
  destruct (Req_dec (a₁₃ m₁) (a₁₃ m₂)) as [H₁₃| H₁₃].
   destruct (Req_dec (a₂₁ m₁) (a₂₁ m₂)) as [H₂₁| H₂₁].
    destruct (Req_dec (a₂₂ m₁) (a₂₂ m₂)) as [H₂₂| H₂₂].
     destruct (Req_dec (a₂₃ m₁) (a₂₃ m₂)) as [H₂₃| H₂₃].
      destruct (Req_dec (a₃₁ m₁) (a₃₁ m₂)) as [H₃₁| H₃₁].
       destruct (Req_dec (a₃₂ m₁) (a₃₂ m₂)) as [H₃₂| H₃₂].
        destruct (Req_dec (a₃₃ m₁) (a₃₃ m₂)) as [H₃₃| H₃₃].
         now left; destruct m₁, m₂; simpl in *; subst.
         now right; intros H; subst m₁; apply H₃₃.
        now right; intros H; subst m₁; apply H₃₂.
       now right; intros H; subst m₁; apply H₃₁.
      now right; intros H; subst m₁; apply H₂₃.
     now right; intros H; subst m₁; apply H₂₂.
    now right; intros H; subst m₁; apply H₂₁.
   now right; intros H; subst m₁; apply H₁₃.
  now right; intros H; subst m₁; apply H₁₂.
 now right; intros H; subst m₁; apply H₁₁.
Qed.

Theorem mat_mul_id_l : ∀ m, mat_mul mat_id m = m.
Proof.
intros m.
unfold mat_mul, mat_id; simpl.
progress repeat rewrite Rmult_1_l.
progress repeat rewrite Rmult_0_l.
progress repeat rewrite Rplus_0_l.
progress repeat rewrite Rplus_0_r.
now destruct m.
Qed.

Theorem mat_mul_id_r : ∀ m, mat_mul m mat_id = m.
Proof.
intros m.
unfold mat_mul, mat_id; simpl.
progress repeat rewrite Rmult_1_r.
progress repeat rewrite Rmult_0_r.
progress repeat rewrite Rplus_0_l.
progress repeat rewrite Rplus_0_r.
now destruct m.
Qed.

Theorem mat_vec_mul_id : ∀ p, mat_vec_mul mat_id p = p.
Proof.
intros (x, y, z).
unfold mat_vec_mul; simpl.
progress repeat rewrite Rmult_0_l.
progress repeat rewrite Rmult_1_l.
progress repeat rewrite Rplus_0_l.
progress repeat rewrite Rplus_0_r.
easy.
Qed.

Theorem mat_vec_mul_assoc : ∀ m₁ m₂ p,
  mat_vec_mul (m₁ * m₂)%mat p = mat_vec_mul m₁ (mat_vec_mul m₂ p).
Proof.
intros m₁ m₂ (x, y, z).
unfold mat_vec_mul.
simpl; f_equal; lra.
Qed.

Theorem  mat_vec_mul_add_distr_l : ∀ M u v, (M * (u + v) = M * u + M * v)%vec.
Proof.
intros.
destruct u as (u₁, u₂, u₃).
destruct v as (v₁, v₂, v₃); simpl; f_equal; lra.
Qed.

Theorem  mat_vec_mul_const_distr : ∀ M k v, (M * (k ⁎ v) = k ⁎ (M * v))%vec.
Proof.
intros.
destruct v as (v₁, v₂, v₃); simpl; f_equal; lra.
Qed.

Theorem vec_mul_diag : ∀ x y z k,
  V (k * x) (k * y) (k * z) = (k ⁎ V x y z)%vec.
Proof. easy. Qed.

Theorem rot_rot_inv_x : ∀ pt,
  mat_vec_mul rot_x (mat_vec_mul rot_inv_x pt) = pt.
Proof.
intros.
unfold mat_vec_mul; simpl.
destruct pt as (x, y, z).
progress repeat rewrite Rmult_1_l.
progress repeat rewrite Rmult_0_l.
progress repeat rewrite Rplus_0_r.
progress repeat rewrite Rplus_0_l.
f_equal.
 field_simplify; simpl.
 unfold Rdiv.
 progress repeat rewrite Rmult_1_r.
 progress repeat rewrite RMicromega.Rinv_1.
 rewrite sqrt_sqrt; [ | lra ].
 field_simplify; simpl.
 unfold Rdiv.
 now field_simplify.

 unfold Rdiv.
 field_simplify; simpl.
 progress repeat rewrite Rmult_1_r.
 rewrite sqrt_sqrt; [ | lra ].
 field_simplify; simpl.
 unfold Rdiv.
 now field_simplify.
Qed.

Theorem rot_inv_rot_x : ∀ pt,
  mat_vec_mul rot_inv_x (mat_vec_mul rot_x pt) = pt.
Proof.
intros.
unfold mat_vec_mul; simpl.
destruct pt as (x, y, z).
progress repeat rewrite Rmult_1_l.
progress repeat rewrite Rmult_0_l.
progress repeat rewrite Rplus_0_r.
progress repeat rewrite Rplus_0_l.
f_equal.
 field_simplify; simpl.
 unfold Rdiv.
 progress repeat rewrite Rmult_1_r.
 progress repeat rewrite RMicromega.Rinv_1.
 rewrite sqrt_sqrt; [ | lra ].
 field_simplify; simpl.
 unfold Rdiv.
 now field_simplify.

 unfold Rdiv.
 field_simplify; simpl.
 progress repeat rewrite Rmult_1_r.
 rewrite sqrt_sqrt; [ | lra ].
 field_simplify; simpl.
 unfold Rdiv.
 now field_simplify.
Qed.

Theorem rot_rot_inv_z : ∀ pt,
  mat_vec_mul rot_z (mat_vec_mul rot_inv_z pt) = pt.
Proof.
intros.
unfold mat_vec_mul; simpl.
destruct pt as (x, y, z).
progress repeat rewrite Rmult_1_l.
progress repeat rewrite Rmult_0_l.
progress repeat rewrite Rplus_0_r.
progress repeat rewrite Rplus_0_l.
f_equal.
 field_simplify; simpl.
 unfold Rdiv.
 progress repeat rewrite Rmult_1_r.
 progress repeat rewrite RMicromega.Rinv_1.
 rewrite sqrt_sqrt; [ | lra ].
 field_simplify; simpl.
 unfold Rdiv.
 now field_simplify.

 unfold Rdiv.
 field_simplify; simpl.
 progress repeat rewrite Rmult_1_r.
 rewrite sqrt_sqrt; [ | lra ].
 field_simplify; simpl.
 unfold Rdiv.
 now field_simplify.
Qed.

Theorem rot_inv_rot_z : ∀ pt,
  mat_vec_mul rot_inv_z (mat_vec_mul rot_z pt) = pt.
Proof.
intros.
unfold mat_vec_mul; simpl.
destruct pt as (x, y, z).
progress repeat rewrite Rmult_1_l.
progress repeat rewrite Rmult_0_l.
progress repeat rewrite Rplus_0_r.
progress repeat rewrite Rplus_0_l.
f_equal.
 field_simplify; simpl.
 unfold Rdiv.
 progress repeat rewrite Rmult_1_r.
 progress repeat rewrite RMicromega.Rinv_1.
 rewrite sqrt_sqrt; [ | lra ].
 field_simplify; simpl.
 unfold Rdiv.
 now field_simplify.

 unfold Rdiv.
 field_simplify; simpl.
 progress repeat rewrite Rmult_1_r.
 rewrite sqrt_sqrt; [ | lra ].
 field_simplify; simpl.
 unfold Rdiv.
 now field_simplify.
Qed.

Theorem rotate_rotate_neg : ∀ e p, rotate e (rotate (negf e) p) = p.
Proof.
intros (t, d) p; simpl.
destruct t, d; simpl.
 apply rot_inv_rot_x.
 apply rot_rot_inv_x.
 apply rot_inv_rot_z.
 apply rot_rot_inv_z.
Qed.

Theorem rotate_neg_rotate : ∀ e p, rotate (negf e) (rotate e p) = p.
Proof.
intros (t, d) p; simpl.
destruct t, d; simpl.
 apply rot_rot_inv_x.
 apply rot_inv_rot_x.
 apply rot_rot_inv_z.
 apply rot_inv_rot_z.
Qed.

Theorem app_path_rev_path : ∀ p el,
  fold_right rotate p (rev_path el ++ el) = p.
Proof.
intros.
revert p.
induction el as [| e] using rev_ind; intros; [ easy | simpl ].
rewrite rev_path_app; simpl.
rewrite app_assoc, fold_right_app; simpl.
rewrite IHel; apply rotate_neg_rotate.
Qed.

Theorem rotate_cancel_in : ∀ el₁ el₂ e p,
  fold_right rotate p (el₁ ++ e :: negf e :: el₂) =
  fold_right rotate p (el₁ ++ el₂).
Proof.
intros.
do 2 rewrite fold_right_app; simpl.
now rewrite rotate_rotate_neg.
Qed.

Theorem rotate_rotate_norm : ∀ el p,
  fold_right rotate p el = fold_right rotate p (norm_list el).
Proof.
intros el p.
remember (length el) as len eqn:Hlen; symmetry in Hlen.
revert el p Hlen.
induction len as (len, IHlen) using lt_wf_rec; intros.
destruct (norm_list_dec el) as [H₁| H₁]; [ now rewrite H₁ | ].
destruct H₁ as (el₁ & t & d & el₂ & H₁).
subst el.
rewrite rotate_cancel_in, norm_list_cancel_in.
destruct len; [ now destruct el₁ | ].
destruct len.
 destruct el₁; [ easy | simpl in Hlen ].
 now destruct el₁.

 apply IHlen with len.
  transitivity (S len); apply Nat.lt_succ_diag_r.

  clear - Hlen.
  revert len el₂ Hlen.
  induction el₁ as [| e₁]; intros.
   simpl in Hlen; simpl.
   now do 2 apply Nat.succ_inj in Hlen.

   simpl in Hlen; simpl.
   apply Nat.succ_inj in Hlen.
   destruct len.
    destruct el₁; [ easy | simpl in Hlen ].
    now destruct el₁.

    f_equal.
    now apply IHel₁.
Qed.

Theorem rotate_rev_path : ∀ el p₁ p₂,
  fold_right rotate p₁ el = p₂
  → fold_right rotate p₂ (rev_path el) = p₁.
Proof.
intros el p₁ p₂ Hr.
revert p₁ p₂ Hr.
induction el as [| e]; intros; [ now symmetry | ].
simpl in Hr.
rewrite rev_path_cons, rev_path_single, fold_right_app; simpl.
apply IHel; rewrite <- Hr.
rewrite rotate_neg_rotate.
easy.
Qed.

Definition mat_transp m :=
  mkrmat
   (a₁₁ m) (a₂₁ m) (a₃₁ m)
   (a₁₂ m) (a₂₂ m) (a₃₂ m)
   (a₁₃ m) (a₂₃ m) (a₃₃ m).

Definition mat_det m :=
  (a₁₁ m * (a₂₂ m * a₃₃ m - a₃₂ m * a₂₃ m) +
   a₁₂ m * (a₂₃ m * a₃₁ m - a₃₃ m * a₂₁ m) +
   a₁₃ m * (a₂₁ m * a₃₂ m - a₃₁ m * a₂₂ m))%R.

Arguments mat_transp m%mat.
Arguments mat_det m%mat.

Theorem mat_transp_id : mat_transp mat_id = mat_id.
Proof. easy. Qed.

Theorem mat_transp_mul : ∀ m₁ m₂,
  mat_transp (mat_mul m₁ m₂) = mat_mul (mat_transp m₂) (mat_transp m₁).
Proof.
intros m₁ m₂.
unfold mat_transp, mat_mul; simpl; f_equal; ring.
Qed.

Theorem mat_mul_assoc : ∀ m₁ m₂ m₃,
  (m₁ * (m₂ * m₃) = m₁ * m₂ * m₃)%mat.
Proof.
intros m₁ m₂ m₃.
unfold mat_mul; simpl; f_equal; ring.
Qed.

Theorem mat_det_mul : ∀ m₁ m₂,
  mat_det (m₁ * m₂) = (mat_det m₂ * mat_det m₁)%R.
Proof.
intros m₁ m₂.
unfold mat_det; simpl; ring.
Qed.

Definition is_rotation_matrix A :=
  mat_mul A (mat_transp A) = mat_id ∧
  mat_det A = 1%R.

Arguments is_rotation_matrix A%mat.

Theorem mat_id_is_rotation_matrix : is_rotation_matrix mat_id.
Proof.
split; [ now rewrite mat_transp_id, mat_mul_id_l | ].
unfold mat_det; simpl; ring.
Qed.

Theorem rot_x_is_rotation_matrix : is_rotation_matrix rot_x.
Proof.
unfold is_rotation_matrix, mat_transp, mat_mul, mat_det; simpl.
unfold mat_id, Rdiv.
progress repeat rewrite Rmult_0_l.
progress repeat rewrite Rmult_0_r.
progress repeat rewrite Rmult_1_l.
progress repeat rewrite Rplus_0_l.
progress repeat rewrite Rplus_0_r.
progress repeat rewrite <- Rmult_assoc.
progress repeat (rewrite Rmult5_sqrt2_sqrt5; [ | lra ]).
split; [ f_equal; field | field ].
Qed.

Theorem rot_inv_x_is_rotation_matrix : is_rotation_matrix rot_inv_x.
Proof.
unfold is_rotation_matrix, rot_inv_x, mat_transp, mat_mul, mat_det; simpl.
unfold mat_id, Rdiv.
progress repeat rewrite Rmult_0_l.
progress repeat rewrite Rmult_0_r.
progress repeat rewrite Rmult_1_l.
progress repeat rewrite Rplus_0_l.
progress repeat rewrite Rplus_0_r.
progress repeat rewrite <- Rmult_assoc.
progress repeat (rewrite Rmult5_sqrt2_sqrt5; [ | lra ]).
split; [ f_equal; field | field ].
Qed.

Theorem rot_z_is_rotation_matrix : is_rotation_matrix rot_z.
Proof.
unfold is_rotation_matrix, mat_transp, mat_mul, mat_det; simpl.
unfold mat_id, Rdiv.
progress repeat rewrite Rmult_0_l.
progress repeat rewrite Rmult_0_r.
progress repeat rewrite Rmult_1_l.
progress repeat rewrite Rplus_0_l.
progress repeat rewrite Rplus_0_r.
progress repeat rewrite Rminus_0_l.
progress repeat rewrite Rminus_0_r.
progress repeat rewrite Ropp_mult_distr_l.
progress repeat rewrite <- Rmult_assoc.
progress repeat (rewrite Rmult5_sqrt2_sqrt5; [ | lra ]).
split; [ f_equal; field | field ].
Qed.

Theorem rot_inv_z_is_rotation_matrix : is_rotation_matrix rot_inv_z.
Proof.
unfold is_rotation_matrix, rot_inv_x, mat_transp, mat_mul, mat_det; simpl.
unfold mat_id, Rdiv.
progress repeat rewrite Rmult_0_l.
progress repeat rewrite Rmult_0_r.
progress repeat rewrite Rmult_1_l.
progress repeat rewrite Rplus_0_l.
progress repeat rewrite Rplus_0_r.
progress repeat rewrite Rminus_0_l.
progress repeat rewrite Rminus_0_r.
progress repeat rewrite Ropp_mult_distr_l.
progress repeat rewrite <- Rmult_assoc.
progress repeat (rewrite Rmult5_sqrt2_sqrt5; [ | lra ]).
split; [ f_equal; field | field ].
Qed.

Theorem rotate_is_rotation_matrix : ∀ e, is_rotation_matrix (mat_of_elem e).
Proof.
intros (t, d); destruct t, d.
 apply rot_inv_x_is_rotation_matrix.
 apply rot_x_is_rotation_matrix.
 apply rot_inv_z_is_rotation_matrix.
 apply rot_z_is_rotation_matrix.
Qed.

Theorem mat_mul_is_rotation_matrix : ∀ m1 m2,
  is_rotation_matrix m1
  → is_rotation_matrix m2
  → is_rotation_matrix (m1 * m2).
Proof.
intros * (Hm1, Hd1) (Hm2, Hd2).
unfold is_rotation_matrix.
rewrite mat_transp_mul.
rewrite mat_mul_assoc.
setoid_rewrite <- mat_mul_assoc at 2.
rewrite Hm2, mat_mul_id_r, Hm1.
split; [ easy | ].
rewrite mat_det_mul, Hd1, Hd2.
apply Rmult_1_r.
Qed.

Theorem vec_const_mul_assoc : ∀ a b v, a ⁎ (b ⁎ v) = (a * b) ⁎ v.
Proof.
intros a b (x, y, z); simpl.
now do 3 rewrite Rmult_assoc.
Qed.

Theorem vec_const_mul_div : ∀ a b u v,
  a ≠ 0%R
  → a ⁎ u = b ⁎ v
  → u = (b / a) ⁎ v.
Proof.
intros * Ha Hm.
destruct u as (u₁, u₂, u₃).
destruct v as (v₁, v₂, v₃).
simpl in Hm; simpl.
injection Hm; clear Hm; intros H₃ H₂ H₁.
unfold Rdiv; setoid_rewrite Rmult_shuffle0.
rewrite <- H₁, <- H₂, <- H₃.
setoid_rewrite Rmult_shuffle0.
rewrite Rinv_r; [ | easy ].
now do 3 rewrite Rmult_1_l.
Qed.

Theorem vec_norm_nonneg : ∀ v, (0 ≤ ∥v∥)%R.
Proof.
intros (x, y, z); simpl.
apply sqrt_pos.
Qed.

Theorem nonneg_plus_sqr : ∀ x y, (0 ≤ x² + y²)%R.
Proof.
intros.
apply Rplus_le_le_0_compat; apply Rle_0_sqr.
Qed.

Theorem nonneg_sqr_vec_norm : ∀ x y z, (0 ≤ x² + y² + z²)%R.
Proof.
intros.
apply Rplus_le_le_0_compat; [ | apply Rle_0_sqr ].
apply Rplus_le_le_0_compat; apply Rle_0_sqr.
Qed.

Theorem vec_norm_vec_const_mul : ∀ a v,
  ∥(vec_const_mul a v)∥ = (Rabs a * ∥v∥)%R.
Proof.
intros a (x, y, z); simpl.
do 3 rewrite Rsqr_mult.
do 2 rewrite <- Rmult_plus_distr_l.
rewrite sqrt_mult; [ | apply Rle_0_sqr | apply nonneg_sqr_vec_norm ].
now rewrite sqrt_Rsqr_abs.
Qed.

Theorem sqr_vec_norm_eq_0 : ∀ x y z,
  (x² + y² + z²)%R = 0%R
  → x = 0%R ∧ y = 0%R ∧ z = 0%R.
Proof.
intros * H.
apply Rplus_eq_R0 in H; [ | | apply Rle_0_sqr ].
 destruct H as (H₁, H₂).
 apply Rplus_sqr_eq_0 in H₁.
 apply Rsqr_eq_0 in H₂.
 move H₁ at top; move H₂ at top; destruct H₁; subst x y z.
 now split; [ | split ].

 apply Rplus_le_le_0_compat; apply Rle_0_sqr.
Qed.

Theorem vec_norm_0 : ∥0∥ = 0%R.
Proof.
simpl; rewrite Rsqr_0.
do 2 rewrite Rplus_0_l.
apply sqrt_0.
Qed.

Theorem vec_norm_eq_0 : ∀ v, ∥v∥ = 0%R ↔ v = 0%vec.
Proof.
intros.
split; intros Hv.
 destruct v as (v₁, v₂, v₃); simpl in Hv.
 apply sqrt_eq_0 in Hv; [ | apply nonneg_sqr_vec_norm ].
 apply sqr_vec_norm_eq_0 in Hv.
 now destruct Hv as (H₁ & H₂ & H₃); subst.

 destruct v as (v₁, v₂, v₃); simpl.
 injection Hv; clear Hv; intros; subst.
 rewrite Rsqr_0, Rplus_0_r, Rplus_0_r.
 apply sqrt_0.
Qed.

Theorem vec_add_0_l : ∀ v, (0 + v = v)%vec.
Proof.
intros (x, y, z); simpl.
now do 3 rewrite Rplus_0_l.
Qed.

Theorem vec_add_0_r : ∀ v, (v + 0 = v)%vec.
Proof.
intros (x, y, z); simpl.
now do 3 rewrite Rplus_0_r.
Qed.

Theorem eq_vec_const_mul_0 : ∀ a v, (a ⁎ v = 0 → a = 0%R ∨ v = 0)%vec.
Proof.
intros a (x, y, z) Hv; simpl in Hv; simpl.
injection Hv; intros Hz Hy Hx.
apply Rmult_integral in Hx.
apply Rmult_integral in Hy.
apply Rmult_integral in Hz.
destruct Hx as [Hx| Hx]; [ now left | subst x ].
destruct Hy as [Hy| Hy]; [ now left | subst y ].
destruct Hz as [Hz| Hz]; [ now left | subst z ].
now right.
Qed.

Theorem vec_const_mul_0_l : ∀ v, (0 ⁎ v = 0)%vec.
Proof.
intros (x, y, z); simpl.
now do 3 rewrite Rmult_0_l.
Qed.

Theorem vec_const_mul_0_r : ∀ a, (a ⁎ 0 = 0)%vec.
Proof.
intros x; simpl.
now rewrite Rmult_0_r.
Qed.

Theorem vec_const_mul_1_l : ∀ v, 1 ⁎ v = v.
Proof.
intros (x, y, z).
unfold vec_const_mul.
now do 3 rewrite Rmult_1_l.
Qed.

Theorem neg_vec_involutive : ∀ p, (- - p)%vec = p.
Proof.
intros (x, y, z); simpl.
now do 3 rewrite Ropp_involutive.
Qed.

Theorem is_neg_vec_0 : is_neg_vec (V 0 0 0) = true.
Proof.
simpl.
destruct (Rlt_dec 0 0) as [H₁| H₁]; [ easy | clear H₁ ].
destruct (Rgt_dec 0 0) as [H₁| H₁]; [ | easy ].
now apply Rgt_irrefl in H₁.
Qed.

Theorem is_neg_vec_neg_vec : ∀ v,
  v ≠ 0%vec
  → is_neg_vec (- v) = negb (is_neg_vec v).
Proof.
intros (x, y, z) Hv; simpl.
destruct (Rlt_dec x 0) as [Hx| Hx].
 destruct (Rlt_dec (-x) 0) as [Hx'| Hx'].
  apply Ropp_lt_contravar in Hx'.
  rewrite Ropp_0, Ropp_involutive in Hx'.
  now apply Rlt_le, Rle_not_lt in Hx'.

  clear Hx'.
  destruct (Rgt_dec (-x) 0) as [Hx'| Hx']; [ easy | ].
  apply Ropp_lt_contravar in Hx.
  now rewrite Ropp_0 in Hx.

 apply Rnot_lt_le in Hx.
 destruct (Rlt_dec (-x) 0) as [Hx'| Hx'].
  apply Ropp_lt_contravar in Hx'.
  rewrite Ropp_0, Ropp_involutive in Hx'.
  now destruct (Rgt_dec x 0).

  apply Rnot_lt_le in Hx'.
  apply Ropp_le_contravar in Hx'.
  rewrite Ropp_0, Ropp_involutive in Hx'.
  apply Rle_antisym in Hx'; [ subst x | easy ].
  rewrite Ropp_0; clear Hx.
  destruct (Rgt_dec 0 0) as [Hx| Hx]; [ now apply Rgt_irrefl in Hx | ].
  clear Hx.
  destruct (Rlt_dec y 0) as [Hy| Hy].
   destruct (Rlt_dec (-y) 0) as [Hy'| Hy'].
    apply Ropp_lt_contravar in Hy'.
    rewrite Ropp_0, Ropp_involutive in Hy'.
    now apply Rlt_le, Rle_not_lt in Hy'.

    clear Hy'.
    destruct (Rgt_dec (-y) 0) as [Hy'| Hy']; [ easy | ].
    apply Ropp_lt_contravar in Hy.
    now rewrite Ropp_0 in Hy.

   apply Rnot_lt_le in Hy.
   destruct (Rlt_dec (-y) 0) as [Hy'| Hy'].
    apply Ropp_lt_contravar in Hy'.
    rewrite Ropp_0, Ropp_involutive in Hy'.
    now destruct (Rgt_dec y 0).

    apply Rnot_lt_le in Hy'.
    apply Ropp_le_contravar in Hy'.
    rewrite Ropp_0, Ropp_involutive in Hy'.
    apply Rle_antisym in Hy'; [ subst y | easy ].
    rewrite Ropp_0; clear Hy.
    destruct (Rgt_dec 0 0) as [Hy| Hy]; [ now apply Rgt_irrefl in Hy | ].
    clear Hy.
    destruct (Rlt_dec z 0) as [Hz| Hz].
     destruct (Rlt_dec (-z) 0) as [Hz'| Hz'].
      apply Ropp_lt_contravar in Hz'.
      rewrite Ropp_0, Ropp_involutive in Hz'.
      now apply Rlt_le, Rle_not_lt in Hz'.

      clear Hz'.
      destruct (Rgt_dec (-z) 0) as [Hz'| Hz']; [ easy | ].
      apply Ropp_lt_contravar in Hz.
      now rewrite Ropp_0 in Hz.

     apply Rnot_lt_le in Hz.
     destruct (Rlt_dec (-z) 0) as [Hz'| Hz'].
      apply Ropp_lt_contravar in Hz'.
      rewrite Ropp_0, Ropp_involutive in Hz'.
      now destruct (Rgt_dec z 0).

      apply Rnot_lt_le in Hz'.
      apply Ropp_le_contravar in Hz'.
      rewrite Ropp_0, Ropp_involutive in Hz'.
      apply Rle_antisym in Hz'; [ subst z | easy ].
      now exfalso; apply Hv.
Qed.

Theorem vec_add_assoc : ∀ u v w, (u + (v + w))%vec = (u + v + w)%vec.
Proof.
intros.
destruct u as (u₁, u₂, u₃).
destruct v as (v₁, v₂, v₃).
destruct w as (w₁, w₂, w₃).
simpl; f_equal; lra.
Qed.

Theorem vec_add_opp_l : ∀ v, (vec_opp v + v = 0)%vec.
Proof.
intros.
destruct v as (v₁, v₂, v₃); simpl.
f_equal; lra.
Qed.

Theorem vec_add_opp_r : ∀ v, (v + vec_opp v = 0)%vec.
Proof.
intros.
destruct v as (v₁, v₂, v₃); simpl.
f_equal; lra.
Qed.

Theorem vec_sub_move_r : ∀ u v w, (u - v)%vec = w ↔ u = (w + v)%vec.
Proof.
intros.
split; intros H.
 rewrite <- H.
 unfold vec_sub.
 rewrite <- vec_add_assoc.
 rewrite vec_add_opp_l.
 now rewrite vec_add_0_r.

 rewrite H.
 unfold vec_sub.
 rewrite <- vec_add_assoc.
 rewrite vec_add_opp_r.
 now rewrite vec_add_0_r.
Qed.

Theorem vec_cross_mul_integral : ∀ a v, (a ⁎ v = 0)%vec → a = 0%R ∨ v = 0%vec.
Proof.
intros a (x, y, z) Hav; simpl in Hav.
injection Hav; clear Hav; intros Hz Hy Hx.
apply Rmult_integral in Hx.
apply Rmult_integral in Hy.
apply Rmult_integral in Hz.
destruct Hx as [Hx| Hx]; [ now left | subst x ].
destruct Hy as [Hy| Hy]; [ now left | subst y ].
destruct Hz as [Hz| Hz]; [ now left | subst z ].
now right.
Qed.

Theorem vec_const_mul_cross_distr_l : ∀ k u v,
  vec_const_mul k (u × v) = vec_const_mul k u × v.
Proof.
intros k (u₁, u₂, u₃) (v₁, v₂, v₃); simpl.
f_equal; ring.
Qed.

Theorem mat_const_vec_mul : ∀ M v k,
  mat_vec_mul (mat_const_mul k M) v = mat_vec_mul M (vec_const_mul k v).
Proof.
intros.
destruct v as (x, y, z); simpl; f_equal; ring.
Qed.

Theorem mat_vec_mat_const_mul : ∀ M v k,
  mat_vec_mul (mat_const_mul k M) v = vec_const_mul k (mat_vec_mul M v).
Proof.
intros.
destruct v as (x, y, z); simpl; f_equal; ring.
Qed.

Theorem vec_dot_cross_mul : ∀ u v, u · (u × v) = 0%R.
Proof.
intros.
destruct u, v; simpl; lra.
Qed.

Theorem vec_cross_dot_mul : ∀ u v, u × v · u = 0%R.
Proof.
intros.
destruct u, v; simpl; lra.
Qed.

Theorem vec_dot_mul_0_r : ∀ v, (v · 0)%vec = 0%R.
Proof.
intros (x, y, z); simpl.
do 3 rewrite Rmult_0_r.
now do 2 rewrite Rplus_0_r.
Qed.

Theorem vec_dot_mul_add_distr_l : ∀ u v w,
  u · (v + w) = (u · v + u · w)%R.
Proof.
intros (x₁, y₁, z₁) (x₂, y₂, z₂) (x₃, y₃, z₃); simpl; lra.
Qed.

Theorem Rmult_vec_dot_mul_distr_r : ∀ a u v, (a * (u · v))%R = u · a ⁎ v.
Proof.
intros a (u₁, u₂, u₃) (v₁, v₂, v₃); simpl; lra.
Qed.

Theorem vec_dot_mul_diag : ∀ v, v · v = (∥v∥²)%R.
Proof.
intros (x, y, z); simpl.
do 3 rewrite fold_Rsqr.
rewrite Rsqr_sqrt; [ easy | ].
apply nonneg_sqr_vec_norm.
Qed.

Theorem vec_add_comm : ∀ u v, (u + v = v + u)%vec.
Proof.
intros (u₁, u₂, u₃) (v₁, v₂, v₃); simpl.
f_equal; lra.
Qed.

Theorem vec_dot_mul_comm : ∀ u v, u · v = v · u.
Proof.
intros (u₁, u₂, u₃) (v₁, v₂, v₃); simpl; lra.
Qed.

Theorem vec_cross_mul_anticomm : ∀ u v, (u × v = - (v × u))%vec.
Proof.
intros (u₁, u₂, u₃) (v₁, v₂, v₃); simpl; f_equal; lra.
Qed.

Theorem vec_opp_dot_mul_distr_l : ∀ u v, (- (u · v) = - u · v)%R.
Proof.
intros (u₁, u₂, u₃) (v₁, v₂, v₃); simpl; lra.
Qed.

Theorem vec_opp_dot_mul_distr_r : ∀ u v, (- (u · v) = u · - v)%R.
Proof.
intros (u₁, u₂, u₃) (v₁, v₂, v₃); simpl; lra.
Qed.

Theorem vec_opp_const_mul_distr_l : ∀ a v, (- (a ⁎ v) = - a ⁎ v)%vec.
Proof.
intros a (v₁, v₂, v₃); simpl; f_equal; lra.
Qed.

Theorem vec_opp_const_mul_distr_r : ∀ a v, (- (a ⁎ v) = a ⁎ - v)%vec.
Proof.
intros a (v₁, v₂, v₃); simpl; f_equal; lra.
Qed.

Theorem vec_const_mul_add_distr_l : ∀ a u v,
  (a ⁎ (u + v) = a ⁎ u + a ⁎ v)%vec.
Proof.
intros a (u₁, u₂, u₃) (v₁, v₂, v₃); simpl; f_equal; lra.
Qed.

Theorem vec_const_mul_add_distr_r : ∀ a b v,
  ((a + b) ⁎ v = a ⁎ v + b ⁎ v)%vec.
Proof.
intros a b (v₁, v₂, v₃); simpl; f_equal; lra.
Qed.

Theorem vec_add_shuffle0 : ∀ u v w, (u + v + w = u + w + v)%vec.
Proof.
intros (u₁, u₂, u₃) (v₁, v₂, v₃) (w₁, w₂, w₃); simpl; f_equal; lra.
Qed.

Theorem vec_const_mul_eq_reg_l : ∀ a u v, a ⁎ u = a ⁎ v → a ≠ 0%R → u = v.
Proof.
intros a (u₁, u₂, u₃) (v₁, v₂, v₃) Hauv Ha.
simpl in Hauv.
injection Hauv; clear Hauv; intros H₃ H₂ H₁.
apply Rmult_eq_reg_l in H₁; [ | easy ].
apply Rmult_eq_reg_l in H₂; [ | easy ].
apply Rmult_eq_reg_l in H₃; [ | easy ].
now subst.
Qed.

Theorem mat_vec_mul_0_r : ∀ M, (M * 0)%vec = 0%vec.
Proof.
intros; simpl.
do 9 rewrite Rmult_0_r.
now do 2 rewrite Rplus_0_r.
Qed.

Theorem mat_opp_vec_mul_distr_r : ∀ M v, (M * - v = - (M * v))%vec.
Proof.
intros M (x, y, z); simpl; f_equal; lra.
Qed.
