-- ID: p1_s12_step1
def N (h k : ℕ) : ℕ := sorry

-- ID: p1_s12_step2
theorem rajagopal_fixed_h_range (h : ℕ) (A : Finset ℤ) : ... := sorry

-- ID: p1_s12_step3
theorem polynomial_compression_bound (h k : ℕ) : ∃ C_h : ℝ, (N h k : ℝ) ≤ (k : ℝ) ^ C_h := by sorry

-- ID: p1_s12_step4
def hilbert_function_replacement (h : ℕ) : ... := sorry

-- ID: p1_s22_step1
def h_sumset (A : Finset ℤ) (h : ℕ) : Finset ℤ := sorry

-- ID: p1_s22_step2
def R (h k : ℕ) : Set ℕ := sorry

-- ID: p1_s22_step3
def N (h k : ℕ) : ℕ := sorry

-- ID: p1_s22_step4
theorem polynomial_compression_bound (h k : ℕ) : N h k ≤ sorry := by sorry

-- ID: p1_s999_step1
theorem theorem_1_1 (h : ℕ) (hh : h ≥ 1) : ∃ C : ℝ, ∀ k : ℕ, k ≥ 2 → N h k ≤ k ^ (C * h) := by sorry

-- ID: p1_s999_step2
-- 证明依赖外部引理：Rajagopal's theorem on sumset ranges
axiom rajagopal_sumset_range : ∀ (h k : ℕ), ...

-- ID: p1_s999_step3
def M (h k : ℕ) : ℕ := h * k - h + 1
def K (h k : ℕ) : ℕ := Nat.choose (h + k - 1) h
def Delta (h k : ℕ) : Set ℕ := ⋃ ℓ in Finset.range (min h k - 2), Set.Icc (M h k + ℓ * h + 1) (M h k + ℓ * h + (h - 2 - ℓ))

-- ID: p1_s999_step4
-- 区间约定已对齐 Mathlib 标准定义 Set.Icc u v = {n | u ≤ n ∧ n ≤ v}
-- 当 u > v 时自动退化为 ∅

-- ID: p2_s14_step1
theorem rajagopal_threshold (h : ℕ) : ∃ k_h : ℕ, ∀ k > k_h, R h k = Set.Icc (M h k) (K h k) \ Δ h k := by sorry

-- ID: p2_s14_step2
theorem constructive_witness_large_k (h k : ℕ) (hk : k > k_h h) : ∃ (W : Finset ℤ), (∀ x ∈ R h k, ∃ w ∈ W, witness_rel w x) ∧ diam W ≤ poly k := by sorry

-- ID: p2_s14_step3
theorem absorb_small_k (h : ℕ) : ∃ C : ℝ, ∀ k ≤ k_h h, ∃ (W : Finset ℤ), covers_range W ∧ diam W ≤ C * poly k := by sorry

-- ID: p2_s14_step4
theorem lower_range_filling_set (h k : ℕ) : diam (filling_set h k) ≤ poly k := by sorry

-- ID: p2_s14_step5
theorem upper_range_lattice_gadget (h k : ℕ) : ∃ (G : LatticeGadget), trunc_gen_func G = trunc_gen_func (geo_prog h k) ∧ diam G ≤ poly k := by sorry

-- ID: p2_s14_step6
theorem mixed_radix_embedding (h : ℕ) (G : LatticeGadget) : ∃ (φ : G → ℤ), function.injective φ ∧ diam (φ '' G) ≤ poly (diam G) := by sorry

-- ID: p2_s27_step1
variable (h k : ℕ)
-- 约定隐含常数仅依赖于 h

-- ID: p2_s27_step2
def F_A (A : Finset G) (z : R) : R :=
  ∑ q in Finset.range (h + 1), (q • A).card * z ^ q

-- ID: p2_s27_step3
theorem identities_mod_z_pow (A : Finset G) :
  (F_A A z) % (z ^ (h + 1)) = F_A A z := by sorry

-- ID: p2_s30_step1
variable {r s : ℕ} (A : Finset (Fin r → ℤ)) (B : Finset (Fin s → ℤ))

-- ID: p2_s30_step2
def disjoint_union (A : Finset (Fin r → ℤ)) (B : Finset (Fin s → ℤ)) : Finset (Fin (r + s + 2) → ℤ) := sorry

-- ID: p2_s30_step3
theorem iterated_disjoint_union_assoc : ∀ (A B C : Finset _), (A ⊔ B) ⊔ C = A ⊔ (B ⊔ C) := by sorry

-- ID: p2_s33_step1
theorem lemma_2_2 {α : Type*} (A B : Finset α) (h : ℕ) : F (A ⊔ B) ≡ F A * F B [PMOD X^(h + 1)] := by sorry

-- ID: p2_s40_step1
lemma element_coordinate_decomposition {q : ℕ} {A B : Type} (x : Multiset (A ⊕ B)) (hx : x.card = q) : ∃! i : ℕ, i ≤ q ∧ (x.filter Sum.isLeft).card = i := by sorry

