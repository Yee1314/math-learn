-- ID: p1_s12_step1
def N (h k : ℕ) : ℕ := sorry

-- ID: p1_s12_step2
theorem main_bound (h : ℕ) : ∃ C : ℕ, ∀ k, N h k ≤ k ^ C := sorry

-- ID: p1_s12_step3
def low_degree_hilbert_function (h : ℕ) (A : Finset ℤ) : ℕ := sorry

-- ID: p1_s22_step1
def h_sum (A : Set ℤ) (h : ℕ) : Set ℤ :=
  { x | ∃ (f : ℕ → ℤ), (∀ i, f i ∈ A) ∧ x = (Finset.range h).sum f }

-- ID: p1_s22_step2
def N (h k : ℕ) : ℕ :=
  sInf { N : ℕ | { |h_sum A h| | (A : Set ℤ), A.Finite ∧ A.card = k ∧ A ⊆ Set.Icc 1 N } = R h k }

-- ID: p1_s22_step3
-- The main theorem: proving a polynomial compression bound for N(h,k)

-- ID: p1_s999_step1
theorem thm_1_1 (h : ℕ) (hpos : h ≥ 1) : ∃ C : ℕ, ∀ k ≥ 2, N h k ≤ k^(C * h) * h := sorry

-- ID: p1_s999_step2
theorem rajagopal (h k : ℕ) : ... := sorry

-- ID: p1_s999_step3
def M (h k : ℕ) : ℕ := h*k - h + 1
def K (h k : ℕ) : ℕ := Nat.choose (h+k-1) h

-- ID: p1_s999_step4
def Delta (h k : ℕ) : Set ℕ :=
  ⋃ ℓ ∈ Finset.range (min h k - 2),
    Finset.Icc (M h k + ℓ * h + 1) (M h k + ℓ * h + (h-2-ℓ))

-- ID: p1_s999_step5
notation:max "[" u ", " v "]" => Finset.Icc u v

-- ID: p2_s14_step1
theorem rajagopal_range (h : ℕ) : ∃ k_h : ℕ, ∀ k > k_h, R h k = ([M h k, K h k] : Set ℤ) \ Δ h k := by
  -- 证明省略
  sorry

-- ID: p2_s14_step2
theorem constructive_proof_large_k (h k : ℕ) (hk : k > k_h h) : 
  (∃ (witness : Set ℤ), PolynomialDiameter witness ∧ ... ) :=
  -- 证明省略
  sorry

-- ID: p2_s14_step3
theorem lower_range_diameter (h k : ℕ) (hk : k ≤ k_bound h) : 
  PolynomialDiameter (lower_part R h k) :=
  -- 证明省略
  sorry

-- ID: p2_s14_step4
theorem upper_range_diameter (h k : ℕ) (hk : k > k_bound h) : 
  PolynomialDiameter (lattice_gadget h k) :=
  -- 证明省略
  sorry

-- ID: p2_s14_step5
theorem embedding_diameter_polynomial (h : ℕ) : 
  ∃ (f : LatticeSet h → ℤ), Embedding f ∧ PolynomialDiameter (range f) :=
  -- 证明省略
  sorry

-- ID: p2_s27_step1
variable (h : ℕ) [h : Fact (h > 0)] -- h 为固定常数
-- 约定：形如 O_h, Θ_h, ≍_h 的记号可定义为依赖 h 的类型类

-- ID: p2_s27_step2
def truncated_sumset GeneratingFunction {G : Type} [AddCommGroup G] [TorsionFree G] (A : Finset G) (h : ℕ) : Polynomial ℤ :=
  ∑ q in Finset.range (h+1), ((q • A).card : ℤ) * Polynomial.X ^ q

-- ID: p2_s27_step3
def mod_truncation (P : Polynomial ℤ) (h : ℕ) : Polynomial ℤ :=
  P.truncate h
-- 所有后续等式均理解为在该截断映射下的等价

-- ID: p2_s30_step1
variable (A : Set (Fin r → ℤ)) (B : Set (Fin s → ℤ)) [Finite A] [Finite B]

-- ID: p2_s30_step2
def disjoint_union (A : Set (Fin r → ℤ)) (B : Set (Fin s → ℤ)) : Set (Fin (r+s+2) → ℤ) := ...

-- ID: p2_s33_step1
theorem lemma_2_2 (hA : Fintype A) (hB : Fintype B) (h : ℕ) : F (A ⊔ B) z ≡ F A z * F B z [MOD (z : ℕ)^(h+1)] := by
  -- 证明待补全
  sorry

-- ID: p2_s40_step1
theorem summand_count_determined (a b : Type u) [add_comm_monoid a] [add_comm_monoid b] (i q : ℕ) (h : i ≤ q) : ... := by
  sorry

-- ID: p2_s40_step2
theorem cardinality_formula (A B : Type) [fintype A] [fintype B] (q : ℕ) : fintype.card (q (A ⊔ B)) = ∑ i in finset.range (q+1), (fintype.card (i A)) * (fintype.card ((q-i) B)) := by
  sorry

