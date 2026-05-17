-- ID: p1_s12_step1
def N (h k : ℕ) : ℕ := sorry

-- ID: p1_s12_step2
theorem main_bound (h : ℕ) : ∃ C_h : ℕ, ∀ k : ℕ, N h k ≤ k ^ C_h := by sorry

-- ID: p1_s12_step3
theorem hilbert_replacement_validity (h : ℕ) : ∀ A : Finset ℤ, A.card = k → ∃ B : Finset ℕ, B.card = k ∧ B ⊆ Finset.Icc 1 (N h k) ∧ (h • A).card = (h • B).card := by sorry

-- ID: p1_s22_step1
def h_fold_sumset (A : Finset ℤ) (h : ℕ) : Finset ℤ := sorry

-- ID: p1_s22_step2
def R (h k : ℕ) : Set ℕ := sorry

-- ID: p1_s22_step3
def N (h k : ℕ) : ℕ := sorry

-- ID: p1_s22_step4
theorem polynomial_compression_bound (h k : ℕ) : N h k ≤ poly_bound h k := by sorry

-- ID: p1_s999_step1
theorem thm_1_1_bound (h k : ℕ) (h_ge : h ≥ 1) (k_ge : k ≥ 2) : ∃ C : ℝ, N h k ≤ k * C ^ h := by sorry

-- ID: p1_s999_step2
def M (h k : ℕ) : ℕ := Nat.choose (h + k - 1) h
def K (h k : ℕ) : ℕ := Nat.choose (h + k - 1) k
def Delta (h k : ℕ) : Set ℤ := ⋃ ℓ ∈ Finset.range (min h k - 2), Icc (M h k + ℓ * h + 1) (M h k + ℓ * h + (h - 2 - ℓ))

-- ID: p1_s999_step3
notation "[u, v]" => {n : ℤ | u ≤ n ∧ n ≤ v}