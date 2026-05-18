-- ID: p1_s12_step1
def N (h k : ℕ) : ℕ := sorry -- 最小 N 使得 ∀ A : Finset ℤ, A.card = k → ∃ B ⊆ Finset.Icc 1 N, B.card = k ∧ (h • B).card = (h • A).card

-- ID: p1_s12_step2
theorem polynomial_compression_bound (h : ℕ) : ∃ C_h : ℕ, ∀ k : ℕ, N h k ≤ k ^ C_h := by sorry

-- ID: p1_s12_step3
lemma hilbert_function_preservation (h : ℕ) (A : Finset ℤ) : ∃ B : Finset ℕ, B.card = A.card ∧ hilbert_function h B = hilbert_function h A := by sorry

-- ID: p1_s22_step1
def h_fold_sumset (A : Finset ℤ) (h : ℕ) : Finset ℤ := sorry

-- ID: p1_s22_step2
def R (h k : ℕ) : Finset ℕ := sorry

-- ID: p1_s22_step3
def N (h k : ℕ) : ℕ := sorry

-- ID: p1_s22_step4
theorem polynomial_compression_bound (h k : ℕ) : N h k ≤ poly_bound h k := by sorry

-- ID: p1_s999_step1
theorem main_bound (h k : ℕ) (C : ℝ) : h ≥ 1 → k ≥ 2 → N h k ≤ k ^ (C * h) := by sorry

-- ID: p1_s999_step2
def M (h k : ℕ) : ℕ := Nat.choose (h + k - 1) h
def K (h k : ℕ) : ℕ := Nat.choose (h + k - 1) k

-- ID: p1_s999_step3
def Delta (h k : ℕ) : Set ℤ := ⋃ ℓ ∈ Finset.range (min h k - 2), Icc (M h k + ℓ * h + 1) (M h k + ℓ * h + (h - 2 - ℓ)) := by sorry

-- ID: p1_s999_step4
lemma interval_def (u v : ℤ) : (u ≤ v → Icc u v = {n : ℤ | u ≤ n ∧ n ≤ v}) ∧ (u > v → Icc u v = ∅) := by sorry