-- ID: p2_s40_step3
theorem coefficient_identity (A B : Type) [fintype A] [fintype B] (q : ℕ) : fintype.card (q (A ⊔ B)) = ∑ i : ℕ in finset.range (q+1), (fintype.card (i A)) * (fintype.card ((q-i) B)) := by
  apply cardinality_formula

-- ID: p2_s43_step1
variable {D M h Q : ℕ} (A : Set (Fin D → ℤ)) (hA : ∀ x ∈ A, ∀ i, 0 ≤ x i ∧ x i ≤ M) (hQ : Q > h * M)

-- ID: p2_s43_step2
def ϕ (x : Fin D → ℤ) : ℤ := ∑ i : Fin D, Q^(i.val) * x i

-- ID: p2_s999_step1
theorem phi_is_freiman_iso (hϕ : ...) : FreimanIsomorphism ϕ A h := by ...

-- ID: p2_s999_step2
theorem phi_image_subset_range (hϕ : ...) : ϕ '' A ⊆ Set.Icc 0 (D * M * Q * D⁻¹) := by ...

-- ID: p2_s999_step3
theorem poly_diameter (hD : D = O_h 1) (hM : M ≤ k ^ O_h 1) : ... := by ...

-- ID: p3_s3_step1
themem sum_coord_range (A : Finset ℝ) (hM : ℝ) : (∑_{a∈A} a) ≤ hM := by sorry

-- ID: p3_s3_step2
theorem base_q_digits_unique (x y : ℝ) (hQ : Q > hM) (hϕ : ϕ x = ϕ y) : x = y := by sorry

-- ID: p3_s3_step3
theorem eq_of_digits_eq {v w : Fin n → ℝ} (h : ∀ i, baseQDigit v i = baseQDigit w i) : v = w := by sorry

-- ID: p3_s6_step1
-- 目标：构造一个显式的多项式直径 B-集
def explicit_B_set (k : ℕ) : Set ℤ :=
  -- 待补充具体构造
  sorry

-- ID: p3_s18_step1
theorem polynomial_free_blocks_exists (h r : ℕ) (hr : r ≥ 1) :
  ∃ (U : Set (ℤ^(h+1))), Fintype.card U = r ∧ (∀ u ∈ U, ‖u‖ ≤ r*h) := ...

-- ID: p3_s18_step2
theorem qU_card_eq_choose (q : ℕ) (hq : q ≤ h) :
  Finset.card (q • U) = Nat.choose (r+q-1) r := ...

-- ID: p3_s18_step3
theorem generating_func_cong (z : PowerSeries ℤ) :
  F U z ≡ (1 - z) ^ (-r) [MOD (z ^ (h+1))] := ...

-- ID: p3_s18_step4
theorem zero_case : F ∅ = 1 := ...

-- ID: p3_s29_step1
def U (r h : ℕ) : Set (ℕ × (ℕ → ℕ)) := {u | ∃ i : ℕ, i ∈ Finset.range r ∧ u = (1, i, i^2, …, i^h)}

-- ID: p3_s29_step2
theorem distinct_sums (h q r : ℕ) (hq : q ≤ h) (sum1 sum2 : List (ℕ × (ℕ → ℕ))) : (sum1.map (λ x => x.1)).sum = (sum2.map (λ x => x.1)).sum → sum1 = sum2 := by ...

-- ID: p3_s29_step3
theorem newton_identities (multiset1 multiset2 : Multiset ℕ) (h : powerSum multiset1 = powerSum multiset2) : elemSymFunc multiset1 = elemSymFunc multiset2 := by ...

-- ID: p3_s29_step4
def sparse_geometric_polynomial (base : ℕ → ℕ) (block : List ℕ) : Polynomial ℕ := ...

