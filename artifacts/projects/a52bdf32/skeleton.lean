-- ID: p1_s12_step1
def N (h k : ℕ) : ℕ := Classical.choose (exists_least_N h k)

-- ID: p1_s12_step2
theorem upper_bound_N_h_k (h k : ℕ) : N h k ≤ k ^ C_h := by sorry

-- ID: p1_s12_step3
structure poly_diameter_replacement (A : Finset ℤ) := (replacement : Finset ℕ) (h_equiv : card_sumsets_eq A replacement)

-- ID: p1_s12_step4
theorem hilbert_functions_determine_h_fold_sumsets (h : ℕ) (f g : Polynomial ℤ) : hilbert_func f = hilbert_func g → sumset_card h f = sumset_card h g := by sorry

-- ID: p1_s22_step1
def hA (A : Finset ℤ) (h : ℕ) : Finset ℤ := Finset.image (fun f => Finset.sum f id) (Finset.univ : Finset (Fin h → A)) -- 示意性骨架

-- ID: p1_s22_step2
def N (h k : ℕ) : ℕ := Nat.find (∃ N, ∀ A : Finset ℕ, A.card = k → A ⊆ Finset.Icc 1 N → (hA A h).card ∈ R h k) -- 示意性骨架

-- ID: p1_s22_step3
theorem polynomial_compression_bound (h k : ℕ) : ∃ C > 0, N h k ≤ C * (k ^ h) := by sorry

-- ID: p1_s999_step1
theorem thm_1_1 (h : ℕ) (h_ge : h ≥ 1) : ∃ C : ℝ, ∀ k : ℕ, k ≥ 2 → N h k ≤ k ^ (C * h) := by sorry

-- ID: p1_s999_step2
def M (h k : ℕ) : ℕ := h ^ (k - h + 1)
def K (h k : ℕ) : ℕ := Nat.choose (h + k - 1) h
def Delta (h k : ℕ) : Set ℤ := ⋃ ℓ ∈ Finset.range (min h k - 2), Icc (M h k + ℓ * h + 1) (M h k + ℓ * h + (h - 2 - ℓ)) := by sorry

-- ID: p1_s999_step3
def Interval (u v : ℤ) : Set ℤ := { n : ℤ | u ≤ n ∧ n ≤ v }
lemma Interval_empty (u v : ℤ) (h : u > v) : Interval u v = ∅ := by sorry