-- ID: p2_s40_step2
theorem cardinality_sum_identity {q : ℕ} {A B : Fintype} : Fintype.card (Sym (A ⊕ B) q) = ∑ i in Finset.range (q + 1), Fintype.card (Sym A i) * Fintype.card (Sym B (q - i)) := by sorry

-- ID: p2_s40_step3
theorem coefficient_identity_match {q : ℕ} : (∑ i in Finset.range (q + 1), card_A i * card_B (q - i)) = target_coeff q := by sorry

-- ID: p2_s43_step1
def A (D M : ℕ) : Set (Fin D → ℤ) := { x | ∀ i, 0 ≤ x i ∧ x i ≤ M }

-- ID: p2_s43_step2
def phi (D : ℕ) (Q : ℤ) (x : Fin D → ℤ) : ℤ := ∑ i : Fin D, x i * Q ^ (i : ℕ)

-- ID: p2_s999_step1
theorem freiman_isomorphism_order_h (A : Finset ℕ) (ϕ : ℕ → ℕ) (h : ℕ) : IsFreimanIsomorphism ϕ A h := by sorry

-- ID: p2_s999_step2
theorem image_diameter_polynomial_bound (A : Finset ℕ) (ϕ : ℕ → ℕ) (D M Q k h : ℕ) : ϕ '' A ⊆ Finset.Icc 0 (D * M * Q ^ (D - 1)) := by sorry

-- ID: p3_s3_step1
lemma sum_coord_bound {n : ℕ} (A : Fin n → ℕ) (h M : ℕ) (S : Finset (Fin n)) (hS : S.card ≤ h) (hA : ∀ a ∈ S, ∀ i, A a i ≤ M) : ∀ i, (∑ a in S, A a i) ≤ h * M := by sorry

-- ID: p3_s3_step2
theorem phi_inj_on_bounded_vectors {n : ℕ} (Q h M : ℕ) (hQ : Q > h * M) (v₁ v₂ : Fin n → ℕ) (hv₁ : ∀ i, v₁ i ≤ h * M) (hv₂ : ∀ i, v₂ i ≤ h * M) : (∑ i, v₁ i * Q ^ (i : ℕ)) = (∑ i, v₂ i * Q ^ (i : ℕ)) → v₁ = v₂ := by sorry

-- ID: p3_s6_step1
section polynomial_diameter_free_and_carry_gadgets

/-- 我们首先记录一个具有显式多项式直径的 $B$-集族。 -/
theorem exists_explicit_poly_diam_B_sets : ∃ (ℬ : Set (Set α)), sorry := by sorry

-- ID: p3_s18_step1
lemma polynomial_free_blocks_existence (r h : ℕ) (hr : r ≥ 1) : ∃ (U : Finset (Fin (h + 1) → ℤ)), U.card = r ∧ (∀ x ∈ U, ∀ i, |x i| ≤ r^h) := by sorry

-- ID: p3_s18_step2
lemma sumset_cardinality (U : Finset (Fin (h + 1) → ℤ)) (q : ℕ) (hq : q ≤ h) : (q • U).card = Nat.choose (r + q - 1) q := by sorry

-- ID: p3_s18_step3
lemma generating_function_equiv (U : Finset (Fin (h + 1) → ℤ)) : F_U z ≡ (1 - z)^(-r : ℤ) [PMOD z^(h + 1)] := by sorry

-- ID: p3_s18_step4
lemma base_case_r_zero : U = ∅ ∧ F = 1 := by sorry

-- ID: p3_s29_step1
def U (r h : ℕ) : Set (Fin (h + 1) → ℕ) := {v | ∃ i ∈ Finset.Icc 1 r, ∀ k, v k = i ^ k}
theorem q_fold_sums_eq_implies_multiset_eq {r h q : ℕ} (hq : q ≤ h) : ... := by sorry

-- ID: p3_s29_step2
have h_card : s1.card = q ∧ s2.card = q := by sorry
have h_power_sums : ∀ k ≤ h, (s1.map (λ v => v k)).sum = (s2.map (λ v => v k)).sum := by sorry

-- ID: p3_s29_step3
have h_elem_sym : elementary_symmetric_poly s1 = elementary_symmetric_poly s2 := by sorry
have h_multiset_eq : s1 = s2 := by sorry
exact distinct_q_fold_sums h_multiset_eq

-- ID: p3_s29_step4
def polynomial_replacement (base : DissociatedBase) : Polynomial ℕ := by sorry
theorem sparse_geometric_block_replacement : ... := by sorry

