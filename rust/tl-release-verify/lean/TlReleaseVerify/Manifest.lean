/-!
Model of `parse_manifest` (duplicate and path checks) and `verify`/`Report::all_ok`
(src/lib.rs). Paths are `Nat` identifiers after `safe_path`; digests are `Nat`; the
SHA-256 of a file is an abstract function supplied by the caller (collision
resistance is assumed, not proved).
-/
namespace TlReleaseVerify

structure Entry where
  path : Nat
  digest : Nat
deriving DecidableEq, Repr

/-- Accept entries in order, refusing an unsafe path or a repeated path. -/
def accept (safe : Nat → Bool) : List Entry → List Nat → Option (List Entry)
  | [], _ => some []
  | e :: es, seen =>
    if !safe e.path then none
    else if e.path ∈ seen then none
    else (e :: ·) <$> accept safe es (e.path :: seen)

theorem accept_spec (safe : Nat → Bool) (es : List Entry) (seen : List Nat) (out : List Entry)
    (h : accept safe es seen = some out) :
    out = es ∧ (∀ e ∈ es, safe e.path = true ∧ e.path ∉ seen) ∧ (es.map (·.path)).Nodup := by
  induction es generalizing seen out with
  | nil => simp [accept] at h; subst h; simp
  | cons e es ih =>
    simp only [accept] at h
    split at h
    · simp at h
    · rename_i hs
      split at h
      · simp at h
      · rename_i hn
        cases hr : accept safe es (e.path :: seen) with
        | none => simp [hr] at h
        | some r =>
          simp only [hr, Option.map_eq_map, Option.map_some, Option.some.injEq] at h
          subst h
          obtain ⟨h1, h2, h3⟩ := ih (e.path :: seen) r hr
          subst h1
          refine ⟨rfl, ?_, ?_⟩
          · intro x hx
            simp only [List.mem_cons] at hx
            rcases hx with rfl | hx
            · exact ⟨by simpa using hs, hn⟩
            · have := h2 x hx
              exact ⟨this.1, fun m => this.2 (List.mem_cons_of_mem _ m)⟩
          · simp only [List.map_cons, List.nodup_cons]
            refine ⟨?_, h3⟩
            intro hm
            obtain ⟨x, hx, hxp⟩ := List.mem_map.mp hm
            exact (h2 x hx).2 (hxp ▸ List.mem_cons_self)

def parse (safe : Nat → Bool) (es : List Entry) : Option (List Entry) :=
  if es = [] then none else accept safe es []

/-- An accepted manifest has only safe paths and never lists a path twice. -/
theorem parse_sound (safe : Nat → Bool) (es out : List Entry) (h : parse safe es = some out) :
    out = es ∧ out ≠ [] ∧ (∀ e ∈ out, safe e.path = true) ∧ (out.map (·.path)).Nodup := by
  unfold parse at h
  split at h
  · simp at h
  · rename_i hne
    obtain ⟨h1, h2, h3⟩ := accept_spec safe es [] out h
    subst h1
    exact ⟨rfl, hne, fun e he => (h2 e he).1, h3⟩

inductive Outcome where
  | ok
  | missing
  | mismatch (actual : Nat)
deriving DecidableEq, Repr

def check (present : Nat → Option Nat) (e : Entry) : Outcome :=
  match present e.path with
  | none => .missing
  | some d => if d = e.digest then .ok else .mismatch d

/-- `Report::all_ok`: every listed file checks out and every present file is listed. -/
def allOk (es : List Entry) (present : Nat → Option Nat) (presentPaths : List Nat) : Bool :=
  es.all (fun e => check present e == .ok) && presentPaths.all (fun p => es.any (·.path == p))

/-- Soundness: if verification passes, every listed artifact is present with exactly the
listed digest, and nothing unlisted was shipped alongside. -/
theorem allOk_sound (es : List Entry) (present : Nat → Option Nat) (pp : List Nat)
    (h : allOk es present pp = true) :
    (∀ e ∈ es, present e.path = some e.digest) ∧ ∀ p ∈ pp, ∃ e ∈ es, e.path = p := by
  simp only [allOk, Bool.and_eq_true, List.all_eq_true, List.any_eq_true, beq_iff_eq] at h
  refine ⟨fun e he => ?_, h.2⟩
  have := h.1 e he
  unfold check at this
  split at this
  · simp at this
  · rename_i d hd
    split at this
    · rename_i heq; rw [hd, heq]
    · simp at this

/-- A tampered artifact (digest differs) is always reported, never accepted. -/
theorem tamper_detected (es : List Entry) (present : Nat → Option Nat) (pp : List Nat) (e : Entry)
    (he : e ∈ es) (d : Nat) (hp : present e.path = some d) (hne : d ≠ e.digest) :
    allOk es present pp = false := by
  cases h : allOk es present pp with
  | false => rfl
  | true =>
    have := (allOk_sound es present pp h).1 e he
    rw [hp] at this
    exact absurd (Option.some.inj this) hne

-- Vectors from tests/verify.rs `verify_reports_missing_mismatch_and_unlisted`
-- (a=1 ok, b=2 tampered, c=3 missing, extra=4 unlisted).
def es0 : List Entry := [⟨1, 10⟩, ⟨2, 20⟩, ⟨3, 30⟩]
def pres0 : Nat → Option Nat := fun p => if p = 1 then some 10 else if p = 2 then some 99
  else if p = 4 then some 40 else none
example : es0.map (check pres0) = [.ok, .mismatch 99, .missing] := by decide
example : allOk es0 pres0 [1, 2, 4] = false := by decide
def pres1 : Nat → Option Nat := fun p => if p = 1 then some 10 else if p = 2 then some 20
  else if p = 3 then some 30 else none
example : allOk es0 pres1 [1, 2, 3] = true := by decide
-- Duplicate path refused (`malformed_manifests_are_refused`).
example : parse (fun _ => true) [⟨1, 10⟩, ⟨1, 10⟩] = none := by decide
example : parse (fun _ => true) [] = none := by decide

end TlReleaseVerify
