/-
Copyright (c) 2016 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro

Miscellaneous function constructions and lemmas.
-/
import logic.basic

universes u v
variables {α : Type u} {β : Type v} {f : α → β}

namespace function

@[simp] theorem injective.eq_iff (I : injective f) {a b : α} :
  f a = f b ↔ a = b :=
⟨@I _ _, congr_arg f⟩

local attribute [instance] classical.decidable_inhabited classical.prop_decidable

noncomputable def partial_inv (f : α → β) (b : β) : option α :=
if h : ∃ a, f a = b then some (classical.some h) else none

theorem partial_inv_eq {f : α → β} (I : injective f) (a : α) : (partial_inv f (f a)) = some a :=
have h : ∃ a', f a' = f a, from ⟨_, rfl⟩,
(dif_pos h).trans (congr_arg _ (I $ classical.some_spec h))

theorem partial_inv_eq_of_eq {f : α → β} (I : injective f) {b : β} {a : α}
  (h : partial_inv f b = some a) : f a = b :=
by by_cases (∃ a, f a = b) with h'; simp [partial_inv, h'] at h;
   injection h with h; subst h; apply classical.some_spec h'

variables {s : set α} {a : α} {b : β}

section inv_fun
variable [inhabited α]

noncomputable def inv_fun_on (f : α → β) (s : set α) (b : β) : α :=
if h : ∃a, a ∈ s ∧ f a = b then classical.some h else default α

theorem inv_fun_on_pos (h : ∃a∈s, f a = b) : inv_fun_on f s b ∈ s ∧ f (inv_fun_on f s b) = b :=
by rw [bex_def] at h; rw [inv_fun_on, dif_pos h]; exact classical.some_spec h

theorem inv_fun_on_mem (h : ∃a∈s, f a = b) : inv_fun_on f s b ∈ s := (inv_fun_on_pos h).left

theorem inv_fun_on_eq (h : ∃a∈s, f a = b) : f (inv_fun_on f s b) = b := (inv_fun_on_pos h).right

theorem inv_fun_on_eq' (h : ∀x∈s, ∀y∈s, f x = f y → x = y) (ha : a ∈ s) :
  inv_fun_on f s (f a) = a :=
have ∃a'∈s, f a' = f a, from ⟨a, ha, rfl⟩,
h _ (inv_fun_on_mem this) _ ha (inv_fun_on_eq this)

theorem inv_fun_on_neg (h : ¬ ∃a∈s, f a = b) : inv_fun_on f s b = default α :=
by rw [bex_def] at h; rw [inv_fun_on, dif_neg h]

noncomputable def inv_fun (f : α → β) : β → α := inv_fun_on f set.univ

theorem inv_fun_eq (h : ∃a, f a = b) : f (inv_fun f b) = b :=
inv_fun_on_eq $ let ⟨a, ha⟩ := h in ⟨a, trivial, ha⟩

theorem inv_fun_eq_of_injective_of_right_inverse {g : β → α}
  (hf : injective f) (hg : right_inverse g f) : inv_fun f = g :=
funext $ assume b,
hf begin rw [hg b], exact inv_fun_eq ⟨g b, hg b⟩ end

lemma right_inverse_inv_fun (hf : surjective f) : right_inverse (inv_fun f) f :=
assume b, inv_fun_eq $ hf b

lemma left_inverse_inv_fun (hf : injective f) : left_inverse (inv_fun f) f :=
assume b,
have f (inv_fun f (f b)) = f b,
  from inv_fun_eq ⟨b, rfl⟩,
hf this

lemma injective.has_left_inverse (hf : injective f) : has_left_inverse f :=
⟨inv_fun f, left_inverse_inv_fun hf⟩

end inv_fun

section surj_inv

noncomputable def surj_inv {f : α → β} (h : surjective f) (b : β) : α := classical.some (h b)

lemma surj_inv_eq (h : surjective f) : f (surj_inv h b) = b := classical.some_spec (h b)

lemma right_inverse_surj_inv (hf : surjective f) : right_inverse (surj_inv hf) f :=
assume b, surj_inv_eq hf

lemma surjective.has_right_inverse (hf : surjective f) : has_right_inverse f :=
⟨_, right_inverse_surj_inv hf⟩

lemma injective_surj_inv (h : surjective f) : injective (surj_inv h) :=
injective_of_has_left_inverse ⟨f, right_inverse_surj_inv h⟩

end surj_inv

end function