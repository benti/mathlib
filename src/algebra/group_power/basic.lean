/-
Copyright (c) 2015 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Robert Y. Lewis
-/
import algebra.ordered_ring
import tactic.monotonicity.basic
import deprecated.group
import group_theory.group_action.defs

/-!
# Power operations on monoids and groups

The power operation on monoids and groups.
We separate this from group, because it depends on `ℕ`,
which in turn depends on other parts of algebra.

This module contains the definitions of `monoid.pow` and `group.pow`
and their additive counterparts `nsmul` and `gsmul`, along with a few lemmas.
Further lemmas can be found in `algebra.group_power.lemmas`.

## Notation

The class `has_pow α β` provides the notation `a^b` for powers.
We define instances of `has_pow M ℕ`, for monoids `M`, and `has_pow G ℤ` for groups `G`.

Scalar multiplication by naturals and integers is handled by the `•` (`has_scalar.smul`)
notation defined elsewhere.

## Implementation details

We adopt the convention that `0^0 = 1`.

This module provides the instance `has_pow ℕ ℕ` (via `monoid.has_pow`)
and is imported by `data.nat.basic`, so it has to live low in the import hierarchy.
Not all of its imports are needed yet; the intent is to move more lemmas here from `.lemmas`
so that they are available in `data.nat.basic`, and the imports will be required then.
-/

universes u v w x y z u₁ u₂

variables {M : Type u} {N : Type v} {G : Type w} {H : Type x} {A : Type y} {B : Type z}
  {R : Type u₁} {S : Type u₂}

instance monoid.has_pow [monoid M] : has_pow M ℕ := ⟨λ x n, npow n x⟩

instance add_monoid.has_scalar_nat [add_monoid M] : has_scalar ℕ M := ⟨nsmul⟩

instance div_inv_monoid.has_pow [div_inv_monoid M] : has_pow M ℤ := ⟨λ x n, gpow n x⟩

instance sub_neg_monoid.has_scalar_int [sub_neg_monoid M] : has_scalar ℤ M := ⟨gsmul⟩

@[simp] lemma npow_eq_pow {M : Type*} [monoid M] (n : ℕ) (x : M) : npow n x = x^n := rfl

@[simp] lemma nsmul_eq_smul {M : Type*} [add_monoid M] (n : ℕ) (x : M) : nsmul n x = n • x := rfl

@[simp] lemma gpow_eq_pow {M : Type*} [div_inv_monoid M] (n : ℤ) (x : M) : gpow n x = x^n := rfl

@[simp] lemma gsmul_eq_smul {M : Type*} [sub_neg_monoid M] (n : ℤ) (x : M) : gsmul n x = n • x :=
rfl

/-!
### Commutativity

First we prove some facts about `semiconj_by` and `commute`. They do not require any theory about
`pow` and/or `nsmul` and will be useful later in this file.
-/

namespace semiconj_by

variables [monoid M]