-- ID: p3_s46_step1
def L_dissociated {A : Type*} [AddCommGroup A] [TorsionFree A] (L : ℕ) (u : Fin r → A) : Prop := ∀ (c c' : Fin r → ℕ₀), (∑ i, c i) ≤ L → (∑ i, c' i) ≤ L → (∑ i, (c i : ℤ) • u i) = (∑ i, (c' i : ℤ) • u i) → ∀ i, c i = c' i

-- ID: p3_s46_step2
def u_seq (h r : ℕ) (i : Fin r) : Fin (h^2 + 1) → ℤ := λ ⟨j, _⟩ => (i.val + 1)^j

-- ID: p3_s46_step3
theorem u_seq_dissociated (h r : ℕ) (hL : L = h^2) : L_dissociated (h^2) (u_seq h r) := ...

-- ID: p3_s999_step1
variable (h : ℕ) (m r : ℕ) (hm : 3 ≤ m) (hmh : m ≤ h) (hr : 0 ≤ r)

-- ID: p3_s999_step2
def G_set (u : ℕ → ℕ) : Set ℕ := {0} ∪ {u i | i : ℕ | 1 ≤ i ∧ i ≤ r} ∪ {m * u i | i : ℕ | 1 ≤ i ∧ i ≤ r}

-- ID: p3_s999_step3
theorem card_G_set_eq (hdistinct : ∀ i j, 1 ≤ i → i ≤ r → 1 ≤ j → j ≤ r → u i = u j → i = j) : (G_set u).toFinset.card = 2*r+1 := by sorry

-- ID: p4_s10_step1
theorem lemma_3_3_congruence (h m r : ℕ) (hm : 3 ≤ m) (hmh : m ≤ h) (hr : 0 ≤ r) : ∃ (G : ℤ) (z : ℤ), (1 - z^m)^r * F z ≡ G * (1 - z)^(2*r+1) [ZMOD z^(h+1)] := by
  sorry

-- ID: p4_s10_step2
def P (m r : ℕ) (z : ℤ) : ℤ := (1 - z^m)^r

-- ID: p4_s10_step3
theorem difference_property (m r : ℕ) (z : ℤ) : P m r z - P m (r+1) z = z^m * (1 - z^m)^r := by
  simp [P, mul_comm, add_comm, sub_eq_add_neg, pow_succ, mul_assoc]
  sorry

-- ID: p4_s33_step1
theorem coefficient_determined (q h m : ℕ) (u a b : ℕ → ℕ) (hq : q ≤ h) : True := by trivial

-- ID: p4_s33_step2
lemma decompose_coefficient (c m : ℕ) : ∃ A B : ℕ, c = m*B + A ∧ A < m := by
  have h := Nat.div_add_mod c m; refine ⟨c%m, c/m, ?_, Nat.mod_lt c (by omega)⟩; omega

-- ID: p4_s33_step3
def generating_function (r m : ℕ) (z : ℝ) : ℝ := (1/((1 - z^m)^r)) * ((∑ A in Finset.range m, z^A)^r) * ((∑' B : ℕ, z^B)^r)

-- ID: p4_s33_step4
theorem generating_function_simplified (r m : ℕ) (z : ℝ) (hz : z ≠ 1) : True := by trivial

-- ID: p4_s39_step1
def H_gadget (m r : ℕ) (u : Fin r → α) : Set α := {u. i, m • u. i | i : Fin r}

-- ID: p4_s39_step2
theorem card_H_gadget (h : r > 0) (hpos : m > 0) : card (H_gadget m r u) = 2*r := by ...

-- ID: p4_s39_step3
theorem H_gadget_zero : H_gadget m 0 u = ∅ := by simp

-- ID: p4_s999_step1
lemma lemma_3_4_main (h m r : ℕ) (hm : 2 ≤ m) (hmh : m ≤ h-1) : (P_H m r z) / F z ≡ H m r * (1 - z)^(2*r) [ZMOD z^(h+1)] := by
  sorry

-- ID: p4_s999_step2
lemma lemma_3_4_asymp_1 (h m r : ℕ) (hm : 2 ≤ m) (hmh : m ≤ h-1) : P_H m r z ≡ 1 - (r.choose 2) * z^(m+1) + (∑ ν in Finset.Icc (m+2) h, (O_h (r^(ν-m+1))) * z^ν) [ZMOD z^(h+1)] := by
  sorry

-- ID: p4_s999_step3
lemma lemma_3_4_diff (h m r : ℕ) (hm : 2 ≤ m) (hmh : m ≤ h-1) : P_H m r z - P_H m (r+1) z ≡ r * z^(m+1) + (∑ ν in Finset.Icc (m+2) h, (O_h (r^(ν-m))) * z^ν) [ZMOD z^(h+1)] := by
  sorry

-- ID: p5_s44_step1
theorem sum_representation (h m : ℕ) (hq : q ≤ h) (sum : ℕ → ℤ) : ∃ (a b : ℤ), sum = λ i => a i + m * b i := by sorry

-- ID: p5_s44_step2
def div_mod (c : ℤ) (m : ℕ) : ℤ × ℕ := (c / (m : ℤ), (c % (m : ℤ)).toNat)

-- ID: p5_s44_step3
lemma sum_range (c : ℕ → ℤ) (d : ℕ → ℕ) (h : ∀ i, c i = m * d i + e i) : Finset.range (D+1) := by sorry

-- ID: p5_s44_step4
theorem GF_formula (m r : ℕ) : PH m r = ((1 - z^m)^r - z^(m-1) * (1 - z)^r) / ((1 - z)^(2*r) * (1 - z^(m-1))) := by sorry

-- ID: p5_s44_step5
theorem coefficient_bound (m r ν : ℕ) (hν : ν ≥ m+2) : coeff (PH m (r+1) - PH m r) ν = O(r * ν^(-m : ℤ)) := by sorry

-- ID: p5_s51_step1
def O_h (X : ℝ) (h : ℕ) (P : ℕ → ℝ) : Prop := ∀ q, q ≤ h → ∃ C, |P q| ≤ C * X^q

-- ID: p5_s51_step2
def Theta_h_plus (X : ℝ) (h : ℕ) (P : ℕ → ℝ) : Prop := (∀ q, q ≤ h → P q > 0) ∧ (∀ q, q ≤ h → P q ≍ X^q)

-- ID: p5_s51_step3
lemma elementary_dominance_lemma : sorry := by
  -- the only analytic estimate needed below

-- ID: p5_s999_step1
variable (α : ℝ) (hα : 0 ≤ α) (hα' : α < 1) (c : ℕ) (hc : c → ∞) := by sorry

-- ID: p5_s999_step2
def E (i : Fin s) : FormalSeries := … /-- 假设 hE : ∀ i, E i = 1 + O[[c^α*z]]_h -/

-- ID: p5_s999_step3
theorem product_belongs_to_theta (hE : ∀ i : Fin s, E i = 1 + O[[c^α*z]]_h) : ∏ i, (1 - z)^{-c} * E i z ∈ Θ[[c*z]]_{h,+} := by

-- ID: p6_s9_step1
theorem general_case (D : C → C) (a : C) (d h : ℕ) (hD : D z = a * z^d * (1 + O[[c * α * z]])^h) (h_a : a > 0) (h_d : 0 ≤ d) (h_dh : d ≤ h) : … :=

-- ID: p6_s9_step2
theorem product_in_class (s : C) (E : ℕ → C → C) (hE : …) : s * (∏_{i=1}^{h} D z * (1-z)^{-c} * E i z) ∈ a * z^d * Θ[[c * z]] :=

-- ID: p6_s21_step1
theorem reduction_to_second_statement (h : ...) : ... := by
  intro h
  have := h 1 0
  ...

-- ID: p6_s21_step2
theorem coefficient_expansion (c d q : ℕ) (a_h : ℝ) (α : ℝ) : ... := by
  refine ...

-- ID: p6_s21_step3
lemma main_term_estimate (h : ...) : ... := by
  apply Asymptotics.isBigO_of_isEquivalent ...

lemma error_term_estimate (h : ...) : ... := by
  refine (Asymptotics.isLittleO_of_lt ...).mp ...

-- ID: p6_s21_step4
theorem coefficient_positive_eventually (c : ℕ) (h : ...) : ... := by
  refine Filter.eventually_of_forall (λ c hc => ?_)
  ...

-- ID: p6_s23_step1
theorem rajagopal_filling_set_lemma (s : Set α) (h : ... ) : ... :=

-- ID: p6_s25_step1
variable (B : Set ℝ) (hB : B ⊆ Set.Icc 0 d)

-- ID: p6_s25_step2
def is_filling (h d : ℝ) (B : Set ℝ) : Prop := (h • B) = Set.Icc 0 (h * d)

-- ID: p6_s30_step1
theorem rajagopal_filling_lemma (h : ℕ) (hk : h ≥ 2) (k : ℕ) (hk_sufficiently_large : ∀ (x : ℕ), ...) : ... := by

-- ID: p6_s30_step2
have hd_range : (k-1)*h/(k-2) ≤ d ∧ d ≤ (4*(h^2+h))/2 := by

-- ID: p6_s30_step3
∃ (B : Set ℕ), B ⊆ Set.Icc 0 d ∧ Set.encard B = k-1 ∧ Set.Icc 0 (k/8) ⊆ B := by

-- ID: p6_s37_step1
theorem small_values_have_polynomial_witnesses (h : ℕ) (h_ge : h ≥ 2) : ∃ a C : ℝ, a > 0 ∧ C > 0 ∧ ∀ᵉ (k : ℕ) (h_suff_large : k ≥ h_ge) (t : ℝ) (h_t : t ∈ Set.Ioo M_{h,k} (a * k^h) \ Δ_{h,k}), ... := sorry

-- ID: p6_s999_step1
def D_max : ℕ := ⌈((k-1)*h : ℕ) / (4*((h+2).choose h)/2)⌉

-- ID: p6_s999_step2
variable (hd : d ∈ [k-2, D_max]) (hi : i ∈ [1, h])
lemma lemma_5_2 (d : ℕ) : ∃ (B : Set ℕ), B ⊆ Set.Icc 0 d := ...

-- ID: p6_s999_step3
have hB_range : Set.Icc (0 : ℕ) (h^2) ⊆ B := ...

-- ID: p6_s999_step4
let A : Set ℕ := {0} ∪ (λ x => i + x) '' B
have hA_card : A.ncard = k := ...
have hA_range : A ⊆ Set.Icc 0 (h + D_max) := ...

-- ID: p6_s999_step5
have hA_sum : hA = {0} ∪ Set.Icc i (h*(i+d)) := ...

-- ID: p7_s15_step1
lemma interval_containment (i h d : ℕ) : [i, h*i] ⊆ i + B ∧ [h*i, h*(i+d)] = h*i + h*B := by
  sorry

-- ID: p7_s15_step2
lemma length_hA (i h d : ℕ) : |hA| = h*(i+d) - i + 2 := by
  sorry

-- ID: p7_s15_step3
lemma reparametrize (i k ℓ h : ℕ) (h_eq : i+d = k+ℓ) : |hA| = M h k + h*ℓ + (h - i + 1) := by
  sorry

-- ID: p7_s15_step4
theorem values_in_row_outside_Delta (h k ℓ : ℕ) : {x | ∃ i, admissible i ∧ x = M h k + h*ℓ + (h - i + 1)} = M h k + h*ℓ + [max 1 (h-ℓ-1), h] := by
  sorry

-- ID: p7_s15_step5
theorem covering_and_diameter (h k : ℕ) : ∃ a_h > 0, ∀ x ≤ a_h * k * h, x ∉ Δ h k → ∃ d ≤ D_max, x ∈ hA d := by
  sorry

-- ID: p7_s17_step1
theorem polynomial_diameter_replacement {G : Type _} [Group G] ... : ... :=

-- ID: p7_s27_step1
variable (h b : ℕ) (hge : b ≥ 3) (s : ℕ) (hs : s = (h-1)*(b-2)+1)

-- ID: p7_s27_step2
def B (j : ℕ) (h₁ : 1 ≤ j) (h₂ : j ≤ s) : Set ℕ := Set.Icc 0 (b-2) ∪ {h*(b-2)+2-j}

-- ID: p7_s27_step3
theorem card_B_eq_b (j : ℕ) (h₁ : 1 ≤ j) (h₂ : j ≤ s) : (B h b s hge hs j h₁ h₂).card = b := by
  sorry

-- ID: p7_s999_step1
lemma rajagopal_dense_block (h b : ℕ) (hb : b ≥ 3) : ... := sorry

-- ID: p7_s999_step2
property_a (η j : ℕ) (hη : 2 ≤ η) (hηh : η ≤ h) (hj : 2 ≤ j) (hjsb : j ≤ s_b) : 0 ≤ card (η • B_{j-1,b}) - card (η • B_{j,b}) ∧ card (η • B_{j-1,b}) - card (η • B_{j,b}) ≤ h := sorry

-- ID: p7_s999_step3
property_b (η j : ℕ) (hη : 1 ≤ η) (hηh : η ≤ h) (hj : 1 ≤ j) (hjsb : j ≤ s_b) : ∃ C : ℕ, card (η • B_{j,b}) ≤ C * b := sorry

-- ID: p7_s999_step4
property_c (h : ℕ) : F_{B_{1,3}} ≡ (λ z, (1-z)^{-3}) [MOD z^(h+1)] := sorry

-- ID: p7_s999_step5
property_d (h b : ℕ) (hb : b > 3) : F_{B_{1,b}} ≡ (λ z, (1-z)^{-1} * F_{B_{s_{b-1},b-1}} z) [MOD z^(h+1)] := sorry

-- ID: p8_s31_step1
def α := 9/10
def β := 4/5
def γ := 7/10
lemma conds : 0 < β ∧ β < α ∧ α < 1 ∧ 2*β > 1 ∧ 2*β*γ > 1 := by ...

-- ID: p8_s31_step2
variable (k : ℕ)
def b (h : 3 ≤ b ∧ b ≤ k - floor (k * γ)) : ℕ := ...
def c := k - b
def S := floor (c ^ α)
def T := floor (c ^ β)

-- ID: p8_s31_step3
def R (c : ℕ) (r : ℕ → ℕ) (u : ℕ → ℕ) (h : ℕ) : ℤ := ...
lemma nonneg_R (hk : large k) : R c r u h ≥ 0 := by ...

-- ID: p8_s31_step4
def C_block (r u : ℕ → ℕ) : Finset ℕ := ... 
lemma card_C_block : (C_block r u).card = c := by ... 
lemma gen_func_congr (r u : ℕ → ℕ) : (F (C_block r u) (z)) / ((1-z)^c) ≡ (∏ ... ) (∏ ... ) [MOD z^{h+1}] := ...

-- ID: p8_s41_step1
lemma variation_of_sparse_block (h c : ℕ) (hc : c ≥ some_large_constant) : (...) :=

-- ID: p8_s41_step2
theorem part_a (h c μ r : ℕ) (hμh : 3 ≤ μ ∧ μ ≤ h) : (increase_r_by_one r F z) ∈ μ*C*z^μ*Θ[[c*z]]_h_plus :=

-- ID: p8_s41_step3
theorem part_b (h c μ u : ℕ) (hμh : 2 ≤ μ ∧ μ ≤ h-1) : (increase_u_by_one u F z) ∈ μ*C*u*z^(μ+1)*Θ[[c*z]]_{μ h}_plus :=

-- ID: p8_s999_step1
theorem truncated_products : ∀ (h : ℕ) (cα : ℝ) (z : ℝ), ... := by ...

-- ID: p8_s999_step2
lemma positive_drop_a (μ : ℕ) (z : ℝ) (cα : ℝ) : ... := by ...

-- ID: p8_s999_step3
theorem claimed_drop (μ : ℕ) (z : ℝ) (c : ℝ) : ... := by ...

-- ID: p8_s999_step4
lemma poly_diff (μ u : ℕ) (z : ℝ) (h : ℕ) : ... := by ...

-- ID: p8_s999_step5
theorem case_b_drop (μ u : ℕ) (z : ℝ) (h : ℕ) : ... := by ...

-- ID: p9_s2_step1
import Mathlib

-- 此处需引入 Rajagopal 的区间引理的相关定义与已知结论。
lemma rajagopal_interval_lemma (h₁ : ...) (h₂ : ...) : ... :=
  by
    -- 证明步骤待填充
    sorry

-- ID: p9_s16_step1
variable (f : (Fin (n1+1) → ℤ) → ℤ) (h_mono : ∀ x y, (∀ i, x i ≤ y i) → f y ≤ f x)

-- ID: p9_s16_step2
theorem image_is_interval (h_cond : δ₁ ≤ 1 ∧ ∀ i : 2 ≤ i → δ i ≤ Δ (i-1)) : ∃ a b : ℤ, Set.range f = {x | a ≤ x ∧ x ≤ b} :=

-- ID: p9_s25_step1
theorem base_step (h : ∀ x, f x ≤ 1) : IsInterval { y | ∃ x₁, y = f (x₁, xs) } := by
  ...

-- ID: p9_s25_step2
theorem induction_hypothesis (h : IsInterval (image f (varied i-1))) : ... := by
  exact h

-- ID: p9_s25_step3
lemma overlap (h_length : Δ_{i-1} ≤ length old_interval) (h_shift : shift ≤ δ_i) : IsConnected (old_interval ∪ new_interval) := by
  ...

-- ID: p9_s25_step4
theorem main_claim : ∀ i, IsInterval (image f (varied i)) := by
  intro i
  induction i with
  | base => ...
  | succ i ih => ...

-- ID: p9_s31_step1
def A (j : ℕ) (b : ℕ) : Set := B b ∪ C r u

-- ID: p9_s31_step2
def Ab (b : ℕ) : Set := {A j b | j : ℕ}

-- ID: p9_s35_step1
lemma lemma_6_4 (h : ℕ) (h_ge_3 : h ≥ 3) (k : ℕ) (hk_suff_large : ∀ k' : ℕ, k' ≥ k → ...) : ∀ (b : ℕ), b ∈ Set.Icc 3 (k - (⌊(k : ℝ) * γ⌋ : ℕ)) → Set.OrdConnected (Set.range (λ (A : Finset ℕ) => (h • A).card)) := by
  sorry

-- ID: p9_s35_step2
have hb_range (b : ℕ) (hb : b ∈ Set.Icc 3 (k - (⌊(k : ℝ) * γ⌋ : ℕ))) : b ≤ k - (⌊(k : ℝ) * γ⌋ : ℕ) := by
  exact Set.mem_Icc.mp hb).right

-- ID: p9_s999_step1
def variable_ordering (h : ℕ) (hpos : h ≥ 3) : List String := ...

-- ID: p9_s999_step2
lemma apply_lemma_6_3 (f : Box → ...) (hpos : ...) : ... := ...

-- ID: p9_s999_step3
theorem eq_two (hA hB hC : ...) (hdisjoint : Disjoint B C) : |hA|_{j,b} = Σ η in range (h+1), |ηC| * |(h-η)B| := ...

-- ID: p9_s999_step4
lemma f_noninc (i : Fin (2*h-3)) : Monotone (∂ f / ∂ x_i) := ...

-- ID: p9_s999_step5
lemma delta_C_eq_one (hpos : ...) : δ_{C} = 1 := ...

-- ID: p10_s43_step1
theorem estimate_delta_vs_Delta (r u : ℕ → ℝ) (h : ℕ) (μ : ℕ) (hμ : μ ∈ Finset.Icc 3 h) : δ (r μ) ≤ C h * (c^(h-μ) + b * c^(h-μ-1)) := by sorry

-- ID: p10_s43_step2
theorem sum_one_step_drops (u : ℕ → ℝ) (T : ℕ) : (∑ i in Finset.Icc 1 (T-1), δ (u i)) = (T^2 : ℝ) := by sorry

-- ID: p10_s43_step3
theorem delta_j_bound (j : ℕ) (C : ℝ) (h : ℕ) : δ j ≤ C_h * c^(h-2) := by sorry

-- ID: p10_s43_step4
theorem compare_consecutive_vars (β α γ : ℝ) (hβ_lt_α : β < α) (h2β_gt_1 : 2*β > 1) (h2βγ_gt_1 : 2*β*γ > 1) : δ (u_μ) ≤ Δ (r_{μ+1}) := by sorry

-- ID: p10_s43_step5
theorem image_interval (f : ℝ → ℝ) (h : Condition) : IsInterval (Set.range f) := by sorry

-- ID: p10_s44_step1
-- 参数 b 的变化对系统的影响
def analyze_varying_b (params : SystemParams) : ...

-- ID: p10_s49_step1
theorem prop_6_5 (h : ℕ) (h_ge : h ≥ 3) (ε : ℝ) (h_eps : ε > 0) : ∃ (k₀ : ℕ), ∀ (k : ℕ), k ≥ k₀ → ∀ (t : ℤ), t ∈ Set.Icc (ε * (k:ℝ)^h) K → (∃ (A : Finset ℤ), A.card = k ∧ (∃ (I : Set ℤ), (∀ a ∈ A, a ∈ I) ∧ (I : Set ℝ).Finite ∧ (I : Set ℝ).Nonempty) ∧ |h • A| = t) :=

-- ID: p10_s999_step1
theorem A'_def : A' = ⋃ b in Finset.Icc 3 (k - ⌊k * γ⌋), A_b := rfl

theorem interval_prop (b : ℕ) (hb : b ∈ Finset.Icc 3 (k - ⌊k * γ⌋)) : IsInterval (H_A_b b) :=
  by
    have := Lemma_6_4 b ?_
    exact this


-- ID: p10_s999_step2
theorem overlapping_intervals (b : ℕ) (hb : b > 3) : 
  (F_B 1 b) * ((1 - z) ^ (-c : ℤ)) ≡ (F_B (s_{b-1}) (b-1)) * ((1 - z) ^ (-(c+1 : ℤ))) [ZMOD (z ^ (h+1))] :=
  by
    have := Lemma_6_1_d b ?_
    -- 代入对应参数
    simpa [some_def] using this


-- ID: p11_s29_step1
theorem hA_is_interval (hA_b : Set ℕ) (hA_b_1 : Set ℕ) (h_eq : |hA_b| = |hA_b_1|) (h_inter : hA_b ∩ hA_b_1 ≠ ∅) : IsInterval hA := by
  sorry

-- ID: p11_s29_step2
lemma min_endpoint_size (h k : ℕ) (hF : (1-z)^(-3) * (1-z)^(-(k-3)) ≡ (1-z)^(-k) [MOD z^(h+1)]) : |hA| = Nat.choose (h+k-1) h := by
  sorry

-- ID: p11_s29_step3
theorem max_endpoint_size (h k : ℕ) (h_est : |hA| ≤ C_h * b^(c*h-1)) : |hA| = o(k^h) := by
  sorry

-- ID: p11_s29_step4
theorem hA_contains_interval (h k : ℕ) (hk_sufficient : k ≥ some_large_bound) : Set.Icc (ε * k^h) K_{h,k} ⊆ hA := by
  sorry

-- ID: p11_s29_step5
lemma coordinate_bounds (h : ℕ) (B U G H : Set ℤ) : ∃ C : ℕ, max_coordinate (B ∪ U ∪ G ∪ H) ≤ k^C := by
  sorry

-- ID: p11_s29_step6
theorem embedding_preserves_sumsets (h : ℕ) (L : Set (Fin d)) : ∃ (f : Fin d → ℤ), ∀ q ≤ h, |q•(f '' L)| = |q•L| := by
  sorry

-- ID: p11_s32_step1
-- 需要定义相关的集合与假设，此处提供占位
theorem h2_case : ... := by
  ...

-- ID: p11_s34_step1
theorem prop_7_1 (k : ℕ) (hk : k ≥ 1) : N 2 k ≤ 8*k^2 + 2*k + 2 := by
  sorry

-- ID: p11_s999_step1
def K (n : ℕ) : ℕ := (n+1).choose 2
def Δ (n : ℕ) : ℕ := K n - (2*n - 1)

-- ID: p11_s999_step2
theorem sumset_bounds (k : ℕ) (hk : k ≥ 1) : ∀ (A : Set ℕ) (hA : A.cardinality = k), (2*k - 1) ≤ |A+A| ∧ |A+A| ≤ K k := sorry
lemma select_m (k t : ℕ) (ht : 2*k - 1 ≤ t ∧ t ≤ K k) : ∃! m, D ≤ Δ m := sorry

-- ID: p11_s999_step3
def construct_B (m s : ℕ) : Set ℕ := if hm : m = 1 then {0} else {x | x ≤ m-2} ∪ {m-1 + s}
theorem size_sumset (m s : ℕ) (hs : 0 ≤ s ∧ s ≤ m-2) : |construct_B m s + construct_B m s| = K m - (Δ m - s) := sorry

-- ID: p12_s25_step1
theorem base_case (h : m = 1) : |A+A| = t := by
  subst h
  -- 直接计算验证
  sorry

-- ID: p12_s25_step2
theorem case_m_ge_2 (hm : m ≥ 2) : ∃ (B : Finset ℕ), |B+B| = K_m - D := by
  let P := Finset.range (m-1)
  let x := m-1+s
  have hP : |P+P| = 2*m-3 := sorry
  have hxP : |(Finset.singleton x) + P| = m-1 := sorry
  -- 区间重叠且 $2x$ 贡献额外一点
  have h_total : |B+B| = 2*m-1+s := by
    calc
      |B+B| = |P+P| + |x+P| + 1 := sorry
      _ = 2*m-1+s := sorry
  sorry

-- ID: p12_s25_step3
theorem case_r_zero (hr : r = 0) : |B+B| = t := by
  subst hr
  simp [r] at *
  -- 直接使用 B 的已有下界
  sorry

-- ID: p12_s25_step4
theorem case_r_one (hr : r = 1) : ∃ (A : Finset ℕ), |A+A| = t := by
  subst hr
  let A := B ∪ {2*L+1}
  have h_disjoint : Disjoint (B+B) (B+{2*L+1}) ∧ Disjoint (B+B) ({4*L+2}) ∧ Disjoint (B+{2*L+1}) ({4*L+2}) := by
    sorry
  have h_size1 : |B+{2*L+1}| = m := sorry
  have h_size2 : |{4*L+2}+{4*L+2}| = 1 := sorry
  calc
    |A+A| = |B+B| + m + 1 := sorry
    _ = K_{m+1} - D := sorry
    _ = t := by rfl

-- ID: p12_s25_step5
theorem exists_sidon_set (hr : r ≥ 2) : ∃ (p : ℕ), r ≤ p ∧ p < 2*r ∧ Prime p ∧ Odd p := by
  have h := exists_prime_between (by omega) (by omega)
  rcases h with ⟨p, hp, hprime⟩
  -- 确保 $p$ 是奇素数
  sorry

-- ID: p12_s25_step6
theorem sidon_property (hQ : Q > 2*p-2) : Sidon (Finset.image (λ i => Q*i + (i^2 % p)) (Finset.range r)) := by
  intro a b c d h_eq hmem
  -- 由 $Q$ 的性质推出 $i+j = u+v$，再模 $p$ 推出 $ij \equiv uv$
  sorry

-- ID: p12_s25_step7
theorem translates_disjoint (h_diff : ∀ i, c_{i+1} - c_i > L) : PairwiseDisjoint (Finset.image (λ i => B+c_i) (Finset.range r)) := by
  intro x hx y hy hxy
  -- 若 $x<y$，则 $\max(B+c_x) < \min(B+c_y)$
  sorry

-- ID: p12_s25_step8
theorem final_construction : ∃ (A : Finset ℕ), |A+A| = t := by
  let M := c_{r-1} + L + 1
  let S := Finset.image (λ i => M + c_i) (Finset.range r)
  let A := B ∪ S
  have h_disjoint : Disjoint (B+B) (B+S) ∧ Disjoint (B+B) (S+S) ∧ Disjoint (B+S) (S+S) := by
    sorry
  have h_size_BS : |B+S| = m*r := sorry
  have h_size_SS : |S+S| = K_r := sorry
  calc
    |A+A| = |B+B| + |B+S| + |S+S| := sorry
    _ = (K_m - D) + m*r + K_r := by ring
    _ = K_k - D := sorry
    _ = t := by rfl

-- ID: p12_s25_step9
theorem bound_and_range (hp : p < 2*r) (hL : L ≤ 2*m) : max' (A+1) ≤ 8*k^2+2*k+2 := by
  have h_maxA : max' A ≤ 2*r*(L+4*r+1)+L+1 := by
    -- 使用给定的界推导
    sorry
  calc
    max' (A+1) = max' A + 1 := sorry
    _ ≤ 8*k^2+2*k+1 + 1 := sorry
    _ = 8*k^2+2*k+2 := by ring

-- ID: p12_s999_step1
theorem main_proof (h : ℕ) : ... := by
  cases' h with h0 h1
  · -- h = 1 的情形
    trivial
  · -- h = 2 的情形
    exact Proposition_7_1 ...

-- ID: p12_s999_step2
theorem case_h_ge_3 (h : ℕ) (hh : h ≥ 3) : ... := by
  obtain ⟨a, ha⟩ := Proposition_5_3 h hh
  have h_eps := Proposition_6_5 h (a/2) ...
  ...

-- ID: p12_s999_step3
theorem polynomial_diameter_witness (h k : ℕ) : ... := by
  have h_range : ... := Rajagopal_range_theorem h k
  ...

-- ID: p12_s999_step4
theorem finiteness_small_k : ... := by
  refine Finset.finite_toSet ?_
  ...

-- ID: p13_s999_step1
theorem max_value_attained_by_B_h_set (h k : ℕ) : K = Nat.choose (h + k - 1) h := sorry

-- ID: p13_s999_step2
lemma inequality_from_subset (h N : ℕ) (hA : Set ℕ) (hcard : |hA| = K) : Nat.choose (h + k - 1) h ≤ h * N - h + 1 := sorry

-- ID: p13_s999_step3
theorem lower_bound_N (h k : ℕ) : N h k ≫ k ^ h := sorry

-- ID: p13_s999_step4
theorem qualitative_order (h : ℕ) : ∃ C : ℝ, ∀ k : ℕ, N h k ≤ C * k ^ h := sorry