-- ID: p3_s46_step1
def is_L_dissociated {G : Type*} [AddCommGroup G] [IsTorsionFree G] (u : Fin r → G) (L : ℕ) : Prop :=
  ∀ (c c' : Fin r → ℕ), (∀ i, c i ≤ L ∧ c' i ≤ L) → (∑ i, c i • u i = ∑ i, c' i • u i) → c = c'

-- ID: p3_s46_step2
def u_seq (r h : ℕ) (i : Fin r) : Fin (h^2 + 1) → ℤ :=
  fun k => (i.val + 1) ^ k.val

-- ID: p3_s46_step3
theorem u_seq_dissociated_and_bounded (r h : ℕ) :
  is_L_dissociated (u_seq r h) (h^2) ∧ ∀ i k, |(u_seq r h i) k| ≤ r ^ h^2 := by sorry

-- ID: p3_s999_step1
def G_gadget (m h r : ℕ) (u : Fin r → ℕ) : Set ℕ := {0} ∪ ⋃ i, {u i, m * u i}

-- ID: p3_s999_step2
theorem G_gadget_card (m h r : ℕ) (hm : 3 ≤ m ∧ m ≤ h) (u : Fin r → ℕ) (h_inj : ...) : (G_gadget m h r u).ncard = 2 * r + 1 := by sorry

-- ID: p4_s10_step1
theorem lemma_3_3_congruence (m h r : ℕ) (hm : 3 ≤ m ∧ m ≤ h) (F G : PowerSeries ℚ) :
  F ≡ (1 - X^m)^r / (1 - X)^(2*r + 1) * G [PMOD X^(h+1)] := by sorry

-- ID: p4_s10_step2
def P_G (m r : ℕ) : PowerSeries ℚ := (1 - X^m)^r

-- ID: p4_s10_step3
theorem P_G_diff_identity (m r : ℕ) :
  P_G m r - P_G m (r + 1) = X^m * (1 - X^m)^r := by sorry

-- ID: p4_s33_step1
lemma sum_decomposition_unique (q h m : ℕ) (u : Fin r → G) (a b : Fin r → ℕ) (hq : q ≤ h) : 
  (∑ i, a i • u i) + (∑ i, b i • (m • u i)) = ∑ i, (a i + m * b i) • u i := by sorry

-- ID: p4_s33_step2
lemma coeff_decomposition_and_padding (c : Fin r → ℕ) (m : ℕ) : 
  ∃ (A B : Fin r → ℕ), (∀ i, c i = m * B i + A i ∧ A i < m) ∧ 
  (∑ i, (A i + B i)) ≤ q := by sorry

-- ID: p4_s33_step3
theorem generating_function_identity (m r : ℕ) (z : ℝ) (hz : |z| < 1) : 
  (1 / (1 - z)) * (∑ A in Finset.range m, z ^ A) ^ r * (∑' B : ℕ, z ^ B) ^ r = 
  (1 - z ^ m) ^ r / (1 - z) ^ (2 * r + 1) := by sorry

-- ID: p4_s39_step1
variable {h : ℕ} (m r : ℕ) (hm : 2 ≤ m ∧ m ≤ h - 1) (hr : 0 ≤ r)

-- ID: p4_s39_step2
def H (m r : ℕ) : Set α := {x | ∃ i, 1 ≤ i ∧ i ≤ r ∧ (x = u i ∨ x = m • u i)}

-- ID: p4_s39_step3
lemma H_card (hm : 2 ≤ m ∧ m ≤ h - 1) (hr : 0 ≤ r) : (H m r).ncard = 2 * r := by sorry
lemma H_zero (hm : 2 ≤ m ∧ m ≤ h - 1) : H m 0 = ∅ := by sorry

-- ID: p4_s999_step1
lemma main_congruence (m h r : ℕ) (hm : 2 ≤ m ∧ m ≤ h - 1) (hr : 0 ≤ r) : F z ≡ P_H m r z / (1 - z)^(2 * r) [MOD z^(h + 1)] := by sorry

-- ID: p4_s999_step2
def P_H (m r : ℕ) (z : ℝ) : ℝ := ((1 - z^m)^r - z^(m - 1) * (1 - z)^r) / (1 - z^(m - 1))

-- ID: p4_s999_step3
lemma P_H_expansion (m h r : ℕ) (hm : 2 ≤ m ∧ m ≤ h - 1) : P_H m r z ≡ 1 - (r.choose 2) * z^(m + 1) + ∑ ν in Finset.Icc (m + 2) h, O(r^(ν - m + 1)) * z^ν [MOD z^(h + 1)] := by sorry

-- ID: p4_s999_step4
lemma P_H_diff_congruence (m h r : ℕ) (hm : 2 ≤ m ∧ m ≤ h - 1) : P_H m r z - P_H m (r + 1) z ≡ r * z^(m + 1) + ∑ ν in Finset.Icc (m + 2) h, O(r^(ν - m)) * z^ν [MOD z^(h + 1)] := by sorry

-- ID: p5_s44_step1
theorem q_fold_sum_form {H : Type} (q h : ℕ) (hq : q ≤ h) : ∃ (a b : ℕ → ℕ), ∑ i, a i • u i + ∑ i, b i • (m • u i) = ∑ i, (a i + m * b i) • u i := by sorry

-- ID: p5_s44_step2
theorem coeff_decomposition_and_length (c : ℕ → ℕ) (m : ℕ) (d e : ℕ → ℕ) (h_div : ∀ i, c i = m * d i + e i ∧ e i < m) : ∑ i, (a i + b i) = m * (∑ i, d i) + (∑ i, e i) - (m - 1) * ∑ i, b i := by sorry

-- ID: p5_s44_step3
theorem degree_contribution_range (D E m : ℕ) : ∀ k ∈ Finset.range (D + 1), ∃ (b : ℕ → ℕ), (∑ i, b i) = k ∧ degree_contribution = D + E + (m - 1) * k := by sorry

-- ID: p5_s44_step4
theorem generating_function_closed_form (m r : ℕ) : F_Hm_r z = ((1 - z^m)^r - z^(m-1) * (1 - z)^r) / ((1 - z)^(2*r) * (1 - z^(m-1))) := by sorry

-- ID: p5_s44_step5
theorem one_step_difference_asymptotic (m r ν : ℕ) (hν : ν ≥ m + 2) : coeff z^ν (P_Hm_r z - P_Hm_r_plus_1 z) = O (r^(ν - m)) := by sorry

-- ID: p5_s51_step1
def belongs_to_O_h (p : ℕ → ℝ) (X : ℝ) (h : ℕ) : Prop := ∀ q ≤ h, p q =O[𝓝 0] (fun _ => X^q) := by sorry

-- ID: p5_s51_step2
def belongs_to_Theta_h_pos (p : ℕ → ℝ) (X : ℝ) (h : ℕ) : Prop := (∀ q ≤ h, p q ≍ X^q) ∧ (∀ q ≤ h, 0 < p q) := by sorry

-- ID: p5_s51_step3
lemma elementary_dominance_lemma {p : ℕ → ℝ} {X : ℝ} {h : ℕ} : belongs_to_O_h p X h → ... := by sorry

-- ID: p5_s999_step1
variable (α : ℝ) (hα : 0 ≤ α ∧ α < 1) (c : ℝ) (s : ℕ) (E : Fin s → ℝ → ℝ)

-- ID: p5_s999_step2
hypothesis (hE : ∀ i, E i z = 1 + O_h (c^α * z))

-- ID: p5_s999_step3
theorem lemma_4_1 : ∏ i, (1 - z)^(-c) * E i z ∈ Θ_h_plus (c * z) := by sorry

-- ID: p6_s9_step1
theorem general_asymptotic_product (a : ℝ) (d h s c : ℕ) (D : ℂ → ℂ) (E : ℕ → ℂ → ℂ)
  (ha : a > 0) (hd : d ≤ h) :
  (∀ z, D z = a * z^d * (1 + O_term z)) →
  (∏ i in Finset.range s, D z * (1 - z)^(-(c : ℂ)) * E i z) ∈ Θ_set (a * z^d) := by sorry

-- ID: p6_s21_step1
theorem reduce_to_second_statement : ... := by sorry

-- ID: p6_s21_step2
lemma coeff_expansion (q d : ℕ) (hq : q ≥ d) : ... := by sorry

-- ID: p6_s21_step3
lemma asymptotic_analysis : ... := by sorry

-- ID: p6_s21_step4
theorem coeff_positivity_and_order : ... := by sorry

-- ID: p6_s23_step1
section lower_part_of_range

/-- 我们以记录直径的形式引用 Rajagopal 的填充集引理。 -/
lemma rajagopal_filling_set_lemma {α : Type*} [MetricSpace α] (S : Set α) :
  ∃ (d : ℝ), d = Metric.diam S := by sorry

-- ID: p6_s25_step1
variable {d : ℝ} (B : Set ℝ) (hB_sub : B ⊆ Set.Icc 0 d)

-- ID: p6_s25_step2
def h_fold_sumset (h : ℕ) (B : Set ℝ) : Set ℝ := {x | ∃ (f : Fin h → ℝ), (∀ i, f i ∈ B) ∧ x = ∑ i, f i}

-- ID: p6_s25_step3
def is_h_d_filling (h : ℕ) (d : ℝ) (B : Set ℝ) : Prop := h_fold_sumset h B = Set.Icc 0 (h * d)

-- ID: p6_s25_step4
def is_h_d_filling (h : ℕ) (d : ℝ) (B : Set ℝ) (hB_sub : B ⊆ Set.Icc 0 d) : Prop := h_fold_sumset h B = Set.Icc 0 (h * d)

-- ID: p6_s30_step1
variable (h k d : ℕ)
lemma rajagopal_filling_lemma (hh : h ≥ 2) (hk : k ≥ k₀) (hd : (k - 1) * h / (k - 2) ≤ d ∧ d ≤ 4 ^ ((h^2 + h) / 2)) : ∃ (B : Finset ℕ), B ⊆ Finset.Icc 0 d ∧ B.card = k - 1 ∧ Finset.Icc 0 (k / 8) ⊆ B := by sorry

-- ID: p6_s30_step2
def IsFillingSet (h d : ℕ) (B : Finset ℕ) : Prop := sorry
theorem exists_h_d_filling_set (h k d : ℕ) (h_cond : (k - 1) * h / (k - 2) ≤ d ∧ d ≤ 4 ^ ((h^2 + h) / 2)) : ∃ B : Finset ℕ, IsFillingSet h d B ∧ B.card = k - 1 ∧ Finset.Icc 0 (k / 8) ⊆ B := by sorry

-- ID: p6_s37_step1
theorem small_values_polynomial_witnesses (h : ℕ) (hh : h ≥ 2) : ∃ (a C : ℝ), a > 0 ∧ C > 0 ∧ ∀ᶠ k in atTop, ...

-- ID: p6_s37_step2
∀ k : ℕ, k ≥ K₀ → ∀ t : ℕ, t ∈ Set.Icc (M h k) (⌊a * k^h⌋) \ Δ h k → ...

-- ID: p6_s37_step3
∃ A : Finset ℕ, A ⊆ Finset.Icc 0 (⌊C * k^h⌋) ∧ A.card = k ∧ (h_fold_sumset A).card = t := by sorry

-- ID: p6_s999_step1
def D_max (k h : ℕ) : ℕ := Nat.floor ((k - 1) * h / (2 * (h^2 + h)))

-- ID: p6_s999_step2
lemma large_k_inclusion (k h : ℕ) (hk : k ≥ K₀) (B : Set ℕ) : Set.Icc 0 (k/8) ⊆ B → Set.Icc 0 (h^2) ⊆ B := by sorry

-- ID: p6_s999_step3
theorem A_properties (k h d i : ℕ) (B : Set ℕ) (A : Set ℕ) (hA : A = {0} ∪ (i + B)) : Finset.card (A.toFinset) = k ∧ A ⊆ Set.Icc 0 (h + D_max k h) := by sorry

-- ID: p6_s999_step4
theorem hA_structure (h i d : ℕ) (B : Set ℕ) (hB : h • B = Set.Icc 0 (h*d)) (hB_sub : Set.Icc 0 (h^2) ⊆ B) : h • A = {0} ∪ Set.Icc i (h*(i+d)) := by sorry

-- ID: p7_s15_step1
theorem card_hA_calc (i h d : ℕ) (B : Finset ℕ) : (hA : Finset ℕ).card = h * (i + d) - i + 2 := by sorry

-- ID: p7_s15_step2
theorem rewrite_card_hA (h k l i : ℕ) (M_hk : ℕ) : h * (k + l) - i + 2 = M_hk + h * l + (h - i + 1) := by sorry

-- ID: p7_s15_step3
theorem row_coverage_outside_delta (h k l : ℕ) : {n | ∃ i, n = M_hk + h * l + (h - i + 1)} = Set.Icc (M_hk + h * l + max 1 (h - l - 1)) (M_hk + h * l + h) := by sorry

-- ID: p7_s15_step4
theorem diameter_bound_and_coverage (h k : ℕ) : ∃ a_h > 0, ∀ d ≤ D_max, coverage_bound ∧ diameter = O_h (k ^ h) := by sorry

-- ID: p7_s17_step1
section large_part_of_range

/-- 我们现在证明针对 Rajagopal 大值构造的多项式直径替代形式。 -/
theorem rajagopal_large_value_poly_diameter_replacement : True := by sorry

end large_part_of_range

-- ID: p7_s27_step1
variable (h b : ℕ) (hb : b ≥ 3)

-- ID: p7_s27_step2
def s_b (h b : ℕ) : ℕ := (h - 1) * (b - 2) + 1

-- ID: p7_s27_step3
def B (j b h : ℕ) : Finset ℕ := Finset.Icc 0 (b - 2) ∪ {h * (b - 2) + 2 - j}

-- ID: p7_s27_step4
theorem dense_block_card (j b h : ℕ) (hj : 1 ≤ j ∧ j ≤ s_b h b) : (B j b h).card = b := by sorry

-- ID: p7_s999_step1
lemma dense_block_card_diff (h b : ℕ) (hb : b ≥ 3) (η j : ℕ) (hη : 2 ≤ η ∧ η ≤ h) (hj : 2 ≤ j ∧ j ≤ s b) : 0 ≤ |η • B (j - 1) b| - |η • B j b| ∧ |η • B (j - 1) b| - |η • B j b| ≤ h := by sorry

-- ID: p7_s999_step2
lemma dense_block_card_asymptotic (h b : ℕ) (hb : b ≥ 3) (η j : ℕ) (hη : 1 ≤ η ∧ η ≤ h) (hj : 1 ≤ j ∧ j ≤ s b) : |η • B j b| = O_h b := by sorry

-- ID: p7_s999_step3
lemma dense_block_gen_func_base (h : ℕ) : F (B 1 3) z ≡ (1 - z)⁻³ [PMOD z^(h + 1)] := by sorry

-- ID: p7_s999_step4
lemma dense_block_gen_func_rec (h b : ℕ) (hb : b > 3) : F (B 1 b) z ≡ (1 - z)⁻¹ * F (B (s (b - 1)) (b - 1)) z [PMOD z^(h + 1)] := by sorry

-- ID: p8_s31_step1
def alpha : ℝ := 9/10
def beta : ℝ := 4/5
def gamma : ℝ := 7/10
lemma param_constraints : 0 < beta ∧ beta < alpha ∧ alpha < 1 ∧ 2*beta > 1 ∧ 2*beta*gamma > 1 := by sorry

-- ID: p8_s31_step2
variables (k h : ℕ) (b : ℕ) (hb : b ∈ Set.Icc 3 (k - ⌊(k:ℝ)^gamma⌋₊))
def c := k - b
def S := ⌊(c:ℝ)^alpha⌋₊
def T := ⌊(c:ℝ)^beta⌋₊

-- ID: p8_s31_step3
def R (r : ℕ → ℕ) (u : ℕ → ℕ) : ℤ := c - ∑ m in Finset.Icc 3 h, (2 * r m + 1) - ∑ m in Finset.Icc 2 (h-1), 2 * u m
lemma R_nonneg (hk : k ≥ K₀) : R r u ≥ 0 := by sorry

-- ID: p8_s31_step4
def C (r u : ℕ → ℕ) : Finset ℕ := (⋃ m ∈ Finset.Icc 3 h, G m (r m)) ∪ (⋃ m ∈ Finset.Icc 2 (h-1), H m (u m)) ∪ U (R r u)
lemma card_C : (C r u).card = c := by sorry

-- ID: p8_s31_step5
theorem sparse_block_congruence :
  F_C z ≡ (1 / (1 - z)^c) * ∏ m in Finset.Icc 3 h, (1 - z^m)^(r m) * ∏ m in Finset.Icc 2 (h-1), P_H m (u m) z [PMOD z^(h+1)] := by sorry

-- ID: p8_s41_step1
variable (h c : ℕ) (hc : c ≥ c_min)
variable (F : ℕ → PowerSeries ℂ)
variable (Θ_h_plus : Submodule ℂ (PowerSeries ℂ))

-- ID: p8_s41_step2
lemma variation_part_a (μ r : ℕ) (hμ : 3 ≤ μ ∧ μ ≤ h) :
  ∃ δ ∈ (μ / h : ℂ) • C • z^μ • Θ_h_plus, F (r + 1) z = F r z - δ := by sorry

-- ID: p8_s41_step3
lemma variation_part_b (μ u : ℕ) (hμ : 2 ≤ μ ∧ μ ≤ h - 1) :
  ∃ δ ∈ u • z^(μ + 1) • Θ_h_plus_pow_μ, F (u + 1) z = F u z - δ := by sorry

-- ID: p8_s999_step1
lemma truncation_and_factor_bound : ∀ (r u : ℕ), r ≤ c_α → u ≤ c_β → c_β ≤ c_α → remaining_factors = 1 + O(c_α * z) := by sorry

-- ID: p8_s999_step2
lemma case_a_drop_estimation : numerator_drop = z^μ * (1 + O(c_α * z)) → final_drop = z^μ * Θ(c * z) := by sorry

-- ID: p8_s999_step3
lemma case_b_poly_diff : P_H_μ_uμ z - P_H_μ_uμ_plus_1 z = u_μ * z^(μ+1) * (1 + O(c_α * z)) := by sorry

-- ID: p9_s2_step1
lemma rajagopal_interval_lemma {α : Type*} [LinearOrder α] (a b : α) (h : a ≤ b) : IsConnected (Set.Icc a b) := by sorry

-- ID: p9_s16_step1
def is_nonincreasing_on_grid (d : ℕ) (n : Fin d → ℕ) (f : (Fin d → ℕ) → ℤ) : Prop :=
  ∀ (x : Fin d → ℕ) (i : Fin d), x i < n i → f (Function.update x i (x i + 1)) ≤ f x

-- ID: p9_s16_step2
def delta (d : ℕ) (n : Fin d → ℕ) (f : (Fin d → ℕ) → ℤ) (i : Fin d) : ℤ :=
  sSup { f x - f (Function.update x i (x i + 1)) | x : Fin d → ℕ, x i < n i }

-- ID: p9_s16_step3
def Delta (d : ℕ) (n : Fin d → ℕ) (f : (Fin d → ℕ) → ℤ) (i : Fin d) : ℤ :=
  sInf { f (Function.update x i 0) - f (Function.update x i (n i)) | x : Fin d → ℕ }

-- ID: p9_s16_step4
lemma lemma_6_3_image_is_interval (d : ℕ) (n : Fin d → ℕ) (f : (Fin d → ℕ) → ℤ)
  (h_mono : is_nonincreasing_on_grid d n f)
  (h_delta1 : delta d n f 0 ≤ 1)
  (h_rec : ∀ i : Fin d, 0 < i.val → delta d n f i ≤ Delta d n f (Fin.pred i sorry)) :
  ∃ a b : ℤ, Set.range f = Set.Icc a b := by sorry

-- ID: p9_s25_step1
lemma base_interval (x_suffix : Fin (d - 1) → ℤ) : IsInterval (Set.range (λ x₁ => f (x₁ :: x_suffix))) := by sorry

-- ID: p9_s25_step2
lemma ind_hyp (i : ℕ) (x_suffix : Fin (d - i + 1) → ℤ) : IsInterval (image_of_prefix i x_suffix) := by sorry

-- ID: p9_s25_step3
lemma interval_overlap (I_old I_new : Set ℝ) (h_len : measure I_old ≥ Δ_prev) (h_shift : inf I_new ≥ inf I_old - δ_curr) : (I_old ∩ I_new).Nonempty := by sorry

-- ID: p9_s25_step4
theorem main_claim : IsInterval (total_image f) := by sorry

-- ID: p9_s31_step1
def A_jb (j : ℕ) (b : ℝ) : Set α := B b ⊔ C (r j) (u j) 
-- 需补充不交性条件 Disjoint (B b) (C (r j) (u j)) := by sorry

-- ID: p9_s31_step2
def script_A_b (b : ℝ) : Set (Set α) := { S | ∃ j, 1 ≤ j ∧ j ≤ s ∧ S = A_jb j b } := by sorry

-- ID: p9_s35_step1
variables (h k b : ℕ) (hh : h ≥ 3) (hk : k ≥ k₀) (hb : b ∈ Set.Icc 3 (k - Nat.floor (k ^ γ)))

-- ID: p9_s35_step2
def cardinality_set (h b k : ℕ) : Set ℕ := { n | ∃ A ∈ 𝒜 b, n = (h • A).card }

-- ID: p9_s35_step3
theorem lemma_6_4_interval : IsInterval (cardinality_set h b k) := by sorry

-- ID: p9_s999_step1
def var_order (h : ℕ) : List ℕ := sorry
lemma var_count (h : ℕ) : (var_order h).length = 2 * h - 3 := by sorry

-- ID: p9_s999_step2
lemma apply_lemma_6_3 (h : ℕ) (f : ℕ → ℕ) (box : Set ℕ) : ... := by sorry

-- ID: p9_s999_step3
lemma sumset_decomposition (A B C : Finset ℕ) (h : ℕ) (hA : A = B ∪ C) (hBC : Disjoint B C) : Finset.card (h • A) = ∑ η in Finset.range (h + 1), Finset.card (η • C) * Finset.card ((h - η) • B) := by sorry

-- ID: p9_s999_step4
lemma monotonicity_and_delta (h : ℕ) (f : ℕ → ℕ) : Antitone f ∧ δ_1 = 1 := by sorry

-- ID: p10_s43_step1
lemma r_mu_drop_variation_estimate (h μ : ℕ) (c b S : ℝ) (hμ : 3 ≤ μ ∧ μ ≤ h) : δ r_μ ≤ C_h * (c^(h-μ) + b * c^(h-μ-1)) ∧ Δ r_μ ≥ c_h * S * (c^(h-μ) + b * c^(h-μ-1)) := by sorry

-- ID: p10_s43_step2
lemma u_mu_drop_variation_estimate (h μ : ℕ) (c b T : ℝ) (hμ : 2 ≤ μ ∧ μ ≤ h - 1) : δ u_μ ≤ C_h * T * (c^(h-μ-1) + b * c^(h-μ-2)) ∧ Δ u_μ ≥ c_h * T^2 * (c^(h-μ-1) + b * c^(h-μ-2)) := by sorry

-- ID: p10_s43_step3
lemma j_change_estimate (h : ℕ) (c : ℝ) : δ j ≤ C_h * ∑ η in Finset.range (h-1), |η_C| ∧ δ j ≤ C_h * c^(h-2) := by sorry

-- ID: p10_s43_step4
theorem image_f_is_interval (f : ℝ → ℝ) (α β γ : ℝ) (hβ : β < α) (hβγ : 2 * β * γ > 1) (hβ2 : 2 * β > 1) : Set.range f = Set.Icc (f min) (f max) := by sorry

-- ID: p10_s44_step1
section varying_b

variable (b : ℝ)

-- 形式化参数 b 变动时的核心性质占位
theorem varying_b_analysis : ∀ (b : ℝ), True := by sorry

end varying_b

-- ID: p10_s49_step1
variable (h : ℕ) (ε : ℝ) (h_ge : h ≥ 3) (ε_pos : ε > 0)

-- ID: p10_s49_step2
∃ k₀ : ℕ, ∀ k ≥ k₀, ...

-- ID: p10_s49_step3
∀ t : ℤ, ⌈ε * k^h⌉ ≤ t ∧ t ≤ K h k → ...

-- ID: p10_s49_step4
∃ (A : Finset ℤ) (a b : ℤ), A.card = k ∧ (∀ x ∈ A, a ≤ x ∧ x ≤ b) ∧ (b - a + 1 ≤ k ^ (O h 1)) ∧ (Finset.card (h • A) = t) := by sorry

-- ID: p10_s999_step1
def A_union : Set α := ⋃ b ∈ Finset.Icc 3 (k - ⌊k * γ⌋), A_b

-- ID: p10_s999_step2
lemma hA_is_interval (b : ℕ) : IsInterval (hA_b b) := by sorry

-- ID: p10_s999_step3
def sparse_gen_func (b j : ℕ) : PowerSeries ℤ := (1 - X) ^ (-(c + if j = 1 then 0 else 1))

-- ID: p10_s999_step4
lemma gen_func_congruence : F_B_1b * (1 - X)^(-c) ≡ F_B_sb_1 * (1 - X)^(-(c+1)) [PMOD X^(h+1)] := by sorry

-- ID: p11_s29_step1
theorem hA_is_interval : IsInterval (hA) := by sorry

-- ID: p11_s29_step2
theorem cardinality_at_start : Nat.card (hA) = Nat.choose (h + k - 1) h := by sorry

-- ID: p11_s29_step3
theorem cardinality_at_end_asymptotic : |hA| = o (fun k => k^h) := by sorry

-- ID: p11_s29_step4
theorem interval_coverage : Set.Icc (ε * k^h) K_hk ⊆ hA := by sorry

-- ID: p11_s29_step5
theorem diameter_embedding : ∃ (f : Λ → ℤ), Metric.diam (f '' Λ) ≤ k^(O_h 1) ∧ ∀ q ≤ h, Nat.card (q • (f '' A)) = Nat.card (q • A) := by sorry

-- ID: p11_s32_step1
def two_fold_quadratic_argument : Prop := by sorry

-- ID: p11_s32_step2
theorem thm_one_one_endpoint_self_contained : ... := by sorry

-- ID: p11_s32_step3
lemma large_value_construction_exclusion : ... := by sorry

-- ID: p11_s34_step1
theorem prop_7_1 (k : ℕ) (hk : k ≥ 1) : N 2 k ≤ 8 * k^2 + 2 * k + 2 := by sorry

-- ID: p11_s999_step1
def K (n : ℕ) : ℕ := Nat.choose (n + 1) 2
def Delta (n : ℕ) : ℕ := K n - (2 * n - 1)
theorem sumset_size_bounds (A : Finset ℕ) (h : A.card = k) : 2 * k - 1 ≤ (A.sumset A).card ∧ (A.sumset A).card ≤ K k := by sorry

-- ID: p11_s999_step2
theorem construct_m_s (k t : ℕ) (ht : 2 * k - 1 ≤ t ∧ t ≤ K k) : ∃ m s : ℕ, let D := K k - t; D ≤ Delta m ∧ (∀ m' < m, D > Delta m') ∧ s = Delta m - D := by sorry

-- ID: p11_s999_step3
def construct_B (m s : ℕ) : Finset ℕ := 
  if m = 1 then {0} 
  else (Finset.range (m - 1)) ∪ {m - 1 + s}

-- ID: p11_s999_step4
theorem B_properties (m s : ℕ) (hm : m ≥ 2) (hs : s ≤ m - 2) : 
  let B := construct_B m s 
  let L := B.max' (by sorry) 
  L ≤ 2 * m ∧ (B.sumset B).card = K m - (Delta m - s) := by sorry

-- ID: p12_s25_step1
theorem base_case_and_B_sum_size (m s : ℕ) (hm : m ≥ 2) : ... := by sorry

-- ID: p12_s25_step2
theorem handle_small_r (r k m : ℕ) (hr : r ≤ 1) : ... := by sorry

-- ID: p12_s25_step3
theorem sidon_construction_via_quadratic_residues (r : ℕ) (hr : r ≥ 2) : ∃ (p : ℕ) (C : Finset ℕ), ... := by sorry

-- ID: p12_s25_step4
theorem final_set_construction_and_sum_size (B S : Finset ℕ) : ... := by sorry

-- ID: p12_s25_step5
theorem max_element_bound_and_translation (A : Finset ℕ) (k : ℕ) : ... := by sorry

-- ID: p12_s999_step1
theorem main_theorem_base_cases (h : ℕ) (hh : h = 1 ∨ h = 2) : ... := by sorry

-- ID: p12_s999_step2
theorem interval_covering_large_k (h k : ℕ) (hh : h ≥ 3) (hk : k ≥ k₀) : ... := by sorry

-- ID: p12_s999_step3
theorem range_identification (h k : ℕ) (hk : k ≥ k₀) : covered_range h k = R h k := by sorry

-- ID: p12_s999_step4
theorem finite_small_k_and_translation (h : ℕ) : ∃ C_h, ∀ k, bound h k ≤ k ^ C_h := by sorry

-- ID: p12_s999_step5
theorem main_theorem_1_1 : ... := by sorry

-- ID: p13_s999_step1
def K (h k : ℕ) : ℕ := Nat.choose (h + k - 1) h
theorem exists_Bh_set_attaining_max (h k : ℕ) : ∃ (A : Finset ℕ), IsBhSet A ∧ (h • A).card = K h k := by sorry

-- ID: p13_s999_step2
lemma sumset_interval_bound (A : Finset ℕ) (h N : ℕ) (hA : A ⊆ Finset.Icc 1 N) : (h • A).card ≤ h * N - h + 1 := by sorry

-- ID: p13_s999_step3
theorem lower_bound_N_hk (h k : ℕ) : ∃ C > 0, N h k ≥ C * k ^ h := by sorry

-- ID: p13_s999_step4
remark qualitative_order_match : True := by sorry

-- ID: p13_s999_step5
-- References are metadata and typically omitted in Lean formalization.
#check "I. Rajagopal, Possible Sizes of Sumsets, arXiv:2510.23022, 2025."