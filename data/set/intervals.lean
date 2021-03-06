/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Johannes Hölzl

Intervals

Nameing conventions:
  `i`: infinite
  `o`: open
  `c`: closed

Each interval has the name `I` + letter for left side + letter for right side

TODO: This is just the beginning a lot of interavals and rules are missing
-/
import data.set.lattice algebra.order algebra.functions

namespace set

open set

section intervals
variables {α : Type*} [preorder α]

/-- Left-open right-open interval -/
def Ioo (a b : α) := {x | a < x ∧ x < b}

/-- Left-closed right-open interval -/
def Ico (a b : α) := {x | a ≤ x ∧ x < b}

/-- Left-infinite right-open interval -/
def Iio (a : α) := {x | x < a}

end intervals

section decidable_linear_order
variables {α : Type*} [decidable_linear_order α] {a a₁ a₂ b b₁ b₂ : α}

@[simp] lemma Ioo_eq_empty_of_ge {h : b ≤ a} : Ioo a b = ∅ :=
set.ext $ assume x,
  have a < x → b ≤ x, from assume ha, le_trans h $ le_of_lt ha,
  by simp [Ioo]; exact this

lemma Ico_eq_empty_iff : Ico a b = ∅ ↔ (b ≤ a) :=
by rw [←not_lt_iff];
from iff.intro
  (assume eq h, have a ∈ Ico a b, from ⟨le_refl a, h⟩, by rwa [eq] at this)
  (assume h, eq_empty_of_forall_not_mem $ assume x ⟨h₁, h₂⟩, h $ lt_of_le_of_lt h₁ h₂)

@[simp] lemma Ico_eq_empty : b ≤ a → Ico a b = ∅ := Ico_eq_empty_iff.mpr

lemma Ico_subset_Ico_iff (h₁ : a₁ < b₁) : Ico a₁ b₁ ⊆ Ico a₂ b₂ ↔ (a₂ ≤ a₁ ∧ b₁ ≤ b₂) :=
iff.intro
  (assume h,
    have h' : a₁ ∈ Ico a₂ b₂, from h ⟨le_refl _, h₁⟩,
    have ¬ b₂ < b₁, from assume : b₂ < b₁,
      have b₂ ∈ Ico a₂ b₂, from h ⟨le_of_lt h'.right, this⟩,
      lt_irrefl b₂ this.right,
    ⟨h'.left, not_lt_iff.mp $ this⟩)
  (assume ⟨h₁, h₂⟩ x ⟨hx₁, hx₂⟩, ⟨le_trans h₁ hx₁, lt_of_lt_of_le hx₂ h₂⟩)

lemma Ico_eq_Ico_iff : Ico a₁ b₁ = Ico a₂ b₂ ↔ ((b₁ ≤ a₁ ∧ b₂ ≤ a₂) ∨ (a₁ = a₂ ∧ b₁ = b₂)) :=
begin
  by_cases a₁ < b₁ with h₁; by_cases a₂ < b₂ with h₂,
  { rw [subset.antisymm_iff, Ico_subset_Ico_iff h₁, Ico_subset_Ico_iff h₂],
    simp [iff_def, le_antisymm_iff, or_imp_distrib, not_le_of_gt h₁] {contextual := tt} },
  { have h₂ : b₂ ≤ a₂, from not_lt_iff.mp h₂,
    rw [Ico_eq_empty_iff.mpr h₂, Ico_eq_empty_iff],
    simp [iff_def, h₂, or_imp_distrib] {contextual := tt} },
  { have h₁ : b₁ ≤ a₁, from not_lt_iff.mp h₁,
    rw [Ico_eq_empty_iff.mpr h₁, eq_comm, Ico_eq_empty_iff],
    simp [iff_def, h₁, or_imp_distrib] {contextual := tt}, cc },
  { have h₁ : b₁ ≤ a₁, from not_lt_iff.mp h₁,
    have h₂ : b₂ ≤ a₂, from not_lt_iff.mp h₂,
    rw [Ico_eq_empty_iff.mpr h₁, Ico_eq_empty_iff.mpr h₂],
    simp [iff_def, h₁, h₂] {contextual := tt} }
end

@[simp] lemma Ico_sdiff_Iio_eq {a b c : α} : Ico a b \ Iio c = Ico (max a c) b :=
set.ext $ by simp [Ico, Iio, iff_def, max_le_iff] {contextual:=tt}

@[simp] lemma Ico_inter_Iio_eq {a b c : α} : Ico a b ∩ Iio c = Ico a (min b c) :=
set.ext $ by simp [Ico, Iio, iff_def, lt_min_iff] {contextual:=tt}

lemma Ioo_inter_Ioo {a b c d : α} : Ioo a b ∩ Ioo c d = Ioo (max a c) (min b d) :=
set.ext $ assume x, by simp [iff_def, Ioo, lt_min_iff, max_lt_iff] {contextual := tt}

end decidable_linear_order

end set