@[simp] lemma pow_right {a x y : M} (h : semiconj_by a x y) (n : ℕ) : semiconj_by a (x^n) (y^n) :=
begin
  induction n with n ih,
  { simp [← npow_eq_pow, monoid.npow_zero'], },
  { simp only [← npow_eq_pow, nat.succ_eq_add_one, npow_one, npow_add] at ⊢ ih,
    exact ih.mul_right h }
end

end semiconj_by

namespace commute

variables [monoid M] {a b : M}

@[simp] theorem pow_right (h : commute a b) (n : ℕ) : commute a (b ^ n) := h.pow_right n
@[simp] theorem pow_left (h : commute a b) (n : ℕ) : commute (a ^ n) b := (h.symm.pow_right n).symm
@[simp] theorem pow_pow (h : commute a b) (m n : ℕ) : commute (a ^ m) (b ^ n) :=
(h.pow_left m).pow_right n

@[simp] theorem self_pow (a : M) (n : ℕ) : commute a (a ^ n) := (commute.refl a).pow_right n
@[simp] theorem pow_self (a : M) (n : ℕ) : commute (a ^ n) a := (commute.refl a).pow_left n
@[simp] theorem pow_pow_self (a : M) (m n : ℕ) : commute (a ^ m) (a ^ n) :=
(commute.refl a).pow_pow m n

end commute

section monoid
variables [monoid M] [monoid N] [add_monoid A] [add_monoid B]

@[simp] theorem pow_zero (a : M) : a^0 = 1 := monoid.npow_zero' _
theorem zero_nsmul (a : A) : 0 • a = 0 := add_monoid.nsmul_zero' _

theorem pow_succ (a : M) (n : ℕ) : a^(n+1) = a * a^n :=
by rw [← npow_eq_pow, nat.add_comm, npow_add, npow_one, npow_eq_pow]

theorem succ_nsmul (a : A) (n : ℕ) : (n+1) • a = a + n • a :=
by rw [← nsmul_eq_smul, nat.add_comm, nsmul_add', nsmul_one', nsmul_eq_smul]

/-- Note that most of the lemmas about powers of two refer to it as `sq`. -/
theorem pow_two (a : M) : a^2 = a * a :=
by rw [← npow_eq_pow, show 2 = 1 + 1, by refl, npow_add, npow_one]

alias pow_two ← sq

theorem two_nsmul (a : A) : 2 • a = a + a :=
@sq (multiplicative A) _ a

theorem pow_mul_comm' (a : M) (n : ℕ) : a^n * a = a * a^n := commute.pow_self a n
theorem nsmul_add_comm' : ∀ (a : A) (n : ℕ), n • a + a = a + n • a :=
@pow_mul_comm' (multiplicative A) _

theorem pow_succ' (a : M) (n : ℕ) : a^(n+1) = a^n * a :=
by rw [pow_succ, pow_mul_comm']
theorem succ_nsmul' (a : A) (n : ℕ) : (n+1) • a = n • a + a :=
@pow_succ' (multiplicative A) _ _ _

theorem pow_add (a : M) (m n : ℕ) : a^(m + n) = a^m * a^n :=
by induction n with n ih; [rw [nat.add_zero, pow_zero, mul_one],
  rw [pow_succ', ← mul_assoc, ← ih, ← pow_succ', nat.add_assoc]]
theorem add_nsmul : ∀ (a : A) (m n : ℕ), (m + n) • a = m • a + n • a :=
@pow_add (multiplicative A) _

@[simp] theorem pow_one (a : M) : a^1 = a :=
by rw [← npow_eq_pow, npow_one]

@[simp] theorem one_nsmul (a : A) : 1 • a = a :=
by rw [← nsmul_eq_smul, nsmul_one']

@[simp] lemma pow_ite (P : Prop) [decidable P] (a : M) (b c : ℕ) :
  a ^ (if P then b else c) = if P then a ^ b else a ^ c :=
by split_ifs; refl

@[simp] lemma ite_pow (P : Prop) [decidable P] (a b : M) (c : ℕ) :
  (if P then a else b) ^ c = if P then a ^ c else b ^ c :=
by split_ifs; refl

@[simp] lemma pow_boole (P : Prop) [decidable P] (a : M) :
  a ^ (if P then 1 else 0) = if P then a else 1 :=
by simp

@[simp] theorem one_pow (n : ℕ) : (1 : M)^n = 1 :=
by induction n with n ih; [exact pow_zero _, rw [pow_succ, ih, one_mul]]

theorem nsmul_zero (n : ℕ) : n • (0 : A) = 0 :=
by induction n with n ih; [exact add_monoid.nsmul_zero' _, rw [succ_nsmul, ih, zero_add]]

theorem pow_mul (a : M) (m n : ℕ) : a^(m * n) = (a^m)^n :=
begin
  induction n with n ih,
  { rw [nat.mul_zero, pow_zero, pow_zero] },
  { rw [nat.mul_succ, pow_add, pow_succ', ih] }
end

theorem mul_nsmul' : ∀ (a : A) (m n : ℕ), (m * n) • a = n • (m • a) :=
@pow_mul (multiplicative A) _

theorem pow_mul' (a : M) (m n : ℕ) : a^(m * n) = (a^n)^m :=
by rw [nat.mul_comm, pow_mul]

theorem mul_nsmul (a : A) (m n : ℕ) : (m * n) • a = m • (n • a) :=
@pow_mul' (multiplicative A) _ a m n

theorem pow_mul_pow_sub (a : M) {m n : ℕ} (h : m ≤ n) : a ^ m * a ^ (n - m) = a ^ n :=
by rw [←pow_add, nat.add_comm, nat.sub_add_cancel h]

theorem nsmul_add_sub_nsmul (a : A) {m n : ℕ} (h : m ≤ n) : (m • a) + ((n - m) • a) = n • a :=
@pow_mul_pow_sub (multiplicative A) _ _ _ _ h

theorem pow_sub_mul_pow (a : M) {m n : ℕ} (h : m ≤ n) : a ^ (n - m) * a ^ m = a ^ n :=
by rw [←pow_add, nat.sub_add_cancel h]

theorem sub_nsmul_nsmul_add (a : A) {m n : ℕ} (h : m ≤ n) : ((n - m) • a) + (m • a) = n • a :=
@pow_sub_mul_pow (multiplicative A) _ _ _ _ h

theorem pow_bit0 (a : M) (n : ℕ) : a ^ bit0 n = a^n * a^n := pow_add _ _ _

theorem bit0_nsmul (a : A) (n : ℕ) : bit0 n • a = n • a + n • a := add_nsmul _ _ _

theorem pow_bit1 (a : M) (n : ℕ) : a ^ bit1 n = a^n * a^n * a :=
by rw [bit1, pow_succ', pow_bit0]

theorem bit1_nsmul : ∀ (a : A) (n : ℕ), bit1 n • a = n • a + n • a + a :=
@pow_bit1 (multiplicative A) _

theorem pow_mul_comm (a : M) (m n : ℕ) : a^m * a^n = a^n * a^m :=
commute.pow_pow_self a m n

theorem nsmul_add_comm : ∀ (a : A) (m n : ℕ), m • a + n • a = n • a + m • a :=
@pow_mul_comm (multiplicative A) _

@[simp] theorem monoid_hom.map_pow (f : M →* N) (a : M) : ∀(n : ℕ), f (a ^ n) = (f a) ^ n
| 0     := by rw [pow_zero, pow_zero, f.map_one]
| (n+1) := by rw [pow_succ, pow_succ, f.map_mul, monoid_hom.map_pow]

@[simp] theorem add_monoid_hom.map_nsmul (f : A →+ B) (a : A) (n : ℕ) : f (n • a) = n • f a :=
f.to_multiplicative.map_pow a n

theorem is_monoid_hom.map_pow (f : M → N) [is_monoid_hom f] (a : M) :
  ∀(n : ℕ), f (a ^ n) = (f a) ^ n :=
(monoid_hom.of f).map_pow a

theorem is_add_monoid_hom.map_nsmul (f : A → B) [is_add_monoid_hom f] (a : A) (n : ℕ) :
  f (n • a) = n • f a :=
(add_monoid_hom.of f).map_nsmul a n

lemma commute.mul_pow {a b : M} (h : commute a b) (n : ℕ) : (a * b) ^ n = a ^ n * b ^ n :=
nat.rec_on n (by simp) $ λ n ihn,
by simp only [pow_succ, ihn, ← mul_assoc, (h.pow_left n).right_comm]

theorem neg_pow [ring R] (a : R) (n : ℕ) : (- a) ^ n = (-1) ^ n * a ^ n :=
(neg_one_mul a) ▸ (commute.neg_one_left a).mul_pow n

theorem pow_bit0' (a : M) (n : ℕ) : a ^ bit0 n = (a * a) ^ n :=
by rw [pow_bit0, (commute.refl a).mul_pow]

theorem bit0_nsmul' (a : A) (n : ℕ) : bit0 n • a = n • (a + a) :=
@pow_bit0' (multiplicative A) _ _ _

theorem pow_bit1' (a : M) (n : ℕ) : a ^ bit1 n = (a * a) ^ n * a :=
by rw [bit1, pow_succ', pow_bit0']

theorem bit1_nsmul' : ∀ (a : A) (n : ℕ), bit1 n • a = n • (a + a) + a :=
@pow_bit1' (multiplicative A) _

@[simp] theorem neg_pow_bit0 [ring R] (a : R) (n : ℕ) : (- a) ^ (bit0 n) = a ^ (bit0 n) :=
by rw [pow_bit0', neg_mul_neg, pow_bit0']

@[simp] theorem neg_pow_bit1 [ring R] (a : R) (n : ℕ) : (- a) ^ (bit1 n) = - a ^ (bit1 n) :=
by simp only [bit1, pow_succ, neg_pow_bit0, neg_mul_eq_neg_mul]

end monoid

/-!
### Commutative (additive) monoid
-/

section comm_monoid
variables [comm_monoid M] [add_comm_monoid A]

theorem mul_pow (a b : M) (n : ℕ) : (a * b)^n = a^n * b^n :=
(commute.all a b).mul_pow n

theorem nsmul_add : ∀ (a b : A) (n : ℕ), n • (a + b) = n • a + n • b :=
@mul_pow (multiplicative A) _

instance pow.is_monoid_hom (n : ℕ) : is_monoid_hom ((^ n) : M → M) :=
{ map_mul := λ _ _, mul_pow _ _ _, map_one := one_pow _ }

instance nsmul.is_add_monoid_hom (n : ℕ) : is_add_monoid_hom (nsmul n : A → A) :=
{ map_add := λ _ _, nsmul_add _ _ _, map_zero := nsmul_zero _ }

lemma dvd_pow {x y : M} :
  ∀ {n : ℕ} (hxy : x ∣ y) (hn : n ≠ 0), x ∣ y^n
| 0     hxy hn := (hn rfl).elim
| (n+1) hxy hn := by { rw [pow_succ], exact dvd_mul_of_dvd_left hxy _ }

end comm_monoid

section div_inv_monoid
variable [div_inv_monoid G]

open int

@[simp, norm_cast] theorem gpow_coe_nat (a : G) (n : ℕ) : a ^ (n:ℤ) = a ^ n :=
begin
  induction n with n ih,
  { change gpow 0 a = a ^ 0, rw [div_inv_monoid.gpow_zero', pow_zero] },
  { change gpow (of_nat n) a = a ^ n at ih,
    change gpow (of_nat n.succ) a = a ^ n.succ,
    rw [div_inv_monoid.gpow_succ', pow_succ, ih] }
end

theorem gpow_of_nat (a : G) (n : ℕ) : a ^ of_nat n = a ^ n :=
gpow_coe_nat _ _

@[simp] theorem gpow_neg_succ_of_nat (a : G) (n : ℕ) : a ^ -[1+n] = (a ^ n.succ)⁻¹ :=
by { rw ← gpow_coe_nat, exact div_inv_monoid.gpow_neg' n a }

@[simp] theorem gpow_zero (a : G) : a ^ (0:ℤ) = 1 :=
by { convert pow_zero a using 1, exact gpow_coe_nat a 0 }

@[simp] theorem gpow_one (a : G) : a ^ (1:ℤ) = a :=
by { convert pow_one a using 1, exact gpow_coe_nat a 1 }

end div_inv_monoid

section group
variables [group G] [group H] [add_group A] [add_group B]

open int

section nat

@[simp] theorem inv_pow (a : G) (n : ℕ) : (a⁻¹)^n = (a^n)⁻¹ :=
begin
  induction n with n ih,
  { rw [pow_zero, pow_zero, one_inv] },
  { rw [pow_succ', pow_succ, ih, mul_inv_rev] }
end

@[simp] theorem neg_nsmul : ∀ (a : A) (n : ℕ), n • (-a) = -(n • a) :=
@inv_pow (multiplicative A) _

theorem pow_sub (a : G) {m n : ℕ} (h : n ≤ m) : a^(m - n) = a^m * (a^n)⁻¹ :=
have h1 : m - n + n = m, from nat.sub_add_cancel h,
have h2 : a^(m - n) * a^n = a^m, by rw [←pow_add, h1],
eq_mul_inv_of_mul_eq h2

theorem nsmul_sub : ∀ (a : A) {m n : ℕ}, n ≤ m → (m - n) • a = m • a - n • a :=
by simpa only [sub_eq_add_neg] using @pow_sub (multiplicative A) _

theorem pow_inv_comm (a : G) (m n : ℕ) : (a⁻¹)^m * a^n = a^n * (a⁻¹)^m :=
(commute.refl a).inv_left.pow_pow m n

theorem nsmul_neg_comm : ∀ (a : A) (m n : ℕ), m • (-a) + n • a = n • a + m • (-a) :=
@pow_inv_comm (multiplicative A) _

end nat


@[simp, norm_cast] theorem gsmul_coe_nat (a : A) (n : ℕ) : (n : ℤ) • a = n • a :=
@gpow_coe_nat (multiplicative A) _ _ _

theorem gsmul_of_nat (a : A) (n : ℕ) : of_nat n • a = n • a :=
gsmul_coe_nat _ _

@[simp] theorem gsmul_neg_succ_of_nat (a : A) (n : ℕ) : -[1+n] • a = - (n.succ • a) :=
@gpow_neg_succ_of_nat (multiplicative A) _ _ _

@[simp] theorem zero_gsmul (a : A) : (0:ℤ) • a = 0 :=
@gpow_zero (multiplicative A) _ _

@[simp] theorem one_gsmul (a : A) : (1:ℤ) • a = a :=
@gpow_one (multiplicative A) _ _

@[simp] theorem one_gpow : ∀ (n : ℤ), (1 : G) ^ n = 1
| (n : ℕ) := by rw [gpow_coe_nat, one_pow]
| -[1+ n] := by rw [gpow_neg_succ_of_nat, one_pow, one_inv]

@[simp] theorem gsmul_zero : ∀ (n : ℤ), n • (0 : A) = 0 :=
@one_gpow (multiplicative A) _

@[simp] theorem gpow_neg (a : G) : ∀ (n : ℤ), a ^ -n = (a ^ n)⁻¹
| (n+1:ℕ) := div_inv_monoid.gpow_neg' _ _
| 0       := by { change a ^ (0 : ℤ) = (a ^ (0 : ℤ))⁻¹, simp }
| -[1+ n] := by { rw [gpow_neg_succ_of_nat, inv_inv, ← gpow_coe_nat], refl }

lemma mul_gpow_neg_one (a b : G) : (a*b)^(-(1:ℤ)) = b^(-(1:ℤ))*a^(-(1:ℤ)) :=
by simp only [mul_inv_rev, gpow_one, gpow_neg]

@[simp] theorem neg_gsmul : ∀ (a : A) (n : ℤ), -n • a = -(n • a) :=
@gpow_neg (multiplicative A) _

theorem gpow_neg_one (x : G) : x ^ (-1:ℤ) = x⁻¹ :=
by { rw [← congr_arg has_inv.inv (pow_one x), gpow_neg, ← gpow_coe_nat], refl }

theorem neg_one_gsmul (x : A) : (-1:ℤ) • x = -x :=
@gpow_neg_one (multiplicative A) _ _

theorem inv_gpow (a : G) : ∀n:ℤ, a⁻¹ ^ n = (a ^ n)⁻¹
| (n : ℕ) := by rw [gpow_coe_nat, gpow_coe_nat, inv_pow]
| -[1+ n] := by rw [gpow_neg_succ_of_nat, gpow_neg_succ_of_nat, inv_pow]

theorem gsmul_neg (a : A) (n : ℤ) : n • (- a) = - (n • a) :=
@inv_gpow (multiplicative A) _ a n

theorem commute.mul_gpow {a b : G} (h : commute a b) : ∀ n : ℤ, (a * b) ^ n = a ^ n * b ^ n
| (n : ℕ) := by simp [gpow_coe_nat, h.mul_pow n]
| -[1+n]  := by simp [h.mul_pow, (h.pow_pow n.succ n.succ).inv_inv.symm.eq]

end group

section comm_group
variables [comm_group G] [add_comm_group A]

theorem mul_gpow (a b : G) (n : ℤ) : (a * b)^n = a^n * b^n := (commute.all a b).mul_gpow n

theorem gsmul_add : ∀ (a b : A) (n : ℤ), n • (a + b) = n • a + n • b :=
@mul_gpow (multiplicative A) _

theorem gsmul_sub (a b : A) (n : ℤ) : n • (a - b) = n • a - n • b :=
by simp only [gsmul_add, gsmul_neg, sub_eq_add_neg]

instance gpow.is_group_hom (n : ℤ) : is_group_hom ((^ n) : G → G) :=
{ map_mul := λ _ _, mul_gpow _ _ n }

instance gsmul.is_add_group_hom (n : ℤ) : is_add_group_hom (gsmul n : A → A) :=
{ map_add := λ _ _, gsmul_add _ _ n }

end comm_group

lemma zero_pow [monoid_with_zero R] : ∀ {n : ℕ}, 0 < n → (0 : R) ^ n = 0
| (n+1) _ := by rw [pow_succ, zero_mul]

lemma zero_pow_eq [monoid_with_zero R] (n : ℕ) : (0 : R)^n = if n = 0 then 1 else 0 :=
begin
  split_ifs with h,
  { rw [h, pow_zero], },
  { rw [zero_pow (nat.pos_of_ne_zero h)] },
end

namespace ring_hom

variables [semiring R] [semiring S]

@[simp] lemma map_pow (f : R →+* S) (a) :
  ∀ n : ℕ, f (a ^ n) = (f a) ^ n :=
f.to_monoid_hom.map_pow a

end ring_hom

section
variables (R)

theorem neg_one_pow_eq_or [ring R] : ∀ n : ℕ, (-1 : R)^n = 1 ∨ (-1 : R)^n = -1
| 0     := or.inl (pow_zero _)
| (n+1) := (neg_one_pow_eq_or n).swap.imp
  (λ h, by rw [pow_succ, h, neg_one_mul, neg_neg])
  (λ h, by rw [pow_succ, h, mul_one])

end

@[simp]
lemma neg_one_pow_mul_eq_zero_iff [ring R] {n : ℕ} {r : R} : (-1)^n * r = 0 ↔ r = 0 :=
by rcases neg_one_pow_eq_or R n; simp [h]

@[simp]
lemma mul_neg_one_pow_eq_zero_iff [ring R] {n : ℕ} {r : R} : r * (-1)^n = 0 ↔ r = 0 :=
by rcases neg_one_pow_eq_or R n; simp [h]

lemma pow_dvd_pow [monoid R] (a : R) {m n : ℕ} (h : m ≤ n) :
  a ^ m ∣ a ^ n := ⟨a ^ (n - m), by rw [← pow_add, nat.add_comm, nat.sub_add_cancel h]⟩

theorem pow_dvd_pow_of_dvd [comm_monoid R] {a b : R} (h : a ∣ b) : ∀ n : ℕ, a ^ n ∣ b ^ n
| 0     := by rw [pow_zero, pow_zero]
| (n+1) := by { rw [pow_succ, pow_succ], exact mul_dvd_mul h (pow_dvd_pow_of_dvd n) }

lemma sq_sub_sq {R : Type*} [comm_ring R] (a b : R) :
  a ^ 2 - b ^ 2 = (a + b) * (a - b) :=
by rw [sq, sq, mul_self_sub_mul_self]

alias sq_sub_sq ← pow_two_sub_pow_two

lemma eq_or_eq_neg_of_sq_eq_sq [integral_domain R] (a b : R) (h : a ^ 2 = b ^ 2) :
  a = b ∨ a = -b :=
by rwa [← add_eq_zero_iff_eq_neg, ← sub_eq_zero, or_comm, ← mul_eq_zero,
        ← sq_sub_sq a b, sub_eq_zero]

theorem pow_eq_zero [monoid_with_zero R] [no_zero_divisors R] {x : R} {n : ℕ} (H : x^n = 0) :
  x = 0 :=
begin
  induction n with n ih,
  { rw pow_zero at H,
    rw [← mul_one x, H, mul_zero] },
  { rw pow_succ at H,
    exact or.cases_on (mul_eq_zero.1 H) id ih }
end

@[simp] lemma pow_eq_zero_iff [monoid_with_zero R] [no_zero_divisors R]
  {a : R} {n : ℕ} (hn : 0 < n) :
  a ^ n = 0 ↔ a = 0 :=
begin
  refine ⟨pow_eq_zero, _⟩,
  rintros rfl,
  exact zero_pow hn,
end

lemma pow_ne_zero_iff [monoid_with_zero R] [no_zero_divisors R] {a : R} {n : ℕ} (hn : 0 < n) :
  a ^ n ≠ 0 ↔ a ≠ 0 :=
by rwa [not_iff_not, pow_eq_zero_iff]

@[field_simps] theorem pow_ne_zero [monoid_with_zero R] [no_zero_divisors R]
  {a : R} (n : ℕ) (h : a ≠ 0) : a ^ n ≠ 0 :=
mt pow_eq_zero h

section semiring

variables [semiring R]

lemma min_pow_dvd_add {n m : ℕ} {a b c : R} (ha : c ^ n ∣ a) (hb : c ^ m ∣ b) :
  c ^ (min n m) ∣ a + b :=
begin
  replace ha := dvd.trans (pow_dvd_pow c (min_le_left n m)) ha,
  replace hb := dvd.trans (pow_dvd_pow c (min_le_right n m)) hb,
  exact dvd_add ha hb
end

end semiring

section comm_semiring

variables [comm_semiring R]

lemma add_sq (a b : R) : (a + b) ^ 2 = a ^ 2 + 2 * a * b + b ^ 2 :=
by simp only [sq, add_mul_self_eq]

alias add_sq ← add_pow_two

end comm_semiring

@[simp] lemma neg_sq {α} [ring α] (z : α) : (-z)^2 = z^2 :=
by simp [sq]

alias neg_sq ← neg_pow_two

lemma sub_sq {R} [comm_ring R] (a b : R) : (a - b) ^ 2 = a ^ 2 - 2 * a * b + b ^ 2 :=
by rw [sub_eq_add_neg, add_sq, neg_sq, mul_neg_eq_neg_mul_symm, ← sub_eq_add_neg]

alias sub_sq ← sub_pow_two

lemma of_add_nsmul [add_monoid A] (x : A) (n : ℕ) :
  multiplicative.of_add (n • x) = (multiplicative.of_add x)^n := rfl

lemma of_add_gsmul [add_group A] (x : A) (n : ℤ) :
  multiplicative.of_add (n • x) = (multiplicative.of_add x)^n := rfl

lemma of_mul_pow {A : Type*} [monoid A] (x : A) (n : ℕ) :
  additive.of_mul (x ^ n) = n • (additive.of_mul x) := rfl

lemma of_mul_gpow [group G] (x : G) (n : ℤ) : additive.of_mul (x ^ n) = n • additive.of_mul x :=
rfl

@[simp] lemma semiconj_by.gpow_right [group G] {a x y : G} (h : semiconj_by a x y) :
  ∀ m : ℤ, semiconj_by a (x^m) (y^m)
| (n : ℕ) := by simp [gpow_coe_nat, h.pow_right n]
| -[1+n] := by simp [(h.pow_right n.succ).inv_right]

namespace commute

variables [group G] {a b : G}

@[simp] lemma gpow_right (h : commute a b) (m : ℤ) : commute a (b^m) :=
h.gpow_right m

@[simp] lemma gpow_left (h : commute a b) (m : ℤ) : commute (a^m) b :=
(h.symm.gpow_right m).symm

lemma gpow_gpow (h : commute a b) (m n : ℤ) : commute (a^m) (b^n) := (h.gpow_left m).gpow_right n

variables (a) (m n : ℤ)

@[simp] theorem self_gpow : commute a (a ^ n) := (commute.refl a).gpow_right n
@[simp] theorem gpow_self : commute (a ^ n) a := (commute.refl a).gpow_left n
@[simp] theorem gpow_gpow_self : commute (a ^ m) (a ^ n) := (commute.refl a).gpow_gpow m n

end commute
