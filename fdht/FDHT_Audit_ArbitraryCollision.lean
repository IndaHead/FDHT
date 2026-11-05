
namespace FDHT.Audit.ArbitraryCollision

universe u v w x

variable {Address : Type u}
variable {CompressedAddress : Type v}

variable (compress : Address → CompressedAddress)

def ExactOriginalDecoder
    (decode : CompressedAddress → Option Address) : Prop :=
  ∀ addr, decode (compress addr) = some addr

theorem collision_blocks_exact_decoder
    {a b : Address}
    (hCollision : compress a = compress b)
    (hDistinct : a ≠ b) :
    ¬ ∃ decode : CompressedAddress → Option Address,
        ExactOriginalDecoder compress decode := by
  rintro ⟨decode, hExact⟩

  have ha :
      decode (compress a) = some a :=
    hExact a

  have hb :
      decode (compress b) = some b :=
    hExact b

  have hab : some a = some b := by
    calc
      some a = decode (compress a) := ha.symm
      _ = decode (compress b) := by rw [hCollision]
      _ = some b := hb

  have : a = b := by
    exact Option.some.inj hab

  exact hDistinct this

theorem exact_decoder_implies_injective
    (hExact :
      ∃ decode : CompressedAddress → Option Address,
        ExactOriginalDecoder compress decode) :
    Function.Injective compress := by
  rintro a b hab

  rcases hExact with ⟨decode, hDecode⟩

  have ha := hDecode a
  have hb := hDecode b

  have : some a = some b := by
    calc
      some a = decode (compress a) := ha.symm
      _ = decode (compress b) := by rw [hab]
      _ = some b := hb

  exact Option.some.inj this

theorem noninjective_compression_blocks_exact_decoder
    (hNonInjective : ¬ Function.Injective compress) :
    ¬ ∃ decode : CompressedAddress → Option Address,
        ExactOriginalDecoder compress decode := by
  intro hDecoder
  exact hNonInjective
    (exact_decoder_implies_injective compress hDecoder)

variable {Store : Type w}
variable {Location : Type x}

def ResolutionInvariant
    (resolve : Address → Store → Location) : Prop :=
  ∀ a b,
    compress a = compress b →
    ∀ store,
      resolve a store = resolve b store

/--
Exact resolution through compression: resolve factors through compress.
-/
def ExactResolutionThroughCompression
    (resolve : Address → Store → Location) : Prop :=
  ∃ resolveCompressed : CompressedAddress → Store → Location,
    ∀ a store,
      resolve a store = resolveCompressed (compress a) store

theorem exact_resolution_implies_invariant
    (resolve : Address → Store → Location)
    (hExact : ExactResolutionThroughCompression compress resolve) :
    ResolutionInvariant compress resolve := by
  rcases hExact with ⟨resolveCompressed, hFactor⟩
  intro a b hCompress store
  calc
    resolve a store
        = resolveCompressed (compress a) store := hFactor a store
    _ = resolveCompressed (compress b) store := by rw [hCompress]
    _ = resolve b store := (hFactor b store).symm

/--
Classical converse.
-/
theorem invariant_implies_exact_resolution
    [Nonempty Location]
    (resolve : Address → Store → Location)
    (hInvariant : ResolutionInvariant compress resolve) :
    ExactResolutionThroughCompression compress resolve := by
  classical
  let resolveCompressed : CompressedAddress → Store → Location :=
    fun c store =>
      if h : ∃ a, compress a = c then
        resolve (Classical.choose h) store
      else
        Classical.choice inferInstance
  refine ⟨resolveCompressed, ?_⟩
  intro a store
  have hExists : ∃ x, compress x = compress a := ⟨a, rfl⟩
  unfold resolveCompressed
  rw [dif_pos hExists]
  have hChoose : compress (Classical.choose hExists) = compress a :=
    Classical.choose_spec hExists
  exact (hInvariant (Classical.choose hExists) a hChoose store).symm

structure FibreAddress where
  value : CompressedAddress
  representatives : List Address
  nonempty : representatives ≠ []
  sound :
    ∀ a ∈ representatives,
      compress a = value

structure ReachableCompressedAddress where
  compressed : CompressedAddress
  representative : Address
  valid : compress representative = compressed

def resolveReachable
    (resolve : Address → Store → Location)
    (addr : ReachableCompressedAddress compress)
    (store : Store) : Location :=
  resolve addr.representative store

def toReachable (a : Address) :
    ReachableCompressedAddress compress :=
  {
    compressed := compress a
    representative := a
    valid := rfl
  }

theorem resolveReachable_well_defined
    (resolve : Address → Store → Location)
    (hInv : ResolutionInvariant compress resolve)
    (x y : ReachableCompressedAddress compress)
    (hCompressed : x.compressed = y.compressed)
    (store : Store) :
    resolveReachable compress resolve x store =
    resolveReachable compress resolve y store := by
  apply hInv x.representative y.representative
  calc
    compress x.representative = x.compressed := x.valid
    _ = y.compressed := hCompressed
    _ = compress y.representative := y.valid.symm

theorem resolve_toReachable
    (resolve : Address → Store → Location)
    (a : Address)
    (store : Store) :
    resolveReachable compress resolve (toReachable compress a) store =
    resolve a store := by
  rfl

def ResolutionEquivalent
    (resolve : Address → Store → Location)
    (a b : Address) : Prop :=
  ∀ store, resolve a store = resolve b store

def Reflexive {α : Type u} (r : α → α → Prop) : Prop :=
  ∀ a, r a a

def Symmetric {α : Type u} (r : α → α → Prop) : Prop :=
  ∀ a b, r a b → r b a

def Transitive {α : Type u} (r : α → α → Prop) : Prop :=
  ∀ a b c, r a b → r b c → r a c

theorem resolutionEquivalent_refl
    (resolve : Address → Store → Location) :
    Reflexive (ResolutionEquivalent resolve) := by
  intro a store
  rfl

theorem resolutionEquivalent_symm
    (resolve : Address → Store → Location) :
    Symmetric (ResolutionEquivalent resolve) := by
  intro a b hab store
  exact (hab store).symm

theorem resolutionEquivalent_trans
    (resolve : Address → Store → Location) :
    Transitive (ResolutionEquivalent resolve) := by
  intro a b c hab hbc store
  exact (hab store).trans (hbc store)

def ResolutionSetoid
    (resolve : Address → Store → Location) : Setoid Address where
  r := ResolutionEquivalent resolve
  iseqv :=
  {
    refl := resolutionEquivalent_refl resolve
    symm := fun {a b} h => resolutionEquivalent_symm resolve a b h
    trans := fun {a b c} hab hbc => resolutionEquivalent_trans resolve a b c hab hbc
  }

def MinimalBoundary (resolve : Address → Store → Location) :=
  Quotient (ResolutionSetoid resolve)

def toMinimalBoundary
    (resolve : Address → Store → Location)
    (a : Address) : MinimalBoundary resolve :=
  Quotient.mk (ResolutionSetoid resolve) a

def resolveMinimal
    (resolve : Address → Store → Location)
    (q : MinimalBoundary resolve)
    (store : Store) : Location :=
  Quotient.lift
    (fun a => resolve a store)
    (by
      intro a b hab
      exact hab store)
    q

theorem compression_refines_minimal
    (resolve : Address → Store → Location)
    (compress : Address → CompressedAddress)
    (hInv :
      ∀ a b,
        compress a = compress b →
        ResolutionEquivalent resolve a b) :
    ∀ a b,
      compress a = compress b →
      toMinimalBoundary resolve a =
        toMinimalBoundary resolve b := by
  intro a b hab
  exact Quotient.sound (s := ResolutionSetoid resolve) (hInv a b hab)

theorem compress_eq_implies_resolutionEquivalent
    (resolve : Address → Store → Location)
    (compress : Address → CompressedAddress)
    (hInv : ResolutionInvariant compress resolve)
    (a b : Address) :
    compress a = compress b →
    ResolutionEquivalent resolve a b := by
  intro hCompress store
  exact hInv a b hCompress store

#check ResolutionSetoid
#check MinimalBoundary
#check toMinimalBoundary
#check resolveMinimal
#check compression_refines_minimal
structure ReachableMinimalBoundary
    (resolve : Address → Store → Location) where
  boundary : MinimalBoundary resolve
  representative : Address
  valid :
    toMinimalBoundary resolve representative = boundary

def toReachableMinimal
    (resolve : Address → Store → Location)
    (a : Address) :
    ReachableMinimalBoundary resolve :=
  {
    boundary := toMinimalBoundary resolve a
    representative := a
    valid := rfl
  }

def resolveReachableMinimal
    (resolve : Address → Store → Location)
    (x : ReachableMinimalBoundary resolve)
    (store : Store) : Location :=
  resolve x.representative store

#check ReachableMinimalBoundary
#check toReachableMinimal
theorem resolve_toReachableMinimal
    (resolve : Address → Store → Location)
    (a : Address)
    (store : Store) :
    resolveReachableMinimal resolve
      (toReachableMinimal resolve a) store =
    resolve a store := by
  rfl

#check resolveReachableMinimal
theorem resolveReachableMinimal_well_defined
    (resolve : Address → Store → Location)
    (x y : ReachableMinimalBoundary resolve)
    (hBoundary : x.boundary = y.boundary)
    (store : Store) :
    resolveReachableMinimal resolve x store =
    resolveReachableMinimal resolve y store := by
  have hEquiv : ResolutionEquivalent resolve x.representative y.representative := by
    have hX : toMinimalBoundary resolve x.representative = x.boundary := x.valid
    have hY : toMinimalBoundary resolve y.representative = y.boundary := y.valid
    have hSame : toMinimalBoundary resolve x.representative =
                 toMinimalBoundary resolve y.representative := by
      rw [hX, hY, hBoundary]
    exact Quotient.exact hSame
  exact hEquiv store

#check resolve_toReachableMinimal

structure Context (Address : Type u) where
  toAddress : Address
  plug : Address → Address

def compose {Address : Type u}
    (ctx₁ ctx₂ : Context Address) :
    Context Address :=
  { toAddress := ctx₁.toAddress
    plug := ctx₁.plug }

def ContextEquivalent
    (resolve : Address → Store → Location)
    (a b : Address) : Prop :=
  ∀ ctx : Context Address,
  ∀ store,
    resolve (ctx.plug a) store =
    resolve (ctx.plug b) store

theorem composed_minimal_boundary_depends_on_components
    {Address : Type u}
    (resolve : Address → Store → Location)
    (ctx₁ ctx₂ : Context Address) :
    toMinimalBoundary resolve
        (compose ctx₁ ctx₂).toAddress =
    toMinimalBoundary resolve ctx₁.toAddress := by
  rfl

#check Context
noncomputable def identityContext [Nonempty Address] : Context Address :=
  { toAddress := Classical.choice inferInstance
    plug := id }

theorem contextEquivalent_implies_resolutionEquivalent [Nonempty Address]
    (resolve : Address → Store → Location)
    (a b : Address)
    (h : ContextEquivalent resolve a b) :
    ResolutionEquivalent resolve a b := by
  intro store
  exact h identityContext store

#check ContextEquivalent
#check compose
#check identityContext









theorem not_contextEquivalent_iff
    (resolve : Address → Store → Location)
    (a b : Address) :
    ¬ ContextEquivalent resolve a b ↔
    ∃ (ctx : Context Address) (store : Store),
      resolve (ctx.plug a) store ≠
      resolve (ctx.plug b) store := by
  unfold ContextEquivalent
  constructor
  · intro h
    obtain ⟨ctx, hCtx⟩ := Classical.not_forall.mp h
    obtain ⟨store, hStore⟩ := Classical.not_forall.mp hCtx
    exact ⟨ctx, store, hStore⟩
  · intro ⟨ctx, store, h⟩
    intro hEquiv
    exact h (hEquiv ctx store)

#check not_contextEquivalent_iff

end FDHT.Audit.ArbitraryCollision

namespace FutureContextCountermodel

inductive Address where
  | left
  | right
  | exposedLeft
  | exposedRight
  deriving DecidableEq, Repr

inductive Store where
  | unit
  deriving DecidableEq, Repr

inductive Location where
  | shared
  | leftResult
  | rightResult
  deriving DecidableEq, Repr

def resolve : Address → Store → Location
  | .left, _         => .shared
  | .right, _        => .shared
  | .exposedLeft, _  => .leftResult
  | .exposedRight, _ => .rightResult

structure Context where
  plug : Address → Address

def identityContext : Context where
  plug := id

def exposingContext : Context where
  plug
    | .left  => .exposedLeft
    | .right => .exposedRight
    | a      => a

def ResolutionEquivalent (a b : Address) : Prop :=
  ∀ store, resolve a store = resolve b store

def ContextEquivalent (a b : Address) : Prop :=
  ∀ ctx : Context,
  ∀ store,
    resolve (ctx.plug a) store =
    resolve (ctx.plug b) store

theorem left_right_resolutionEquivalent :
    ResolutionEquivalent Address.left Address.right := by
  intro store
  rfl

theorem left_right_not_contextEquivalent :
    ¬ ContextEquivalent .left .right := by
  intro h
  have :=
    h exposingContext Store.unit
  simp [exposingContext, resolve] at this


#check left_right_resolutionEquivalent
theorem exposingContext_distinguishes :
    resolve (exposingContext.plug .left) .unit ≠
    resolve (exposingContext.plug .right) .unit := by
  simp [exposingContext, resolve]


#check left_right_not_contextEquivalent
theorem observational_equivalence_not_future_safe :
    ResolutionEquivalent .left .right ∧
    ¬ ContextEquivalent .left .right := by
  constructor
  · exact left_right_resolutionEquivalent
  · exact left_right_not_contextEquivalent

#check exposingContext_distinguishes
#check observational_equivalence_not_future_safe

end FutureContextCountermodel

namespace KernelExprContext

inductive KernelExpr where
  | hole | left | right | exposedLeft | exposedRight
  deriving DecidableEq, Repr

structure KernelExprContext where
  plug : KernelExpr → KernelExpr

def KernelExprContext.compose
    (ctx₁ ctx₂ : KernelExprContext) : KernelExprContext where
  plug := fun e => ctx₁.plug (ctx₂.plug e)

theorem compose_plug
    (ctx₁ ctx₂ : KernelExprContext)
    (e : KernelExpr) :
    (ctx₁.compose ctx₂).plug e =
    ctx₁.plug (ctx₂.plug e) := by
  rfl

def identityContext : KernelExprContext where
  plug := id

def exposingContext : KernelExprContext where
  plug
    | .left  => .exposedLeft
    | .right => .exposedRight
    | e      => e

def PersistentEquivalent
    (resolve : KernelExpr → Store → Location)
    (e₁ e₂ : KernelExpr) : Prop :=
  ∀ ctx : KernelExprContext,
  ∀ store,
    resolve (ctx.plug e₁) store =
    resolve (ctx.plug e₂) store

theorem persistentEquivalent_refl
    (resolve : KernelExpr → Store → Location)
    (e : KernelExpr) :
    PersistentEquivalent resolve e e := by
  intro ctx store
  rfl

theorem persistentEquivalent_symm
    (resolve : KernelExpr → Store → Location)
    {e₁ e₂ : KernelExpr}
    (h : PersistentEquivalent resolve e₁ e₂) :
    PersistentEquivalent resolve e₂ e₁ := by
  intro ctx store
  exact (h ctx store).symm

theorem persistentEquivalent_trans
    (resolve : KernelExpr → Store → Location)
    {e₁ e₂ e₃ : KernelExpr}
    (h₁₂ : PersistentEquivalent resolve e₁ e₂)
    (h₂₃ : PersistentEquivalent resolve e₂ e₃) :
    PersistentEquivalent resolve e₁ e₃ := by
  intro ctx store
  exact (h₁₂ ctx store).trans (h₂₃ ctx store)

theorem persistentEquivalent_context_closed
    (resolve : KernelExpr → Store → Location)
    {e₁ e₂ : KernelExpr}
    (h : PersistentEquivalent resolve e₁ e₂)
    (outer : KernelExprContext) :
    PersistentEquivalent resolve
      (outer.plug e₁)
      (outer.plug e₂) := by
  intro future store

  have hh :=
    h (future.compose outer) store

  simpa [compose_plug] using hh

def PersistentSetoid
    (resolve : KernelExpr → Store → Location) :
    Setoid KernelExpr where
  r := PersistentEquivalent resolve
  iseqv := ⟨
    persistentEquivalent_refl resolve,
    persistentEquivalent_symm resolve,
    persistentEquivalent_trans resolve
  ⟩

#check PersistentSetoid


def PersistentBoundary
    (resolve : KernelExpr → Store → Location) :=
  Quotient (PersistentSetoid resolve)

#check PersistentBoundary


def toPersistentBoundary
    (resolve : KernelExpr → Store → Location)
    (e : KernelExpr) :
    PersistentBoundary resolve :=
  Quotient.mk _ e

#check toPersistentBoundary


def plugPersistent
    (resolve : KernelExpr → Store → Location)
    (ctx : KernelExprContext)
    (q : PersistentBoundary resolve) :
    PersistentBoundary resolve :=
  Quotient.lift
    (fun e =>
      toPersistentBoundary resolve (ctx.plug e))
    (by
      intro e₁ e₂ h
      exact Quotient.sound
        (persistentEquivalent_context_closed
          resolve h ctx))
    q

#check plugPersistent


theorem plugPersistent_mk
    (resolve : KernelExpr → Store → Location)
    (ctx : KernelExprContext)
    (e : KernelExpr) :
    plugPersistent resolve ctx
      (toPersistentBoundary resolve e) =
    toPersistentBoundary resolve (ctx.plug e) := by
  rfl

#check plugPersistent_mk


theorem plugPersistent_identity
    (resolve : KernelExpr → Store → Location)
    (q : PersistentBoundary resolve) :
    plugPersistent resolve identityContext q = q := by
  induction q using Quotient.ind with
  | _ e =>
    rfl

#check plugPersistent_identity


theorem plugPersistent_compose
    (resolve : KernelExpr → Store → Location)
    (ctx₁ ctx₂ : KernelExprContext)
    (q : PersistentBoundary resolve) :
    plugPersistent resolve (ctx₁.compose ctx₂) q =
    plugPersistent resolve ctx₁
      (plugPersistent resolve ctx₂ q) := by
  induction q using Quotient.ind with
  | _ e =>
    rfl


#check plugPersistent_compose




def hole : KernelExprContext :=
  identityContext


theorem plugPersistent_hole
    (resolve : KernelExpr → Store → Location)
    (q : PersistentBoundary resolve) :
    plugPersistent resolve hole q = q := by
  exact plugPersistent_identity resolve q

#check plugPersistent_hole


def evolvePersistent
    (resolve : KernelExpr → Store → Location)
    (ctxs : List KernelExprContext)
    (q : PersistentBoundary resolve) :
    PersistentBoundary resolve :=
  ctxs.foldr
    (fun ctx acc => plugPersistent resolve ctx acc)
    q

#check evolvePersistent


def composeAll
    (ctxs : List KernelExprContext) :
    KernelExprContext :=
  ctxs.foldr KernelExprContext.compose hole

theorem evolvePersistent_composeAll
    (resolve : KernelExpr → Store → Location)
    (ctxs : List KernelExprContext)
    (q : PersistentBoundary resolve) :
    evolvePersistent resolve ctxs q =
    plugPersistent resolve (composeAll ctxs) q := by
  induction ctxs generalizing q with
  | nil =>
    simp only [evolvePersistent, composeAll, List.foldr]
    exact (plugPersistent_hole resolve q).symm
  | cons ctx rest ih =>
    simp only [evolvePersistent, composeAll, List.foldr]
    conv =>
      lhs
      rw [← evolvePersistent]
    rw [ih]
    exact (plugPersistent_compose resolve ctx (composeAll rest) q).symm

#check evolvePersistent_composeAll


theorem evolvePersistent_append
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (q : PersistentBoundary resolve) :
    evolvePersistent resolve (xs ++ ys) q =
    evolvePersistent resolve xs
      (evolvePersistent resolve ys q) := by
  induction xs generalizing q with
  | nil =>
    simp only [evolvePersistent, List.nil_append, List.foldr]
  | cons x rest ih =>
    simp only [evolvePersistent, List.cons_append, List.foldr]
    conv =>
      lhs
      rw [← evolvePersistent]
    rw [ih]
    rfl

#check evolvePersistent_append


def TrajectoryEquivalent
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) : Prop :=
  ∀ q : PersistentBoundary resolve,
    evolvePersistent resolve xs q =
    evolvePersistent resolve ys q

#check TrajectoryEquivalent


theorem TrajectoryEquivalent_iff_composeAll
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) :
    TrajectoryEquivalent resolve xs ys ↔
    ∀ q : PersistentBoundary resolve,
      plugPersistent resolve (composeAll xs) q =
      plugPersistent resolve (composeAll ys) q := by
  constructor
  · intro h q
    rw [← evolvePersistent_composeAll]
    rw [← evolvePersistent_composeAll]
    exact h q
  · intro h q
    rw [evolvePersistent_composeAll]
    rw [evolvePersistent_composeAll]
    exact h q

#check TrajectoryEquivalent_iff_composeAll


theorem TrajectoryEquivalent_refl
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    TrajectoryEquivalent resolve xs xs := by
  intro q
  rfl

theorem TrajectoryEquivalent_symm
    (resolve : KernelExpr → Store → Location)
    {xs ys : List KernelExprContext}
    (h : TrajectoryEquivalent resolve xs ys) :
    TrajectoryEquivalent resolve ys xs := by
  intro q
  exact (h q).symm

theorem TrajectoryEquivalent_trans
    (resolve : KernelExpr → Store → Location)
    {xs ys zs : List KernelExprContext}
    (hxy : TrajectoryEquivalent resolve xs ys)
    (hyz : TrajectoryEquivalent resolve ys zs) :
    TrajectoryEquivalent resolve xs zs := by
  intro q
  exact (hxy q).trans (hyz q)

def trajectorySetoid
    (resolve : KernelExpr → Store → Location) :
    Setoid (List KernelExprContext) where
  r := TrajectoryEquivalent resolve
  iseqv :=
  {
    refl := TrajectoryEquivalent_refl resolve
    symm := TrajectoryEquivalent_symm resolve
    trans := TrajectoryEquivalent_trans resolve
  }

abbrev TrajectoryBoundary
    (resolve : KernelExpr → Store → Location) :=
  Quotient (trajectorySetoid resolve)

def toTrajectoryBoundary
    (resolve : KernelExpr → Store → Location)
    (ctxs : List KernelExprContext) :
    TrajectoryBoundary resolve :=
  Quotient.mk (trajectorySetoid resolve) ctxs

#check TrajectoryBoundary
#check toTrajectoryBoundary


theorem evolvePersistent_respects_trajectory
    (resolve : KernelExpr → Store → Location)
    {xs ys : List KernelExprContext}
    (h : TrajectoryEquivalent resolve xs ys)
    (q : PersistentBoundary resolve) :
    evolvePersistent resolve xs q =
    evolvePersistent resolve ys q :=
  h q

def actTrajectory
    (resolve : KernelExpr → Store → Location)
    (t : TrajectoryBoundary resolve)
    (q : PersistentBoundary resolve) :
    PersistentBoundary resolve :=
  Quotient.liftOn
    t
    (fun ctxs => evolvePersistent resolve ctxs q)
    (fun _ _ h => evolvePersistent_respects_trajectory resolve h q)

#check actTrajectory


theorem actTrajectory_mk
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext)
    (q : PersistentBoundary resolve) :
    actTrajectory resolve
      (toTrajectoryBoundary resolve xs) q
    =
    evolvePersistent resolve xs q := by
  rfl

#check actTrajectory_mk


/-! ============================================================
    Trajectory composition
============================================================ -/

def composeTrajectory
    (resolve : KernelExpr → Store → Location)
    (tx ty : TrajectoryBoundary resolve) :
    TrajectoryBoundary resolve :=
  Quotient.liftOn₂ tx ty
    (fun xs ys =>
      toTrajectoryBoundary resolve (xs ++ ys))
    (by
      intro xs ys xs' ys' hxs hys
      apply Quotient.sound
      intro q
      rw [evolvePersistent_append, evolvePersistent_append]
      -- evolve xs (evolve ys q) = evolve xs' (evolve ys' q)
      rw [hys q]
      -- evolve xs (evolve ys' q) = evolve xs' (evolve ys' q)
      rw [hxs (evolvePersistent resolve ys' q)])

#check composeTrajectory

theorem composeTrajectory_mk
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) :
    composeTrajectory resolve
      (toTrajectoryBoundary resolve xs)
      (toTrajectoryBoundary resolve ys)
    =
    toTrajectoryBoundary resolve (xs ++ ys) := by
  rfl

#check composeTrajectory_mk

/-! ============================================================
    Empty trajectory and identity laws
============================================================ -/

def emptyTrajectory
    (resolve : KernelExpr → Store → Location) :
    TrajectoryBoundary resolve :=
  toTrajectoryBoundary resolve []

#check emptyTrajectory

theorem composeTrajectory_id_left
    (resolve : KernelExpr → Store → Location)
    (t : TrajectoryBoundary resolve) :
    composeTrajectory resolve
      (emptyTrajectory resolve) t = t := by
  induction t using Quotient.ind with
  | _ xs =>
    rfl

#check composeTrajectory_id_left

theorem composeTrajectory_id_right
    (resolve : KernelExpr → Store → Location)
    (t : TrajectoryBoundary resolve) :
    composeTrajectory resolve
      t (emptyTrajectory resolve) = t := by
  induction t using Quotient.ind with
  | _ xs =>
    show toTrajectoryBoundary resolve (xs ++ []) = toTrajectoryBoundary resolve xs
    rw [List.append_nil]

#check composeTrajectory_id_right

/-! ============================================================
    Associativity
============================================================ -/

theorem composeTrajectory_assoc
    (resolve : KernelExpr → Store → Location)
    (a b c : TrajectoryBoundary resolve) :
    composeTrajectory resolve
      (composeTrajectory resolve a b) c
    =
    composeTrajectory resolve a
      (composeTrajectory resolve b c) := by
  induction a using Quotient.ind with
  | _ xs =>
    induction b using Quotient.ind with
    | _ ys =>
      induction c using Quotient.ind with
      | _ zs =>
        show toTrajectoryBoundary resolve ((xs ++ ys) ++ zs)
            = toTrajectoryBoundary resolve (xs ++ (ys ++ zs))
        rw [List.append_assoc]

#check composeTrajectory_assoc

/-! ============================================================
    Action compatibility
============================================================ -/

theorem actTrajectory_compose
    (resolve : KernelExpr → Store → Location)
    (tx ty : TrajectoryBoundary resolve)
    (q : PersistentBoundary resolve) :
    actTrajectory resolve
      (composeTrajectory resolve tx ty) q
    =
    actTrajectory resolve tx
      (actTrajectory resolve ty q) := by
  induction tx using Quotient.ind with
  | _ xs =>
    induction ty using Quotient.ind with
    | _ ys =>
      show evolvePersistent resolve (xs ++ ys) q
          = evolvePersistent resolve xs
              (evolvePersistent resolve ys q)
      exact evolvePersistent_append resolve xs ys q

#check actTrajectory_compose


/-! ============================================================
    Quotient-level trajectory equality via action
============================================================ -/

/--
Two trajectories are action-equivalent when they produce the same
result on every persistent boundary.
-/
def ActEqual
    (resolve : KernelExpr → Store → Location)
    (tx ty : TrajectoryBoundary resolve) : Prop :=
  ∀ q : PersistentBoundary resolve,
    actTrajectory resolve tx q =
    actTrajectory resolve ty q

#check ActEqual

theorem ActEqual_of_TrajectoryEquivalent
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (h : TrajectoryEquivalent resolve xs ys) :
    ActEqual resolve
      (toTrajectoryBoundary resolve xs)
      (toTrajectoryBoundary resolve ys) := by
  intro q
  rw [actTrajectory_mk, actTrajectory_mk]
  exact h q

#check ActEqual_of_TrajectoryEquivalent

theorem TrajectoryEquivalent_of_ActEqual
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (h : ActEqual resolve
           (toTrajectoryBoundary resolve xs)
           (toTrajectoryBoundary resolve ys)) :
    TrajectoryEquivalent resolve xs ys := by
  intro q
  rw [← actTrajectory_mk, ← actTrajectory_mk]
  exact h q

#check TrajectoryEquivalent_of_ActEqual

theorem ActEqual_iff_TrajectoryEquivalent
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) :
    ActEqual resolve
      (toTrajectoryBoundary resolve xs)
      (toTrajectoryBoundary resolve ys)
    ↔
    TrajectoryEquivalent resolve xs ys := by
  constructor
  · exact TrajectoryEquivalent_of_ActEqual resolve xs ys
  · exact ActEqual_of_TrajectoryEquivalent resolve xs ys

#check ActEqual_iff_TrajectoryEquivalent


theorem ActEqual_implies_eq
    (resolve : KernelExpr → Store → Location)
    (tx ty : TrajectoryBoundary resolve)
    (h : ActEqual resolve tx ty) :
    tx = ty := by
  induction tx using Quotient.ind with
  | _ xs =>
    induction ty using Quotient.ind with
    | _ ys =>
      apply Quotient.sound
      exact (ActEqual_iff_TrajectoryEquivalent resolve xs ys).mp h

#check ActEqual_implies_eq


def trajectoryEndo
    (resolve : KernelExpr → Store → Location)
    (tx : TrajectoryBoundary resolve) :
    PersistentBoundary resolve →
      PersistentBoundary resolve :=
  fun q => actTrajectory resolve tx q

#check trajectoryEndo


theorem trajectoryEndo_compose
    (resolve : KernelExpr → Store → Location)
    (tx ty : TrajectoryBoundary resolve) :
    trajectoryEndo resolve
      (composeTrajectory resolve tx ty)
    =
    (trajectoryEndo resolve tx) ∘
      (trajectoryEndo resolve ty) := by
  funext q
  exact actTrajectory_compose resolve tx ty q

#check trajectoryEndo_compose


theorem actTrajectory_empty
    (resolve : KernelExpr → Store → Location)
    (q : PersistentBoundary resolve) :
    actTrajectory resolve (emptyTrajectory resolve) q = q := by
  rw [emptyTrajectory, actTrajectory_mk]
  simp [evolvePersistent]

#check actTrajectory_empty

theorem trajectoryEndo_empty
    (resolve : KernelExpr → Store → Location) :
    trajectoryEndo resolve
      (emptyTrajectory resolve)
    =
    id := by
  funext q
  change actTrajectory resolve
      (emptyTrajectory resolve) q = q
  rw [show emptyTrajectory resolve =
      toTrajectoryBoundary resolve [] from rfl]
  rw [actTrajectory_mk]
  rfl

#check trajectoryEndo_empty


theorem trajectoryEndo_injective
    (resolve : KernelExpr → Store → Location) :
    Function.Injective (trajectoryEndo resolve) := by
  intro tx ty h
  apply ActEqual_implies_eq resolve tx ty
  intro q
  exact congrFun h q

#check trajectoryEndo_injective


theorem trajectory_monoid_left_identity
    (resolve : KernelExpr → Store → Location)
    (t : TrajectoryBoundary resolve) :
    composeTrajectory resolve
      (emptyTrajectory resolve) t = t := by
  exact composeTrajectory_id_left resolve t

#check trajectory_monoid_left_identity


theorem trajectory_monoid_associativity
    (resolve : KernelExpr → Store → Location)
    (a b c : TrajectoryBoundary resolve) :
    composeTrajectory resolve
      (composeTrajectory resolve a b) c
    =
    composeTrajectory resolve a
      (composeTrajectory resolve b c) := by
  exact composeTrajectory_assoc resolve a b c

#check trajectory_monoid_associativity


/-- Local monoid structure. Mathlib is not available in this environment. -/
structure TrajectoryMonoid
    (resolve : KernelExpr → Store → Location) where
  one : TrajectoryBoundary resolve
  mul : TrajectoryBoundary resolve →
        TrajectoryBoundary resolve →
        TrajectoryBoundary resolve
  one_mul : ∀ t, mul one t = t
  mul_one : ∀ t, mul t one = t
  mul_assoc :
    ∀ a b c,
      mul (mul a b) c = mul a (mul b c)

def trajectoryBoundaryMonoid
    (resolve : KernelExpr → Store → Location) :
    TrajectoryMonoid resolve :=
{
  one := emptyTrajectory resolve
  mul := composeTrajectory resolve
  one_mul := composeTrajectory_id_left resolve
  mul_one := composeTrajectory_id_right resolve
  mul_assoc := composeTrajectory_assoc resolve
}

#check trajectoryBoundaryMonoid


theorem composeAll_eq_implies_evolvePersistent_eq
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (h :
      composeAll xs =
      composeAll ys) :
    ∀ q : PersistentBoundary resolve,
      evolvePersistent resolve xs q =
      evolvePersistent resolve ys q := by
  intro q
  calc
    evolvePersistent resolve xs q
        = plugPersistent resolve (composeAll xs) q :=
            evolvePersistent_composeAll resolve xs q
    _ = plugPersistent resolve (composeAll ys) q := by
            rw [h]
    _ = evolvePersistent resolve ys q :=
            (evolvePersistent_composeAll resolve ys q).symm

#check composeAll_eq_implies_evolvePersistent_eq


def ContextActEqual
    (resolve : KernelExpr → Store → Location)
    (ctx₁ ctx₂ : KernelExprContext) : Prop :=
  ∀ q : PersistentBoundary resolve,
    plugPersistent resolve ctx₁ q =
    plugPersistent resolve ctx₂ q

#check ContextActEqual


theorem composeAll_nil :
    composeAll [] = hole := by
  rfl

#check composeAll_nil


theorem evolvePersistent_nil
    (resolve : KernelExpr → Store → Location)
    (q : PersistentBoundary resolve) :
    evolvePersistent resolve [] q = q := by
  rfl

#check evolvePersistent_nil


theorem composeAll_nonempty_can_be_hole :
    ∃ xs : List KernelExprContext,
      xs ≠ [] ∧
      composeAll xs = hole := by
  refine ⟨[identityContext], ?_, ?_⟩
  · decide
  · rfl

#check composeAll_nonempty_can_be_hole


theorem identity_action_not_empty_raw :
    ∃ xs : List KernelExprContext,
      xs ≠ [] ∧
      (∀ resolve : KernelExpr → Store → Location,
        ∀ q : PersistentBoundary resolve,
          evolvePersistent resolve xs q = q) := by
  refine ⟨[identityContext], ?_, ?_⟩
  · decide
  · intro resolve q
    rw [evolvePersistent_composeAll]
    have h : composeAll [identityContext] = hole := by rfl
    rw [h]
    exact plugPersistent_hole resolve q

#check identity_action_not_empty_raw


theorem identity_list_equals_empty_trajectory
    (resolve : KernelExpr → Store → Location) :
    toTrajectoryBoundary resolve [identityContext] =
    emptyTrajectory resolve := by
  apply Quotient.sound
  intro q
  rw [evolvePersistent_nil]
  rw [evolvePersistent_composeAll]
  have h : composeAll [identityContext] = hole := by rfl
  rw [h]
  exact plugPersistent_hole resolve q

#check identity_list_equals_empty_trajectory


theorem identity_action_implies_empty_trajectory
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext)
    (h :
      ∀ q : PersistentBoundary resolve,
        evolvePersistent resolve xs q = q) :
    toTrajectoryBoundary resolve xs =
    emptyTrajectory resolve := by
  apply Quotient.sound
  intro q
  rw [h q]
  rw [evolvePersistent_nil]

#check identity_action_implies_empty_trajectory


def swapContext : KernelExprContext where
  plug
    | .left  => .right
    | .right => .left
    | e      => e

theorem swapContext_ne_hole :
    swapContext ≠ hole := by
  intro h
  have : swapContext.plug KernelExpr.left = hole.plug KernelExpr.left := by
    rw [h]
  simp [swapContext, hole, identityContext] at this

def swapTwice (e : KernelExpr) : KernelExpr :=
  swapContext.plug (swapContext.plug e)

theorem swapTwice_eq_id (e : KernelExpr) :
    swapTwice e = e := by
  cases e <;> rfl

theorem swap_compose_swap_is_hole :
    swapContext.compose swapContext = hole := by
  show KernelExprContext.mk _ = KernelExprContext.mk _
  congr
  funext e
  exact swapTwice_eq_id e

theorem nontrivial_neutral_pair :
    ∃ a b : KernelExprContext,
      a ≠ hole ∧
      b ≠ hole ∧
      a.compose b = hole := by
  exact ⟨swapContext, swapContext, swapContext_ne_hole, swapContext_ne_hole, swap_compose_swap_is_hole⟩

#check nontrivial_neutral_pair


/-! ============================================================
    Neutral fold recoverability probes
============================================================ -/

theorem swap_pair_equals_empty_trajectory
    (resolve : KernelExpr → Store → Location) :
    toTrajectoryBoundary resolve [swapContext, swapContext] =
    emptyTrajectory resolve := by
  apply Quotient.sound
  intro q
  rw [evolvePersistent_nil]
  rw [evolvePersistent_composeAll]
  have h : composeAll [swapContext, swapContext] = hole := by
    exact swap_compose_swap_is_hole
  rw [h]
  exact plugPersistent_hole resolve q

#check swap_pair_equals_empty_trajectory

theorem future_cannot_distinguish_neutral_fold
    (resolve : KernelExpr → Store → Location)
    (future : TrajectoryBoundary resolve)
    (q : PersistentBoundary resolve) :
    actTrajectory resolve
      (composeTrajectory resolve
        (toTrajectoryBoundary resolve [])
        future) q
    =
    actTrajectory resolve
      (composeTrajectory resolve
        (toTrajectoryBoundary resolve [swapContext, swapContext])
        future) q := by
  rw [swap_pair_equals_empty_trajectory]
  rfl

#check future_cannot_distinguish_neutral_fold

theorem no_history_decoder_from_folded_state
    (resolve : KernelExpr → Store → Location) :
    ¬ ∃ f : TrajectoryBoundary resolve → Bool,
      f (toTrajectoryBoundary resolve []) = true ∧
      f (toTrajectoryBoundary resolve [swapContext, swapContext]) = false := by
  rintro ⟨f, hEmpty, hSwap⟩
  have hEq :
      toTrajectoryBoundary resolve [] =
      toTrajectoryBoundary resolve [swapContext, swapContext] := by
    exact (swap_pair_equals_empty_trajectory resolve).symm
  rw [hEq] at hEmpty
  exact Bool.noConfusion (hEmpty.symm.trans hSwap)

#check no_history_decoder_from_folded_state

theorem composeTrajectory_congr_right
    (resolve : KernelExpr → Store → Location)
    {tx ty future : TrajectoryBoundary resolve}
    (h : tx = ty) :
    composeTrajectory resolve tx future =
    composeTrajectory resolve ty future := by
  rw [h]

theorem composeTrajectory_congr_left
    (resolve : KernelExpr → Store → Location)
    {tx ty future : TrajectoryBoundary resolve}
    (h : tx = ty) :
    composeTrajectory resolve future tx =
    composeTrajectory resolve future ty := by
  rw [h]

#check composeTrajectory_congr_right
#check composeTrajectory_congr_left

def RawHistoryRecoverable
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ f : TrajectoryBoundary resolve → List KernelExprContext,
    ∀ xs : List KernelExprContext,
      f (toTrajectoryBoundary resolve xs) = xs

theorem raw_history_not_recoverable
    (resolve : KernelExpr → Store → Location) :
    ¬ RawHistoryRecoverable resolve := by
  intro ⟨f, hf⟩
  have hEmpty :
      f (toTrajectoryBoundary resolve []) = [] :=
    hf []
  have hSwap :
      f (toTrajectoryBoundary resolve [swapContext, swapContext]) =
      [swapContext, swapContext] :=
    hf [swapContext, swapContext]
  have hEq :
      toTrajectoryBoundary resolve [] =
      toTrajectoryBoundary resolve [swapContext, swapContext] := by
    exact (swap_pair_equals_empty_trajectory resolve).symm
  rw [hEq] at hEmpty
  have hContra :
      [] = [swapContext, swapContext] := by
    calc
      [] = f (toTrajectoryBoundary resolve [swapContext, swapContext]) := hEmpty.symm
      _ = [swapContext, swapContext] := hSwap
  injection hContra

#check raw_history_not_recoverable


def HistoricalEquivalent
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) : Prop :=
  toTrajectoryBoundary resolve xs =
  toTrajectoryBoundary resolve ys

#check HistoricalEquivalent


def HistoricalFibre
    (resolve : KernelExpr → Store → Location)
    (tx : TrajectoryBoundary resolve) :=
  { xs : List KernelExprContext //
      toTrajectoryBoundary resolve xs = tx }

#check HistoricalFibre


theorem historical_fibre_not_singleton
    (resolve : KernelExpr → Store → Location) :
    ∃ tx : TrajectoryBoundary resolve,
    ∃ xs ys : List KernelExprContext,
      xs ≠ ys ∧
      toTrajectoryBoundary resolve xs = tx ∧
      toTrajectoryBoundary resolve ys = tx := by
  refine ⟨emptyTrajectory resolve, [], [swapContext, swapContext], ?_, ?_, ?_⟩
  · intro h
    injection h
  · rfl
  · exact swap_pair_equals_empty_trajectory resolve

#check historical_fibre_not_singleton


def neutralPairs : Nat → List KernelExprContext
  | 0 => []
  | n + 1 => neutralPairs n ++ [swapContext, swapContext]

theorem neutralPairs_to_empty
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    toTrajectoryBoundary resolve (neutralPairs n) =
    emptyTrajectory resolve := by
  induction n with
  | zero =>
    simp [neutralPairs, emptyTrajectory]
  | succ n ih =>
    have hComp :
        toTrajectoryBoundary resolve (neutralPairs n ++ [swapContext, swapContext]) =
        composeTrajectory resolve
          (toTrajectoryBoundary resolve (neutralPairs n))
          (toTrajectoryBoundary resolve [swapContext, swapContext]) := by
      exact (composeTrajectory_mk resolve _ _).symm
    simp [neutralPairs]
    rw [hComp]
    rw [ih]
    rw [swap_pair_equals_empty_trajectory]
    exact composeTrajectory_id_left resolve (emptyTrajectory resolve)

#check neutralPairs
#check neutralPairs_to_empty


def HistoryInvariant
    (resolve : KernelExpr → Store → Location)
    (P : List KernelExprContext → Prop) : Prop :=
  ∀ xs ys : List KernelExprContext,
    HistoricalEquivalent resolve xs ys →
    (P xs ↔ P ys)

#check HistoryInvariant


theorem neutralPairs_length
    (n : Nat) :
    (neutralPairs n).length = 2 * n := by
  induction n with
  | zero => simp [neutralPairs]
  | succ n ih =>
    simp [neutralPairs, List.length_append, ih]
    omega

theorem neutralPairs_distinct
    (m n : Nat)
    (h : m ≠ n) :
    neutralPairs m ≠ neutralPairs n := by
  intro hEq
  have hLen : (neutralPairs m).length = (neutralPairs n).length := by
    rw [hEq]
  rw [neutralPairs_length, neutralPairs_length] at hLen
  omega

theorem empty_fibre_infinite
    (resolve : KernelExpr → Store → Location) :
    ∀ n : Nat,
      toTrajectoryBoundary resolve (neutralPairs n) = emptyTrajectory resolve ∧
      (∀ m : Nat, m < n → neutralPairs m ≠ neutralPairs n) := by
  intro n
  constructor
  · exact neutralPairs_to_empty resolve n
  · intro m hm
    exact neutralPairs_distinct m n (Nat.ne_of_lt hm)

#check neutralPairs_distinct
#check empty_fibre_infinite


/-! ============================================================
    Historical observable boundary
============================================================ -/

def HistoryLength
    (xs : List KernelExprContext) : Nat :=
  xs.length

theorem length_not_invariant
    (resolve : KernelExpr → Store → Location) :
    ¬ HistoryInvariant resolve
        (fun xs => xs.length = 0) := by
  intro hInv
  have hEq :
      HistoricalEquivalent resolve [] (neutralPairs 1) := by
    unfold HistoricalEquivalent
    exact (neutralPairs_to_empty resolve 1).symm
  have hIff :
      ([] : List KernelExprContext).length = 0 ↔
      (neutralPairs 1).length = 0 :=
    hInv [] (neutralPairs 1) hEq
  have hEmpty : ([] : List KernelExprContext).length = 0 := by
    simp
  have hNonEmpty : (neutralPairs 1).length ≠ 0 := by
    have hLen : (neutralPairs 1).length = 2 * 1 := by
      exact neutralPairs_length 1
    rw [hLen]
    omega
  exact hNonEmpty (hIff.mp hEmpty)

theorem length_not_determined
    (resolve : KernelExpr → Store → Location) :
    ∃ xs ys : List KernelExprContext,
      HistoricalEquivalent resolve xs ys ∧
      xs.length ≠ ys.length := by
  refine ⟨[], neutralPairs 1, ?_, ?_⟩
  · unfold HistoricalEquivalent
    exact (neutralPairs_to_empty resolve 1).symm
  · have hLen : (neutralPairs 1).length = 2 := by
      have h : (neutralPairs 1).length = 2 * 1 := neutralPairs_length 1
      omega
    rw [hLen]
    decide

#check length_not_invariant
#check length_not_determined

/-! Prefix recovery -/

def PrefixRecoverable
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ f : TrajectoryBoundary resolve → Option KernelExprContext,
    ∀ xs : List KernelExprContext,
      f (toTrajectoryBoundary resolve xs) =
      xs.head?

theorem prefix_not_recoverable
    (resolve : KernelExpr → Store → Location) :
    ¬ PrefixRecoverable resolve := by
  intro ⟨f, hf⟩
  have hEmpty :
      f (toTrajectoryBoundary resolve []) = none := by
    rw [hf]
    simp
  have hSwap :
      f (toTrajectoryBoundary resolve [swapContext, swapContext]) =
      some swapContext := by
    rw [hf]
    simp
  have hEq :
      toTrajectoryBoundary resolve [] =
      toTrajectoryBoundary resolve [swapContext, swapContext] := by
    exact (swap_pair_equals_empty_trajectory resolve).symm
  rw [hEq] at hEmpty
  injection hEmpty.symm.trans hSwap

#check prefix_not_recoverable

/-! Suffix recovery -/

def SuffixRecoverable
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ f : TrajectoryBoundary resolve → Option KernelExprContext,
    ∀ xs : List KernelExprContext,
      f (toTrajectoryBoundary resolve xs) =
      xs.getLast?

theorem suffix_not_recoverable
    (resolve : KernelExpr → Store → Location) :
    ¬ SuffixRecoverable resolve := by
  intro ⟨f, hf⟩
  have hEmpty :
      f (toTrajectoryBoundary resolve []) = none := by
    rw [hf]
    simp
  have hSwap :
      f (toTrajectoryBoundary resolve [swapContext, swapContext]) =
      some swapContext := by
    rw [hf]
    simp
  have hEq :
      toTrajectoryBoundary resolve [] =
      toTrajectoryBoundary resolve [swapContext, swapContext] := by
    exact (swap_pair_equals_empty_trajectory resolve).symm
  rw [hEq] at hEmpty
  injection hEmpty.symm.trans hSwap

#check suffix_not_recoverable

/-! Coarse properties -/

theorem empty_list_not_invariant
    (resolve : KernelExpr → Store → Location) :
    ¬ HistoryInvariant resolve
        (fun xs => xs = []) := by
  intro hInv
  have hEq :
      HistoricalEquivalent resolve [] (neutralPairs 1) := by
    unfold HistoricalEquivalent
    exact (neutralPairs_to_empty resolve 1).symm
  have hIff :
      ([] : List KernelExprContext) = [] ↔
      neutralPairs 1 = [] :=
    hInv [] (neutralPairs 1) hEq
  have hNonEmpty : neutralPairs 1 ≠ [] := by
    intro h
    have hLen : (neutralPairs 1).length = 0 := by
      rw [h]
      simp
    rw [neutralPairs_length] at hLen
    omega
  exact hNonEmpty (hIff.mp rfl)

theorem empty_class_membership_invariant
    (resolve : KernelExpr → Store → Location) :
    HistoryInvariant resolve
      (fun xs =>
        toTrajectoryBoundary resolve xs = emptyTrajectory resolve) := by
  intro xs ys hEq
  unfold HistoricalEquivalent at hEq
  constructor
  · intro h
    exact hEq.symm.trans h
  · intro h
    exact hEq.trans h

#check empty_list_not_invariant
#check empty_class_membership_invariant

/-! Factorisation criterion -/

theorem history_invariant_iff_factor
    (resolve : KernelExpr → Store → Location)
    (P : List KernelExprContext → Prop) :
    HistoryInvariant resolve P ↔
    ∃ PBoundary : TrajectoryBoundary resolve → Prop,
      ∀ xs : List KernelExprContext,
        PBoundary (toTrajectoryBoundary resolve xs) ↔ P xs := by
  constructor
  · intro hInv
    refine ⟨fun t =>
      Quotient.lift
        (fun xs => P xs)
        (fun xs ys h => by
          have hHist :
              HistoricalEquivalent resolve xs ys := by
            unfold HistoricalEquivalent
            exact Quotient.sound h
          exact propext (hInv xs ys hHist))
        t, ?_⟩
    intro xs
    rfl
  · intro ⟨PBoundary, hFact⟩
    intro xs ys hEq
    unfold HistoricalEquivalent at hEq
    rw [← hFact, ← hFact, hEq]

#check history_invariant_iff_factor

/-! Value-valued observables -/

def HistoryObservableInvariant
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (obs : List KernelExprContext → O) : Prop :=
  ∀ xs ys : List KernelExprContext,
    HistoricalEquivalent resolve xs ys →
    obs xs = obs ys

theorem history_observable_invariant_iff_factor
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (obs : List KernelExprContext → O) :
    HistoryObservableInvariant resolve obs ↔
    ∃ obsBoundary : TrajectoryBoundary resolve → O,
      ∀ xs : List KernelExprContext,
        obsBoundary (toTrajectoryBoundary resolve xs) = obs xs := by
  constructor
  · intro hInv
    refine ⟨fun t =>
      Quotient.lift
        obs
        (fun xs ys h => by
          have hHist :
              HistoricalEquivalent resolve xs ys := by
            unfold HistoricalEquivalent
            exact Quotient.sound h
          exact hInv xs ys hHist)
        t, ?_⟩
    intro xs
    rfl
  · intro ⟨obsBoundary, hFact⟩
    intro xs ys hEq
    unfold HistoricalEquivalent at hEq
    rw [← hFact, ← hFact, hEq]

#check HistoryObservableInvariant
#check history_observable_invariant_iff_factor


/-! ============================================================
    Neutral insertion on arbitrary reachable boundaries
============================================================ -/

theorem right_neutral_insertion
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext)
    (n : Nat) :
    toTrajectoryBoundary resolve (xs ++ neutralPairs n) =
    toTrajectoryBoundary resolve xs := by
  have hComp :
      toTrajectoryBoundary resolve (xs ++ neutralPairs n) =
      composeTrajectory resolve
        (toTrajectoryBoundary resolve xs)
        (toTrajectoryBoundary resolve (neutralPairs n)) := by
    exact (composeTrajectory_mk resolve xs (neutralPairs n)).symm
  rw [hComp]
  rw [neutralPairs_to_empty]
  exact composeTrajectory_id_right resolve (toTrajectoryBoundary resolve xs)

theorem left_neutral_insertion
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext)
    (n : Nat) :
    toTrajectoryBoundary resolve (neutralPairs n ++ xs) =
    toTrajectoryBoundary resolve xs := by
  have hComp :
      toTrajectoryBoundary resolve (neutralPairs n ++ xs) =
      composeTrajectory resolve
        (toTrajectoryBoundary resolve (neutralPairs n))
        (toTrajectoryBoundary resolve xs) := by
    exact (composeTrajectory_mk resolve (neutralPairs n) xs).symm
  rw [hComp]
  rw [neutralPairs_to_empty]
  exact composeTrajectory_id_left resolve (toTrajectoryBoundary resolve xs)

#check right_neutral_insertion
#check left_neutral_insertion

theorem arbitrary_length_representatives
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext)
    (n : Nat) :
    ∃ ys : List KernelExprContext,
      toTrajectoryBoundary resolve ys =
        toTrajectoryBoundary resolve xs ∧
      ys.length ≥ xs.length + 2 * n := by
  refine ⟨xs ++ neutralPairs n, ?_, ?_⟩
  · exact right_neutral_insertion resolve xs n
  · have hLen : (neutralPairs n).length = 2 * n := neutralPairs_length n
    simp [List.length_append, hLen]

#check arbitrary_length_representatives

theorem right_insertion_injective
    (xs : List KernelExprContext)
    (m n : Nat)
    (h : m ≠ n) :
    xs ++ neutralPairs m ≠ xs ++ neutralPairs n := by
  intro hEq
  have hTail : neutralPairs m = neutralPairs n := by
    have hLenM : (neutralPairs m).length = 2 * m := neutralPairs_length m
    have hLenN : (neutralPairs n).length = 2 * n := neutralPairs_length n
    have hDrop :
        List.drop xs.length (xs ++ neutralPairs m) =
        List.drop xs.length (xs ++ neutralPairs n) := by
      rw [hEq]
    rw [List.drop_left, List.drop_left] at hDrop
    exact hDrop
  exact neutralPairs_distinct m n h hTail

theorem left_insertion_injective
    (xs : List KernelExprContext)
    (m n : Nat)
    (h : m ≠ n) :
    neutralPairs m ++ xs ≠ neutralPairs n ++ xs := by
  intro hEq
  have hLen : (neutralPairs m ++ xs).length = (neutralPairs n ++ xs).length := by
    rw [hEq]
  have hLenM : (neutralPairs m).length = 2 * m := neutralPairs_length m
  have hLenN : (neutralPairs n).length = 2 * n := neutralPairs_length n
  simp [List.length_append, hLenM, hLenN] at hLen
  omega

#check right_insertion_injective
#check left_insertion_injective

theorem reachable_fibre_infinite
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    ∀ n : Nat,
      toTrajectoryBoundary resolve (xs ++ neutralPairs n) =
        toTrajectoryBoundary resolve xs ∧
      (∀ m : Nat, m < n →
        xs ++ neutralPairs m ≠ xs ++ neutralPairs n) := by
  intro n
  constructor
  · exact right_neutral_insertion resolve xs n
  · intro m hm
    exact right_insertion_injective xs m n (Nat.ne_of_lt hm)

#check reachable_fibre_infinite

def HistoryLengthBound
    (resolve : KernelExpr → Store → Location)
    (tx : TrajectoryBoundary resolve)
    (B : Nat) : Prop :=
  ∀ xs : List KernelExprContext,
    toTrajectoryBoundary resolve xs = tx →
    xs.length ≤ B

theorem no_finite_length_bound
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    ¬ ∃ B : Nat,
      HistoryLengthBound resolve
        (toTrajectoryBoundary resolve xs) B := by
  intro ⟨B, hBound⟩
  have hRep :
      toTrajectoryBoundary resolve (xs ++ neutralPairs (B + 1)) =
      toTrajectoryBoundary resolve xs :=
    right_neutral_insertion resolve xs (B + 1)
  have hLen :
      (xs ++ neutralPairs (B + 1)).length > B := by
    have hNeut : (neutralPairs (B + 1)).length = 2 * (B + 1) :=
      neutralPairs_length (B + 1)
    simp [List.length_append, hNeut]
    omega
  exact Nat.not_le_of_gt hLen (hBound _ hRep)

#check no_finite_length_bound

theorem right_insertion_preserves_observables
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (obs : List KernelExprContext → O)
    (hInv : HistoryObservableInvariant resolve obs)
    (xs : List KernelExprContext)
    (n : Nat) :
    obs xs = obs (xs ++ neutralPairs n) := by
  have hEq :
      HistoricalEquivalent resolve xs (xs ++ neutralPairs n) := by
    unfold HistoricalEquivalent
    exact (right_neutral_insertion resolve xs n).symm
  exact hInv xs (xs ++ neutralPairs n) hEq

theorem left_insertion_preserves_observables
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (obs : List KernelExprContext → O)
    (hInv : HistoryObservableInvariant resolve obs)
    (xs : List KernelExprContext)
    (n : Nat) :
    obs xs = obs (neutralPairs n ++ xs) := by
  have hEq :
      HistoricalEquivalent resolve xs (neutralPairs n ++ xs) := by
    unfold HistoricalEquivalent
    exact (left_neutral_insertion resolve xs n).symm
  exact hInv xs (neutralPairs n ++ xs) hEq

#check right_insertion_preserves_observables
#check left_insertion_preserves_observables


/-! ============================================================
    Length parity and modulo observables
============================================================ -/

def LengthParity
    (xs : List KernelExprContext) : Nat :=
  xs.length % 2

def LengthMod
    (k : Nat)
    (xs : List KernelExprContext) : Nat :=
  xs.length % k

theorem right_neutral_length
    (xs : List KernelExprContext)
    (n : Nat) :
    (xs ++ neutralPairs n).length =
    xs.length + 2 * n := by
  have hLen : (neutralPairs n).length = 2 * n := neutralPairs_length n
  simp [List.length_append, hLen]

theorem left_neutral_length
    (xs : List KernelExprContext)
    (n : Nat) :
    (neutralPairs n ++ xs).length =
    xs.length + 2 * n := by
  have hLen : (neutralPairs n).length = 2 * n := neutralPairs_length n
  simp [List.length_append, hLen]
  omega

theorem right_neutral_preserves_parity
    (xs : List KernelExprContext)
    (n : Nat) :
    (xs ++ neutralPairs n).length % 2 =
    xs.length % 2 := by
  rw [right_neutral_length]
  omega

theorem left_neutral_preserves_parity
    (xs : List KernelExprContext)
    (n : Nat) :
    (neutralPairs n ++ xs).length % 2 =
    xs.length % 2 := by
  rw [left_neutral_length]
  omega

#check LengthParity
#check LengthMod
#check right_neutral_length
#check left_neutral_length
#check right_neutral_preserves_parity
#check left_neutral_preserves_parity


/-! ============================================================
    Open parity boundary
============================================================ -/

def ParityPreserved
    (resolve : KernelExpr → Store → Location) : Prop :=
  HistoryObservableInvariant resolve LengthParity

def ParityCollision
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ xs ys : List KernelExprContext,
    HistoricalEquivalent resolve xs ys ∧
    LengthParity xs ≠ LengthParity ys

theorem parityCollision_iff_not_preserved
    (resolve : KernelExpr → Store → Location) :
    ParityCollision resolve ↔
    ¬ ParityPreserved resolve := by
  constructor
  · intro ⟨xs, ys, hEq, hDiff⟩
    intro hPres
    exact hDiff (hPres xs ys hEq)
  · intro hNot
    unfold ParityPreserved HistoryObservableInvariant at hNot
    have hEx : ∃ xs, ¬ ∀ ys, HistoricalEquivalent resolve xs ys → LengthParity xs = LengthParity ys :=
      Classical.not_forall.mp hNot
    rcases hEx with ⟨xs, hNotYs⟩
    have hExYs : ∃ ys, ¬ (HistoricalEquivalent resolve xs ys → LengthParity xs = LengthParity ys) :=
      Classical.not_forall.mp hNotYs
    rcases hExYs with ⟨ys, hNotImp⟩
    have hEq : HistoricalEquivalent resolve xs ys := by
      apply Classical.byContradiction
      intro hNotEq
      exact hNotImp (fun h => False.elim (hNotEq h))
    have hDiff : LengthParity xs ≠ LengthParity ys := by
      intro hSame
      exact hNotImp (fun _ => hSame)
    exact ⟨xs, ys, hEq, hDiff⟩

theorem right_neutral_parity_stable
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext)
    (n : Nat) :
    HistoricalEquivalent resolve xs (xs ++ neutralPairs n) ∧
    LengthParity xs =
      LengthParity (xs ++ neutralPairs n) := by
  constructor
  · unfold HistoricalEquivalent
    exact (right_neutral_insertion resolve xs n).symm
  · unfold LengthParity
    exact (right_neutral_preserves_parity xs n).symm

theorem left_neutral_parity_stable
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext)
    (n : Nat) :
    HistoricalEquivalent resolve xs (neutralPairs n ++ xs) ∧
    LengthParity xs =
      LengthParity (neutralPairs n ++ xs) := by
  constructor
  · unfold HistoricalEquivalent
    exact (left_neutral_insertion resolve xs n).symm
  · unfold LengthParity
    exact (left_neutral_preserves_parity xs n).symm

def lengthParityBoundary
    (resolve : KernelExpr → Store → Location)
    (hParity : ParityPreserved resolve) :
    TrajectoryBoundary resolve → Nat :=
  Quotient.lift LengthParity
    (fun xs ys hEq => by
      have hHist :
          HistoricalEquivalent resolve xs ys := by
        unfold HistoricalEquivalent
        exact Quotient.sound hEq
      exact hParity xs ys hHist)

theorem lengthParityBoundary_mk
    (resolve : KernelExpr → Store → Location)
    (hParity : ParityPreserved resolve)
    (xs : List KernelExprContext) :
    lengthParityBoundary resolve hParity
      (toTrajectoryBoundary resolve xs)
    =
    LengthParity xs := by
  rfl

theorem parity_collision_blocks_factorisation
    (resolve : KernelExpr → Store → Location)
    (hCollision : ParityCollision resolve) :
    ¬ ∃ parityBoundary : TrajectoryBoundary resolve → Nat,
        ∀ xs : List KernelExprContext,
          parityBoundary
            (toTrajectoryBoundary resolve xs)
          =
          LengthParity xs := by
  intro ⟨parityBoundary, hFact⟩
  rcases hCollision with ⟨xs, ys, hEq, hDiff⟩
  have hXs : parityBoundary (toTrajectoryBoundary resolve xs) = LengthParity xs :=
    hFact xs
  have hYs : parityBoundary (toTrajectoryBoundary resolve ys) = LengthParity ys :=
    hFact ys
  unfold HistoricalEquivalent at hEq
  rw [hEq] at hXs
  exact hDiff (hXs.symm.trans hYs)

#check ParityPreserved
#check ParityCollision
#check parityCollision_iff_not_preserved
#check right_neutral_parity_stable
#check left_neutral_parity_stable
#check lengthParityBoundary
#check lengthParityBoundary_mk
#check parity_collision_blocks_factorisation


/-! ============================================================
    Open modulo-k boundary
============================================================ -/

def ModPreserved
    (resolve : KernelExpr → Store → Location)
    (k : Nat) : Prop :=
  HistoryObservableInvariant resolve (LengthMod k)

def ModCollision
    (resolve : KernelExpr → Store → Location)
    (k : Nat) : Prop :=
  ∃ xs ys : List KernelExprContext,
    HistoricalEquivalent resolve xs ys ∧
    LengthMod k xs ≠ LengthMod k ys

theorem modCollision_iff_not_preserved
    (resolve : KernelExpr → Store → Location)
    (k : Nat) :
    ModCollision resolve k ↔
    ¬ ModPreserved resolve k := by
  constructor
  · intro ⟨xs, ys, hEq, hDiff⟩
    intro hPres
    exact hDiff (hPres xs ys hEq)
  · intro hNot
    unfold ModPreserved HistoryObservableInvariant at hNot
    have hEx : ∃ xs, ¬ ∀ ys, HistoricalEquivalent resolve xs ys → LengthMod k xs = LengthMod k ys :=
      Classical.not_forall.mp hNot
    rcases hEx with ⟨xs, hNotYs⟩
    have hExYs : ∃ ys, ¬ (HistoricalEquivalent resolve xs ys → LengthMod k xs = LengthMod k ys) :=
      Classical.not_forall.mp hNotYs
    rcases hExYs with ⟨ys, hNotImp⟩
    have hEq : HistoricalEquivalent resolve xs ys := by
      apply Classical.byContradiction
      intro hNotEq
      exact hNotImp (fun h => False.elim (hNotEq h))
    have hDiff : LengthMod k xs ≠ LengthMod k ys := by
      intro hSame
      exact hNotImp (fun _ => hSame)
    exact ⟨xs, ys, hEq, hDiff⟩

theorem right_neutral_mod_stable_of_divides
    (xs : List KernelExprContext)
    (k n : Nat)
    (hk : k ≠ 0)
    (hDiv : (2 * n) % k = 0) :
    LengthMod k (xs ++ neutralPairs n) = LengthMod k xs := by
  unfold LengthMod
  rw [right_neutral_length]
  have hAdd : (xs.length + 2 * n) % k = (xs.length % k + (2 * n) % k) % k := by
    exact Nat.add_mod _ _ _
  rw [hAdd, hDiv]
  simp [Nat.add_zero, Nat.mod_mod]

theorem left_neutral_mod_stable_of_divides
    (xs : List KernelExprContext)
    (k n : Nat)
    (hk : k ≠ 0)
    (hDiv : (2 * n) % k = 0) :
    LengthMod k (neutralPairs n ++ xs) = LengthMod k xs := by
  unfold LengthMod
  rw [left_neutral_length]
  have hAdd : (xs.length + 2 * n) % k = (xs.length % k + (2 * n) % k) % k := by
    exact Nat.add_mod _ _ _
  rw [hAdd, hDiv]
  simp [Nat.add_zero, Nat.mod_mod]

-- replaced above

theorem right_neutral_mod1_stable
    (xs : List KernelExprContext)
    (n : Nat) :
    LengthMod 1 (xs ++ neutralPairs n) = LengthMod 1 xs := by
  exact right_neutral_mod_stable_of_divides xs 1 n (by omega) (by omega)

theorem left_neutral_mod1_stable
    (xs : List KernelExprContext)
    (n : Nat) :
    LengthMod 1 (neutralPairs n ++ xs) = LengthMod 1 xs := by
  exact left_neutral_mod_stable_of_divides xs 1 n (by omega) (by omega)

theorem right_neutral_mod2_stable
    (xs : List KernelExprContext)
    (n : Nat) :
    LengthMod 2 (xs ++ neutralPairs n) = LengthMod 2 xs := by
  exact right_neutral_mod_stable_of_divides xs 2 n (by omega) (by omega)

theorem left_neutral_mod2_stable
    (xs : List KernelExprContext)
    (n : Nat) :
    LengthMod 2 (neutralPairs n ++ xs) = LengthMod 2 xs := by
  exact left_neutral_mod_stable_of_divides xs 2 n (by omega) (by omega)

theorem right_neutral_mod0_changes
    (xs : List KernelExprContext)
    (n : Nat)
    (hn : n ≠ 0) :
    LengthMod 0 (xs ++ neutralPairs n) ≠ LengthMod 0 xs := by
  unfold LengthMod
  rw [right_neutral_length]
  omega

theorem left_neutral_mod0_changes
    (xs : List KernelExprContext)
    (n : Nat)
    (hn : n ≠ 0) :
    LengthMod 0 (neutralPairs n ++ xs) ≠ LengthMod 0 xs := by
  unfold LengthMod
  rw [left_neutral_length]
  omega

def lengthModBoundary
    (resolve : KernelExpr → Store → Location)
    (k : Nat)
    (hMod : ModPreserved resolve k) :
    TrajectoryBoundary resolve → Nat :=
  Quotient.lift (LengthMod k)
    (fun xs ys hEq => by
      have hHist :
          HistoricalEquivalent resolve xs ys := by
        unfold HistoricalEquivalent
        exact Quotient.sound hEq
      exact hMod xs ys hHist)

theorem lengthModBoundary_mk
    (resolve : KernelExpr → Store → Location)
    (k : Nat)
    (hMod : ModPreserved resolve k)
    (xs : List KernelExprContext) :
    lengthModBoundary resolve k hMod
      (toTrajectoryBoundary resolve xs)
    =
    LengthMod k xs := by
  rfl

theorem mod_collision_blocks_factorisation
    (resolve : KernelExpr → Store → Location)
    (k : Nat)
    (hCollision : ModCollision resolve k) :
    ¬ ∃ modBoundary : TrajectoryBoundary resolve → Nat,
        ∀ xs : List KernelExprContext,
          modBoundary
            (toTrajectoryBoundary resolve xs)
          =
          LengthMod k xs := by
  intro ⟨modBoundary, hFact⟩
  rcases hCollision with ⟨xs, ys, hEq, hDiff⟩
  have hXs : modBoundary (toTrajectoryBoundary resolve xs) = LengthMod k xs :=
    hFact xs
  have hYs : modBoundary (toTrajectoryBoundary resolve ys) = LengthMod k ys :=
    hFact ys
  unfold HistoricalEquivalent at hEq
  rw [hEq] at hXs
  exact hDiff (hXs.symm.trans hYs)

theorem LengthParity_eq_LengthMod2
    (xs : List KernelExprContext) :
    LengthParity xs = LengthMod 2 xs := by
  unfold LengthParity LengthMod
  rfl

theorem parityPreserved_iff_mod2Preserved
    (resolve : KernelExpr → Store → Location) :
    ParityPreserved resolve ↔ ModPreserved resolve 2 := by
  unfold ParityPreserved ModPreserved HistoryObservableInvariant
  constructor
  · intro h xs ys hEq
    rw [← LengthParity_eq_LengthMod2, ← LengthParity_eq_LengthMod2]
    exact h xs ys hEq
  · intro h xs ys hEq
    rw [LengthParity_eq_LengthMod2, LengthParity_eq_LengthMod2]
    exact h xs ys hEq

theorem parityCollision_iff_mod2Collision
    (resolve : KernelExpr → Store → Location) :
    ParityCollision resolve ↔ ModCollision resolve 2 := by
  unfold ParityCollision ModCollision
  constructor
  · intro ⟨xs, ys, hEq, hDiff⟩
    rw [LengthParity_eq_LengthMod2, LengthParity_eq_LengthMod2] at hDiff
    exact ⟨xs, ys, hEq, hDiff⟩
  · intro ⟨xs, ys, hEq, hDiff⟩
    rw [← LengthParity_eq_LengthMod2, ← LengthParity_eq_LengthMod2] at hDiff
    exact ⟨xs, ys, hEq, hDiff⟩

#check ModPreserved
#check ModCollision
#check modCollision_iff_not_preserved
#check right_neutral_mod_stable_of_divides
#check left_neutral_mod_stable_of_divides
#check lengthModBoundary
#check lengthModBoundary_mk
#check mod_collision_blocks_factorisation
#check LengthParity_eq_LengthMod2
#check parityPreserved_iff_mod2Preserved
#check parityCollision_iff_mod2Collision


/-! ============================================================
    HistoricalEquivalent congruence under concatenation
============================================================ -/

theorem historicalEquivalent_append_right
    (resolve : KernelExpr → Store → Location)
    {xs ys : List KernelExprContext}
    (h : HistoricalEquivalent resolve xs ys)
    (zs : List KernelExprContext) :
    HistoricalEquivalent resolve
      (xs ++ zs)
      (ys ++ zs) := by
  unfold HistoricalEquivalent at *
  have hXs : toTrajectoryBoundary resolve (xs ++ zs) =
      composeTrajectory resolve
        (toTrajectoryBoundary resolve xs)
        (toTrajectoryBoundary resolve zs) :=
    (composeTrajectory_mk resolve xs zs).symm
  have hYs : toTrajectoryBoundary resolve (ys ++ zs) =
      composeTrajectory resolve
        (toTrajectoryBoundary resolve ys)
        (toTrajectoryBoundary resolve zs) :=
    (composeTrajectory_mk resolve ys zs).symm
  rw [hXs, hYs, h]

theorem historicalEquivalent_append_left
    (resolve : KernelExpr → Store → Location)
    {xs ys : List KernelExprContext}
    (h : HistoricalEquivalent resolve xs ys)
    (zs : List KernelExprContext) :
    HistoricalEquivalent resolve
      (zs ++ xs)
      (zs ++ ys) := by
  unfold HistoricalEquivalent at *
  have hXs : toTrajectoryBoundary resolve (zs ++ xs) =
      composeTrajectory resolve
        (toTrajectoryBoundary resolve zs)
        (toTrajectoryBoundary resolve xs) :=
    (composeTrajectory_mk resolve zs xs).symm
  have hYs : toTrajectoryBoundary resolve (zs ++ ys) =
      composeTrajectory resolve
        (toTrajectoryBoundary resolve zs)
        (toTrajectoryBoundary resolve ys) :=
    (composeTrajectory_mk resolve zs ys).symm
  rw [hXs, hYs, h]

theorem historicalEquivalent_append_congr
    (resolve : KernelExpr → Store → Location)
    {xs xs' ys ys' : List KernelExprContext}
    (hx : HistoricalEquivalent resolve xs xs')
    (hy : HistoricalEquivalent resolve ys ys') :
    HistoricalEquivalent resolve
      (xs ++ ys)
      (xs' ++ ys') := by
  have hLeft :
      HistoricalEquivalent resolve (xs ++ ys) (xs' ++ ys) :=
    historicalEquivalent_append_right resolve hx ys
  have hRight :
      HistoricalEquivalent resolve (xs' ++ ys) (xs' ++ ys') :=
    historicalEquivalent_append_left resolve hy xs'
  unfold HistoricalEquivalent at *
  exact hLeft.trans hRight

theorem observable_append_right
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (obs : List KernelExprContext → O)
    (hInv : HistoryObservableInvariant resolve obs)
    {xs ys : List KernelExprContext}
    (h : HistoricalEquivalent resolve xs ys)
    (zs : List KernelExprContext) :
    obs (xs ++ zs) = obs (ys ++ zs) := by
  exact hInv (xs ++ zs) (ys ++ zs)
    (historicalEquivalent_append_right resolve h zs)

theorem observable_append_left
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (obs : List KernelExprContext → O)
    (hInv : HistoryObservableInvariant resolve obs)
    {xs ys : List KernelExprContext}
    (h : HistoricalEquivalent resolve xs ys)
    (zs : List KernelExprContext) :
    obs (zs ++ xs) = obs (zs ++ ys) := by
  exact hInv (zs ++ xs) (zs ++ ys)
    (historicalEquivalent_append_left resolve h zs)

theorem toTrajectoryBoundary_append
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) :
    toTrajectoryBoundary resolve (xs ++ ys) =
    composeTrajectory resolve
      (toTrajectoryBoundary resolve xs)
      (toTrajectoryBoundary resolve ys) := by
  exact (composeTrajectory_mk resolve xs ys).symm

theorem neutral_insertion_is_congruence
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext)
    (n : Nat) :
    HistoricalEquivalent resolve (xs ++ neutralPairs n) xs ∧
    HistoricalEquivalent resolve (neutralPairs n ++ xs) xs := by
  have hNeut :
      HistoricalEquivalent resolve (neutralPairs n) [] := by
    unfold HistoricalEquivalent
    exact neutralPairs_to_empty resolve n
  constructor
  · have h :
        HistoricalEquivalent resolve (xs ++ neutralPairs n) (xs ++ []) :=
      historicalEquivalent_append_left resolve hNeut xs
    unfold HistoricalEquivalent at *
    simp at h
    exact h
  · have h :
        HistoricalEquivalent resolve (neutralPairs n ++ xs) ([] ++ xs) :=
      historicalEquivalent_append_right resolve hNeut xs
    unfold HistoricalEquivalent at *
    simp at h
    exact h

#check historicalEquivalent_append_right
#check historicalEquivalent_append_left
#check historicalEquivalent_append_congr
#check observable_append_right
#check observable_append_left
#check toTrajectoryBoundary_append
#check neutral_insertion_is_congruence


def trajectoryProjection
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    TrajectoryBoundary resolve :=
  toTrajectoryBoundary resolve xs

#check trajectoryProjection


theorem trajectoryProjection_nil
    (resolve : KernelExpr → Store → Location) :
    trajectoryProjection resolve [] =
    emptyTrajectory resolve := by
  rfl

#check trajectoryProjection_nil


theorem trajectoryProjection_append
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) :
    trajectoryProjection resolve (xs ++ ys) =
    composeTrajectory resolve
      (trajectoryProjection resolve xs)
      (trajectoryProjection resolve ys) := by
  exact toTrajectoryBoundary_append resolve xs ys

#check trajectoryProjection_append


structure TrajectoryProjectionHom
    (resolve : KernelExpr → Store → Location) where
  toFun :
    List KernelExprContext →
    TrajectoryBoundary resolve

  map_one :
    toFun [] =
    emptyTrajectory resolve

  map_mul :
    ∀ xs ys,
      toFun (xs ++ ys) =
      composeTrajectory resolve
        (toFun xs)
        (toFun ys)

#check TrajectoryProjectionHom


def trajectoryProjectionHom
    (resolve : KernelExpr → Store → Location) :
    TrajectoryProjectionHom resolve :=
{
  toFun := trajectoryProjection resolve
  map_one := trajectoryProjection_nil resolve
  map_mul := trajectoryProjection_append resolve
}

#check trajectoryProjectionHom


theorem trajectoryProjection_homomorphism_laws
    (resolve : KernelExpr → Store → Location) :
    trajectoryProjection resolve [] =
      emptyTrajectory resolve
    ∧
    ∀ xs ys : List KernelExprContext,
      trajectoryProjection resolve (xs ++ ys) =
        composeTrajectory resolve
          (trajectoryProjection resolve xs)
          (trajectoryProjection resolve ys) := by
  constructor
  · exact trajectoryProjection_nil resolve
  · intro xs ys
    exact trajectoryProjection_append resolve xs ys

#check trajectoryProjection_homomorphism_laws


theorem composition_descends_to_equivalence_classes
    (resolve : KernelExpr → Store → Location)
    {xs xs' ys ys' : List KernelExprContext}
    (hx : HistoricalEquivalent resolve xs xs')
    (hy : HistoricalEquivalent resolve ys ys') :
    HistoricalEquivalent resolve
      (xs ++ ys)
      (xs' ++ ys') := by
  exact historicalEquivalent_append_congr resolve hx hy

#check composition_descends_to_equivalence_classes


theorem quotient_composition_well_defined
    (resolve : KernelExpr → Store → Location)
    {xs xs' ys ys' : List KernelExprContext}
    (hx : HistoricalEquivalent resolve xs xs')
    (hy : HistoricalEquivalent resolve ys ys') :
    composeTrajectory resolve
      (toTrajectoryBoundary resolve xs)
      (toTrajectoryBoundary resolve ys)
    =
    composeTrajectory resolve
      (toTrajectoryBoundary resolve xs')
      (toTrajectoryBoundary resolve ys') := by
  rw [← toTrajectoryBoundary_append, ← toTrajectoryBoundary_append]
  exact historicalEquivalent_append_congr resolve hx hy

#check quotient_composition_well_defined


structure QuotientMonoidTheorem
    (resolve : KernelExpr → Store → Location) : Prop where

  congruence :
    ∀ {xs xs' ys ys' : List KernelExprContext},
      HistoricalEquivalent resolve xs xs' →
      HistoricalEquivalent resolve ys ys' →
      HistoricalEquivalent resolve
        (xs ++ ys)
        (xs' ++ ys')

  projection_identity :
    trajectoryProjection resolve [] =
      emptyTrajectory resolve

  projection_composition :
    ∀ xs ys : List KernelExprContext,
      trajectoryProjection resolve (xs ++ ys) =
        composeTrajectory resolve
          (trajectoryProjection resolve xs)
          (trajectoryProjection resolve ys)

  quotient_left_identity :
    ∀ t : TrajectoryBoundary resolve,
      composeTrajectory resolve
        (emptyTrajectory resolve) t = t

  quotient_right_identity :
    ∀ t : TrajectoryBoundary resolve,
      composeTrajectory resolve
        t (emptyTrajectory resolve) = t

  quotient_associativity :
    ∀ a b c : TrajectoryBoundary resolve,
      composeTrajectory resolve
        (composeTrajectory resolve a b) c =
      composeTrajectory resolve a
        (composeTrajectory resolve b c)

#check QuotientMonoidTheorem


theorem trajectoryBoundary_is_quotient_monoid
    (resolve : KernelExpr → Store → Location) :
    QuotientMonoidTheorem resolve := by
  refine {
    congruence := ?_
    projection_identity := trajectoryProjection_nil resolve
    projection_composition := trajectoryProjection_append resolve
    quotient_left_identity := composeTrajectory_id_left resolve
    quotient_right_identity := composeTrajectory_id_right resolve
    quotient_associativity := composeTrajectory_assoc resolve
  }
  intro xs xs' ys ys' hx hy
  exact historicalEquivalent_append_congr resolve hx hy

#check trajectoryBoundary_is_quotient_monoid


def RespectsHistoricalEquivalent
    (resolve : KernelExpr → Store → Location)
    {O : Type}
    (f : List KernelExprContext → O) : Prop :=
  ∀ xs ys,
    HistoricalEquivalent resolve xs ys →
    f xs = f ys

#check RespectsHistoricalEquivalent


theorem trajectoryProjection_surjective
    (resolve : KernelExpr → Store → Location)
    (t : TrajectoryBoundary resolve) :
    ∃ xs : List KernelExprContext,
      trajectoryProjection resolve xs = t := by
  induction t using Quotient.ind with
  | _ xs =>
    exact ⟨xs, rfl⟩

theorem trajectoryBoundary_universal_property
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (f : List KernelExprContext → O) :
    RespectsHistoricalEquivalent resolve f ↔
    ∃ fbar : TrajectoryBoundary resolve → O,
      (∀ xs,
        fbar (trajectoryProjection resolve xs) = f xs) ∧
      ∀ g : TrajectoryBoundary resolve → O,
        (∀ xs,
          g (trajectoryProjection resolve xs) = f xs) →
        g = fbar := by
  constructor
  · intro hRespects
    refine ⟨fun t => f (Classical.choose (trajectoryProjection_surjective resolve t)), ?_⟩
    constructor
    · intro xs
      have hEq :
          trajectoryProjection resolve
            (Classical.choose
              (trajectoryProjection_surjective resolve
                (trajectoryProjection resolve xs)))
          =
          trajectoryProjection resolve xs :=
        Classical.choose_spec
          (trajectoryProjection_surjective resolve
            (trajectoryProjection resolve xs))
      exact hRespects _ _ hEq
    · intro g hg
      funext t
      rcases trajectoryProjection_surjective resolve t with ⟨xs, rfl⟩
      calc
        g (trajectoryProjection resolve xs)
            = f xs := hg xs
        _ = f (Classical.choose
              (trajectoryProjection_surjective resolve
                (trajectoryProjection resolve xs))) :=
          (hRespects _ _
            (Classical.choose_spec
              (trajectoryProjection_surjective resolve
                (trajectoryProjection resolve xs)))).symm
  · rintro ⟨fbar, hf, _⟩
    intro xs ys hEq
    calc
      f xs
          = fbar (trajectoryProjection resolve xs) := (hf xs).symm
      _ = fbar (trajectoryProjection resolve ys) := by
          unfold trajectoryProjection
          rw [hEq]
      _ = f ys := hf ys

#check trajectoryBoundary_universal_property


def factorThroughTrajectoryBoundary
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (f : List KernelExprContext → O)
    (h : RespectsHistoricalEquivalent resolve f) :
    TrajectoryBoundary resolve → O :=
  Quotient.lift f
    (by
      intro xs ys hxy
      apply h xs ys
      exact Quotient.sound hxy)

#check factorThroughTrajectoryBoundary


theorem factorisation_unique
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (f : List KernelExprContext → O)
    (h : RespectsHistoricalEquivalent resolve f)
    (g₁ g₂ : TrajectoryBoundary resolve → O)
    (hg₁ : ∀ xs, g₁ (trajectoryProjection resolve xs) = f xs)
    (hg₂ : ∀ xs, g₂ (trajectoryProjection resolve xs) = f xs) :
    g₁ = g₂ := by
  funext t
  rcases trajectoryProjection_surjective resolve t with ⟨xs, rfl⟩
  calc
    g₁ (trajectoryProjection resolve xs)
        = f xs := hg₁ xs
    _ = g₂ (trajectoryProjection resolve xs) := (hg₂ xs).symm

#check factorisation_unique


theorem factorisation_preserves_composition
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (f : List KernelExprContext → O)
    (hRespect : RespectsHistoricalEquivalent resolve f)
    (mulO : O → O → O)
    (hMul :
      ∀ xs ys,
        f (xs ++ ys) =
        mulO (f xs) (f ys))
    (a b : TrajectoryBoundary resolve) :
    factorThroughTrajectoryBoundary resolve f hRespect
      (composeTrajectory resolve a b)
    =
    mulO
      (factorThroughTrajectoryBoundary resolve f hRespect a)
      (factorThroughTrajectoryBoundary resolve f hRespect b) := by
  induction a using Quotient.ind with
  | _ xs =>
    induction b using Quotient.ind with
    | _ ys =>
      change f (xs ++ ys) = mulO (f xs) (f ys)
      exact hMul xs ys

#check factorisation_preserves_composition


theorem factorisation_preserves_identity
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (f : List KernelExprContext → O)
    (hRespect : RespectsHistoricalEquivalent resolve f)
    (oneO : O)
    (hOne : f [] = oneO) :
    factorThroughTrajectoryBoundary resolve f hRespect
      (emptyTrajectory resolve)
    =
    oneO := by
  change f [] = oneO
  exact hOne

#check factorisation_preserves_identity


theorem factorisation_preserves_monoid_structure
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (f : List KernelExprContext → O)
    (hRespect : RespectsHistoricalEquivalent resolve f)
    (mulO : O → O → O)
    (oneO : O)
    (hOne : f [] = oneO)
    (hMul : ∀ xs ys, f (xs ++ ys) = mulO (f xs) (f ys)) :
    factorThroughTrajectoryBoundary resolve f hRespect
      (emptyTrajectory resolve) = oneO
    ∧
    ∀ a b,
      factorThroughTrajectoryBoundary resolve f hRespect
        (composeTrajectory resolve a b)
      =
      mulO
        (factorThroughTrajectoryBoundary resolve f hRespect a)
        (factorThroughTrajectoryBoundary resolve f hRespect b) := by
  constructor
  · exact factorisation_preserves_identity resolve f hRespect oneO hOne
  · intro a b
    exact factorisation_preserves_composition resolve f hRespect mulO hMul a b

#check factorisation_preserves_monoid_structure


theorem trajectoryBoundary_universal_quotient
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (f : List KernelExprContext → O)
    (hRespect : RespectsHistoricalEquivalent resolve f)
    (mulO : O → O → O)
    (oneO : O)
    (hOne : f [] = oneO)
    (hMul :
      ∀ xs ys,
        f (xs ++ ys) =
          mulO (f xs) (f ys)) :
    ∃ fbar : TrajectoryBoundary resolve → O,
      (∀ xs,
        fbar (trajectoryProjection resolve xs) = f xs)
      ∧
      fbar (emptyTrajectory resolve) = oneO
      ∧
      (∀ a b,
        fbar (composeTrajectory resolve a b) =
          mulO (fbar a) (fbar b))
      ∧
      ∀ g : TrajectoryBoundary resolve → O,
        (∀ xs,
          g (trajectoryProjection resolve xs) = f xs)
        ∧
        g (emptyTrajectory resolve) = oneO
        ∧
        (∀ a b,
          g (composeTrajectory resolve a b) =
            mulO (g a) (g b))
        →
        g = fbar := by

  let fbar :=
    factorThroughTrajectoryBoundary resolve f hRespect

  refine ⟨fbar, ?_, ?_, ?_, ?_⟩

  · intro xs
    rfl

  · exact (factorisation_preserves_monoid_structure
      resolve f hRespect mulO oneO hOne hMul).1

  · intro a b
    exact (factorisation_preserves_monoid_structure
      resolve f hRespect mulO oneO hOne hMul).2 a b

  · intro g hg
    apply factorisation_unique
      resolve f hRespect g fbar

    · intro xs
      exact hg.1 xs

    · intro xs
      rfl

#check trajectoryBoundary_universal_quotient


def FoldPreserved
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (obs : List KernelExprContext → O) : Prop :=
  ∀ xs ys,
    HistoricalEquivalent resolve xs ys →
    obs xs = obs ys

structure FoldPreservedStructure
    (resolve : KernelExpr → Store → Location) where

  -- The folded state
  boundary :
    Type

  -- Raw history enters the fold
  project :
    List KernelExprContext → boundary

  -- Folded identity
  one :
    boundary

  -- Folded composition
  mul :
    boundary → boundary → boundary

  -- Equivalent histories occupy the same folded position
  identifies_equivalent :
    ∀ {xs ys},
      HistoricalEquivalent resolve xs ys →
      project xs = project ys

  -- Identity survives the fold
  preserves_identity :
    project [] = one

  -- Composition survives the fold
  preserves_composition :
    ∀ xs ys,
      project (xs ++ ys) =
        mul (project xs) (project ys)

  -- Folded composition remains lawful
  left_identity :
    ∀ q, mul one q = q

  right_identity :
    ∀ q, mul q one = q

  associativity :
    ∀ a b c,
      mul (mul a b) c =
        mul a (mul b c)

def trajectoryFoldPreservedStructure
    (resolve : KernelExpr → Store → Location) :
    FoldPreservedStructure resolve :=
{
  boundary := TrajectoryBoundary resolve

  project := trajectoryProjection resolve

  one := emptyTrajectory resolve

  mul := composeTrajectory resolve

  identifies_equivalent := by
    intro xs ys h
    exact h

  preserves_identity :=
    trajectoryProjection_nil resolve

  preserves_composition :=
    trajectoryProjection_append resolve

  left_identity :=
    composeTrajectory_id_left resolve

  right_identity :=
    composeTrajectory_id_right resolve

  associativity :=
    composeTrajectory_assoc resolve
}

#check trajectoryFoldPreservedStructure


/-! ============================================================
    TEST 1 — Compatible target fold algebra
============================================================ -/

structure CompatibleTargetFold
    (resolve : KernelExpr → Store → Location) where
  O : Type
  oneO : O
  mulO : O → O → O
  f : List KernelExprContext → O
  respects : RespectsHistoricalEquivalent resolve f
  identity_law : f [] = oneO
  composition_law :
    ∀ xs ys,
      f (xs ++ ys) = mulO (f xs) (f ys)

/-! ============================================================
    TEST 2 — Canonical descended map
============================================================ -/

def descend
    {resolve : KernelExpr → Store → Location}
    (T : CompatibleTargetFold resolve) :
    TrajectoryBoundary resolve → T.O :=
  factorThroughTrajectoryBoundary
    resolve
    T.f
    T.respects

theorem descend_recovers
    {resolve : KernelExpr → Store → Location}
    (T : CompatibleTargetFold resolve)
    (xs : List KernelExprContext) :
    descend T (trajectoryProjection resolve xs) = T.f xs := by
  rfl

/-! ============================================================
    TEST 3 — Preserved identity
============================================================ -/

theorem descend_preserves_identity
    {resolve : KernelExpr → Store → Location}
    (T : CompatibleTargetFold resolve) :
    descend T (emptyTrajectory resolve) = T.oneO := by
  change T.f [] = T.oneO
  exact T.identity_law

/-! ============================================================
    TEST 4 — Preserved composition
============================================================ -/

theorem descend_preserves_composition
    {resolve : KernelExpr → Store → Location}
    (T : CompatibleTargetFold resolve)
    (a b : TrajectoryBoundary resolve) :
    descend T (composeTrajectory resolve a b)
    =
    T.mulO (descend T a) (descend T b) := by
  exact factorisation_preserves_composition
    resolve
    T.f
    T.respects
    T.mulO
    T.composition_law
    a
    b

/-! ============================================================
    TEST 5 — Uniqueness
============================================================ -/

theorem descend_unique
    {resolve : KernelExpr → Store → Location}
    (T : CompatibleTargetFold resolve)
    (g : TrajectoryBoundary resolve → T.O)
    (hg_recover :
      ∀ xs,
        g (trajectoryProjection resolve xs) = T.f xs)
    (hg_id :
      g (emptyTrajectory resolve) = T.oneO)
    (hg_mul :
      ∀ a b,
        g (composeTrajectory resolve a b)
        =
        T.mulO (g a) (g b)) :
    g = descend T := by
  apply factorisation_unique
    resolve
    T.f
    T.respects
    g
    (descend T)
  · intro xs
    exact hg_recover xs
  · intro xs
    rfl

/-! ============================================================
    TEST 6 — Package the result
============================================================ -/

structure UniversalFoldPreservedStructure
    (resolve : KernelExpr → Store → Location) where
  fold : FoldPreservedStructure resolve
  descent :
    ∀ T : CompatibleTargetFold resolve,
      TrajectoryBoundary resolve → T.O
  recovery :
    ∀ T : CompatibleTargetFold resolve,
    ∀ xs,
      descent T (trajectoryProjection resolve xs) = T.f xs
  identity_preservation :
    ∀ T : CompatibleTargetFold resolve,
      descent T (emptyTrajectory resolve) = T.oneO
  composition_preservation :
    ∀ T : CompatibleTargetFold resolve,
    ∀ a b,
      descent T (composeTrajectory resolve a b)
      =
      T.mulO (descent T a) (descent T b)
  uniqueness :
    ∀ T : CompatibleTargetFold resolve,
    ∀ g : TrajectoryBoundary resolve → T.O,
      (∀ xs, g (trajectoryProjection resolve xs) = T.f xs)
      ∧
      g (emptyTrajectory resolve) = T.oneO
      ∧
      (∀ a b, g (composeTrajectory resolve a b) = T.mulO (g a) (g b))
      →
      g = descent T

def trajectoryUniversalFoldPreservedStructure
    (resolve : KernelExpr → Store → Location) :
    UniversalFoldPreservedStructure resolve :=
{
  fold := trajectoryFoldPreservedStructure resolve
  descent := fun T => descend T
  recovery := by
    intro T xs
    exact descend_recovers T xs
  identity_preservation := by
    intro T
    exact descend_preserves_identity T
  composition_preservation := by
    intro T a b
    exact descend_preserves_composition T a b
  uniqueness := by
    intro T g hg
    exact descend_unique T g hg.1 hg.2.1 hg.2.2
}

theorem universal_fold_does_not_imply_raw_recovery
    (resolve : KernelExpr → Store → Location) :
    (∃ U : UniversalFoldPreservedStructure resolve, True)
    ∧
    ¬ RawHistoryRecoverable resolve := by
  exact ⟨
    ⟨trajectoryUniversalFoldPreservedStructure resolve, trivial⟩,
    raw_history_not_recoverable resolve
  ⟩

#check CompatibleTargetFold
#check descend
#check descend_recovers
#check descend_preserves_identity
#check descend_preserves_composition
#check descend_unique
#check UniversalFoldPreservedStructure
#check trajectoryUniversalFoldPreservedStructure
#check universal_fold_does_not_imply_raw_recovery


/-! ============================================================
    TEST 1 — Second fold
============================================================ -/

structure SecondFold
    (resolve : KernelExpr → Store → Location) where
  B : Type
  secondProject : TrajectoryBoundary resolve → B
  secondOne : B
  secondMul : B → B → B
  identity_law :
    secondProject (emptyTrajectory resolve) = secondOne
  composition_law :
    ∀ a b,
      secondProject (composeTrajectory resolve a b)
      =
      secondMul (secondProject a) (secondProject b)

/-! ============================================================
    TEST 2 — Composite raw projection
============================================================ -/

def compositeProject
    {resolve : KernelExpr → Store → Location}
    (S : SecondFold resolve)
    (xs : List KernelExprContext) : S.B :=
  S.secondProject (trajectoryProjection resolve xs)

theorem compositeProject_identity
    {resolve : KernelExpr → Store → Location}
    (S : SecondFold resolve) :
    compositeProject S [] = S.secondOne := by
  change S.secondProject (trajectoryProjection resolve []) = S.secondOne
  rw [trajectoryProjection_nil]
  exact S.identity_law

theorem compositeProject_composition
    {resolve : KernelExpr → Store → Location}
    (S : SecondFold resolve)
    (xs ys : List KernelExprContext) :
    compositeProject S (xs ++ ys)
    =
    S.secondMul (compositeProject S xs) (compositeProject S ys) := by
  change
    S.secondProject (trajectoryProjection resolve (xs ++ ys))
    =
    S.secondMul
      (S.secondProject (trajectoryProjection resolve xs))
      (S.secondProject (trajectoryProjection resolve ys))
  rw [trajectoryProjection_append]
  exact S.composition_law
    (trajectoryProjection resolve xs)
    (trajectoryProjection resolve ys)

/-! ============================================================
    TEST 3 — Historical-equivalence preservation
============================================================ -/

theorem compositeProject_respects_historical
    {resolve : KernelExpr → Store → Location}
    (S : SecondFold resolve)
    {xs ys : List KernelExprContext}
    (h : HistoricalEquivalent resolve xs ys) :
    compositeProject S xs = compositeProject S ys := by
  change
    S.secondProject (trajectoryProjection resolve xs)
    =
    S.secondProject (trajectoryProjection resolve ys)
  unfold trajectoryProjection
  rw [h]

/-! ============================================================
    TEST 4 — Direct factorisation
============================================================ -/

def secondFoldTarget
    {resolve : KernelExpr → Store → Location}
    (S : SecondFold resolve) :
    CompatibleTargetFold resolve :=
{
  O := S.B
  oneO := S.secondOne
  mulO := S.secondMul
  f := compositeProject S
  respects := by
    intro xs ys h
    exact compositeProject_respects_historical S h
  identity_law := compositeProject_identity S
  composition_law := compositeProject_composition S
}

def directDescend
    {resolve : KernelExpr → Store → Location}
    (S : SecondFold resolve) :
    TrajectoryBoundary resolve → S.B :=
  descend (secondFoldTarget S)

theorem directDescend_recovers
    {resolve : KernelExpr → Store → Location}
    (S : SecondFold resolve)
    (xs : List KernelExprContext) :
    directDescend S (trajectoryProjection resolve xs)
    =
    compositeProject S xs := by
  rfl

theorem directDescend_eq_secondProject
    {resolve : KernelExpr → Store → Location}
    (S : SecondFold resolve) :
    directDescend S = S.secondProject := by
  symm
  apply descend_unique
    (secondFoldTarget S)
    S.secondProject
  · intro xs
    rfl
  · exact S.identity_law
  · exact S.composition_law

/-! ============================================================
    TEST 5 — Fold-of-fold coherence
============================================================ -/

theorem fold_of_fold_coherence
    {resolve : KernelExpr → Store → Location}
    (S : SecondFold resolve) :
    S.secondProject
    =
    directDescend S := by
  exact (directDescend_eq_secondProject S).symm

/-! ============================================================
    TEST 6 — No restoration of erased history
============================================================ -/

theorem second_fold_does_not_restore_raw_history
    (resolve : KernelExpr → Store → Location) :
    (∃ S : SecondFold resolve, True)
    ∧
    ¬ RawHistoryRecoverable resolve := by
  refine ⟨?_, raw_history_not_recoverable resolve⟩
  exact ⟨
    {
      B := TrajectoryBoundary resolve
      secondProject := id
      secondOne := emptyTrajectory resolve
      secondMul := composeTrajectory resolve
      identity_law := rfl
      composition_law := fun _ _ => rfl
    },
    trivial
  ⟩

/-! ============================================================
    TEST 7 — Associativity of fold descent
============================================================ -/

structure ThirdFold
    {resolve : KernelExpr → Store → Location}
    (S : SecondFold resolve) where
  C : Type
  thirdProject : S.B → C
  thirdOne : C
  thirdMul : C → C → C
  identity_law :
    thirdProject S.secondOne = thirdOne
  composition_law :
    ∀ x y,
      thirdProject (S.secondMul x y)
      =
      thirdMul (thirdProject x) (thirdProject y)

def stepwiseComposite
    {resolve : KernelExpr → Store → Location}
    {S : SecondFold resolve}
    (T : ThirdFold S)
    (xs : List KernelExprContext) : T.C :=
  T.thirdProject (compositeProject S xs)

def directCompositeTarget
    {resolve : KernelExpr → Store → Location}
    {S : SecondFold resolve}
    (T : ThirdFold S) :
    CompatibleTargetFold resolve :=
{
  O := T.C
  oneO := T.thirdOne
  mulO := T.thirdMul
  f := stepwiseComposite T
  respects := by
    intro xs ys h
    change
      T.thirdProject (compositeProject S xs)
      =
      T.thirdProject (compositeProject S ys)
    rw [compositeProject_respects_historical S h]
  identity_law := by
    change T.thirdProject (compositeProject S []) = T.thirdOne
    rw [compositeProject_identity]
    exact T.identity_law
  composition_law := by
    intro xs ys
    change
      T.thirdProject (compositeProject S (xs ++ ys))
      =
      T.thirdMul
        (T.thirdProject (compositeProject S xs))
        (T.thirdProject (compositeProject S ys))
    rw [compositeProject_composition]
    exact T.composition_law
      (compositeProject S xs)
      (compositeProject S ys)
}

theorem fold_descent_associativity
    {resolve : KernelExpr → Store → Location}
    {S : SecondFold resolve}
    (T : ThirdFold S) :
    descend (directCompositeTarget T)
    =
    fun q => T.thirdProject (directDescend S q) := by
  symm
  apply descend_unique
    (directCompositeTarget T)
    (fun q => T.thirdProject (directDescend S q))
  · intro xs
    show
      T.thirdProject (directDescend S (trajectoryProjection resolve xs))
      =
      stepwiseComposite T xs
    rw [directDescend_recovers]
    rfl
  · show
      T.thirdProject (directDescend S (emptyTrajectory resolve))
      =
      T.thirdOne
    have h :
        directDescend S (emptyTrajectory resolve) = S.secondOne := by
      rw [directDescend_eq_secondProject]
      exact S.identity_law
    rw [h]
    exact T.identity_law
  · intro a b
    show
      T.thirdProject
        (directDescend S (composeTrajectory resolve a b))
      =
      T.thirdMul
        (T.thirdProject (directDescend S a))
        (T.thirdProject (directDescend S b))
    rw [directDescend_eq_secondProject]
    rw [S.composition_law a b]
    exact T.composition_law
      (S.secondProject a)
      (S.secondProject b)

#check SecondFold
#check compositeProject
#check compositeProject_identity
#check compositeProject_composition
#check compositeProject_respects_historical
#check directDescend
#check directDescend_eq_secondProject
#check fold_of_fold_coherence
#check second_fold_does_not_restore_raw_history
#check ThirdFold
#check fold_descent_associativity


/-! ============================================================
    Finite compatible fold chains
============================================================ -/

/--
A type-safe finite chain of maps beginning at TrajectoryBoundary,
indexed by the terminal carrier.
-/
inductive FoldChain
    (resolve : KernelExpr → Store → Location) :
    Type → Type 1 where
  | nil :
      FoldChain resolve (TrajectoryBoundary resolve)
  | cons
      {B C : Type}
      (prev : FoldChain resolve B)
      (project : B → C) :
      FoldChain resolve C

/--
Stepwise fold along a chain.
-/
def stepwiseFold
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    : FoldChain resolve C → TrajectoryBoundary resolve → C
  | .nil => id
  | .cons prev project =>
      fun q => project (stepwiseFold prev q)

/--
Composite raw-history observable.
-/
def compositeRaw
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    (chain : FoldChain resolve C)
    (xs : List KernelExprContext) : C :=
  stepwiseFold chain (trajectoryProjection resolve xs)

theorem compositeRaw_respects_historical
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    (chain : FoldChain resolve C)
    {xs ys : List KernelExprContext}
    (h : HistoricalEquivalent resolve xs ys) :
    compositeRaw chain xs = compositeRaw chain ys := by
  change
    stepwiseFold chain (trajectoryProjection resolve xs)
    =
    stepwiseFold chain (trajectoryProjection resolve ys)
  unfold trajectoryProjection
  rw [h]

/--
A chain is compatible when the composite raw map is a monoid
homomorphism into some monoid on the terminal carrier.
-/
def IsCompatible
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    (chain : FoldChain resolve C) : Prop :=
  ∃ one : C, ∃ mul : C → C → C,
    compositeRaw chain [] = one
    ∧
    ∀ xs ys,
      compositeRaw chain (xs ++ ys)
      =
      mul (compositeRaw chain xs) (compositeRaw chain ys)

/--
Composition law for stepwiseFold, reduced via surjectivity.
-/
theorem stepwiseFold_composition
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    (chain : FoldChain resolve C)
    (hComp : IsCompatible chain)
    (a b : TrajectoryBoundary resolve) :
    ∃ mul : C → C → C,
      stepwiseFold chain (composeTrajectory resolve a b)
      =
      mul (stepwiseFold chain a) (stepwiseFold chain b) := by
  rcases trajectoryProjection_surjective resolve a with ⟨xs, rfl⟩
  rcases trajectoryProjection_surjective resolve b with ⟨ys, rfl⟩
  rcases hComp with ⟨one, mul, hOne, hMul⟩
  refine ⟨mul, ?_⟩
  change
    stepwiseFold chain (composeTrajectory resolve
      (trajectoryProjection resolve xs)
      (trajectoryProjection resolve ys))
    =
    mul
      (stepwiseFold chain (trajectoryProjection resolve xs))
      (stepwiseFold chain (trajectoryProjection resolve ys))
  rw [← trajectoryProjection_append]
  exact hMul xs ys

theorem finite_fold_coherence
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    (chain : FoldChain resolve C)
    (hComp : IsCompatible chain) :
    ∃ fbar : TrajectoryBoundary resolve → C,
      (∀ xs, fbar (trajectoryProjection resolve xs) = compositeRaw chain xs)
      ∧
      fbar = stepwiseFold chain := by
  rcases hComp with ⟨one, mul, hOne, hMul⟩
  let T : CompatibleTargetFold resolve :=
  {
    O := C
    oneO := one
    mulO := mul
    f := compositeRaw chain
    respects := by
      intro xs ys h
      exact compositeRaw_respects_historical chain h
    identity_law := hOne
    composition_law := hMul
  }
  refine ⟨descend T, ?_, ?_⟩
  · intro xs
    rfl
  · symm
    apply descend_unique T (stepwiseFold chain)
    · intro xs
      rfl
    · exact hOne
    · intro a b
      rcases trajectoryProjection_surjective resolve a with ⟨xs, rfl⟩
      rcases trajectoryProjection_surjective resolve b with ⟨ys, rfl⟩
      change
        stepwiseFold chain (composeTrajectory resolve
          (trajectoryProjection resolve xs)
          (trajectoryProjection resolve ys))
        =
        mul
          (stepwiseFold chain (trajectoryProjection resolve xs))
          (stepwiseFold chain (trajectoryProjection resolve ys))
      rw [← trajectoryProjection_append]
      exact hMul xs ys

/--
Zero additional folds is the identity (definitional).
-/
theorem finite_fold_coherence_zero
    (resolve : KernelExpr → Store → Location) :
    stepwiseFold (FoldChain.nil : FoldChain resolve (TrajectoryBoundary resolve))
    =
    id := by
  rfl

/--
One additional fold is compatible when the second fold is.
-/
theorem finite_fold_coherence_one
    {resolve : KernelExpr → Store → Location}
    (S : SecondFold resolve) :
    IsCompatible (FoldChain.cons FoldChain.nil S.secondProject) := by
  refine ⟨S.secondOne, S.secondMul, ?_, ?_⟩
  · change S.secondProject (trajectoryProjection resolve []) = S.secondOne
    rw [trajectoryProjection_nil]
    exact S.identity_law
  · intro xs ys
    change
      S.secondProject (trajectoryProjection resolve (xs ++ ys))
      =
      S.secondMul
        (S.secondProject (trajectoryProjection resolve xs))
        (S.secondProject (trajectoryProjection resolve ys))
    rw [trajectoryProjection_append]
    exact S.composition_law
      (trajectoryProjection resolve xs)
      (trajectoryProjection resolve ys)

/--
Two additional folds are compatible when the third fold is.
-/
theorem finite_fold_coherence_two
    {resolve : KernelExpr → Store → Location}
    {S : SecondFold resolve}
    (T : ThirdFold S) :
    IsCompatible
      (FoldChain.cons
        (FoldChain.cons FoldChain.nil S.secondProject)
        T.thirdProject) := by
  refine ⟨T.thirdOne, T.thirdMul, ?_, ?_⟩
  · change
      T.thirdProject (S.secondProject (trajectoryProjection resolve []))
      =
      T.thirdOne
    rw [trajectoryProjection_nil]
    rw [S.identity_law]
    exact T.identity_law
  · intro xs ys
    change
      T.thirdProject
        (S.secondProject (trajectoryProjection resolve (xs ++ ys)))
      =
      T.thirdMul
        (T.thirdProject (S.secondProject (trajectoryProjection resolve xs)))
        (T.thirdProject (S.secondProject (trajectoryProjection resolve ys)))
    rw [trajectoryProjection_append]
    rw [S.composition_law]
    exact T.composition_law
      (S.secondProject (trajectoryProjection resolve xs))
      (S.secondProject (trajectoryProjection resolve ys))

/--
Compatible finite chains do not restore raw-history recoverability.
-/
theorem finite_fold_chain_does_not_restore_raw_history
    (resolve : KernelExpr → Store → Location) :
    (∃ C : Type, ∃ chain : FoldChain resolve C, IsCompatible chain)
    ∧
    ¬ RawHistoryRecoverable resolve := by
  exact ⟨
    ⟨TrajectoryBoundary resolve, FoldChain.nil,
      ⟨emptyTrajectory resolve, composeTrajectory resolve,
        trajectoryProjection_nil resolve,
        fun xs ys => trajectoryProjection_append resolve xs ys⟩⟩,
    raw_history_not_recoverable resolve
  ⟩

#check FoldChain
#check stepwiseFold
#check compositeRaw
#check IsCompatible
#check compositeRaw_respects_historical
#check stepwiseFold_composition
#check finite_fold_coherence
#check finite_fold_coherence_zero
#check finite_fold_coherence_one
#check finite_fold_coherence_two
#check finite_fold_chain_does_not_restore_raw_history


/-! ============================================================
    PART A — Arbitrary-chain no-restoration
============================================================ -/

def RawHistoryRecoverableFromChain
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    (chain : FoldChain resolve C) : Prop :=
  ∃ decode : C → List KernelExprContext,
    ∀ xs : List KernelExprContext,
      decode (compositeRaw chain xs) = xs

theorem foldChain_respects_historical
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    (chain : FoldChain resolve C)
    {xs ys : List KernelExprContext}
    (h : HistoricalEquivalent resolve xs ys) :
    compositeRaw chain xs = compositeRaw chain ys :=
  compositeRaw_respects_historical chain h

theorem arbitrary_fold_chain_cannot_restore_raw_history
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    (chain : FoldChain resolve C) :
    ¬ RawHistoryRecoverableFromChain chain := by
  intro ⟨decode, hDecode⟩
  have hEmpty :
      decode (compositeRaw chain []) = [] :=
    hDecode []
  have hSwap :
      decode (compositeRaw chain [swapContext, swapContext])
      =
      [swapContext, swapContext] :=
    hDecode [swapContext, swapContext]
  have hSame :
      compositeRaw chain []
      =
      compositeRaw chain [swapContext, swapContext] := by
    apply foldChain_respects_historical
    show
      toTrajectoryBoundary resolve []
      =
      toTrajectoryBoundary resolve [swapContext, swapContext]
    rw [swap_pair_equals_empty_trajectory]
    rfl
  rw [hSame] at hEmpty
  have hContra :
      [] = [swapContext, swapContext] := by
    calc
      [] = decode (compositeRaw chain [swapContext, swapContext]) := hEmpty.symm
      _ = [swapContext, swapContext] := hSwap
  injection hContra

/-! ============================================================
    PART B — Local monoid and certified fold step
============================================================ -/

structure LocalMonoid (A : Type) where
  one : A
  mul : A → A → A
  one_mul : ∀ a, mul one a = a
  mul_one : ∀ a, mul a one = a
  mul_assoc :
    ∀ a b c,
      mul (mul a b) c =
      mul a (mul b c)

structure CompatibleFoldStep
    (B C : Type) where
  source : LocalMonoid B
  target : LocalMonoid C
  project : B → C
  preserves_identity :
    project source.one =
    target.one
  preserves_composition :
    ∀ x y,
      project (source.mul x y) =
      target.mul (project x) (project y)


/-! ============================================================
    PART C — Certified fold chain
============================================================ -/

def trajectoryLocalMonoid
    (resolve : KernelExpr → Store → Location) :
    LocalMonoid (TrajectoryBoundary resolve) :=
{
  one := emptyTrajectory resolve
  mul := composeTrajectory resolve
  one_mul := composeTrajectory_id_left resolve
  mul_one := composeTrajectory_id_right resolve
  mul_assoc := composeTrajectory_assoc resolve
}

/--
A certified fold chain carries the current terminal monoid
in its index so that each step's source is definitionally
the previous terminal.
-/
inductive CertifiedFoldChain
    (resolve : KernelExpr → Store → Location) :
    (C : Type) → LocalMonoid C → Type 1 where
  | nil :
      CertifiedFoldChain resolve
        (TrajectoryBoundary resolve)
        (trajectoryLocalMonoid resolve)
  | cons
      {B C : Type}
      {M : LocalMonoid B}
      (prev : CertifiedFoldChain resolve B M)
      (step : CompatibleFoldStep B C)
      (hSource : step.source = M) :
      CertifiedFoldChain resolve C step.target

def terminalOne
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (_chain : CertifiedFoldChain resolve C M) : C :=
  M.one

def terminalMul
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (_chain : CertifiedFoldChain resolve C M) : C → C → C :=
  M.mul

/-! ============================================================
    PART D — Stepwise certified fold
============================================================ -/

def certifiedStepwiseFold
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    : CertifiedFoldChain resolve C M → TrajectoryBoundary resolve → C
  | .nil => id
  | .cons prev step hSource =>
      fun q => step.project (certifiedStepwiseFold prev q)

theorem certifiedStepwiseFold_identity
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (chain : CertifiedFoldChain resolve C M) :
    certifiedStepwiseFold chain (emptyTrajectory resolve)
    =
    terminalOne chain := by
  induction chain with
  | nil =>
    rfl
  | cons prev step hSource ih =>
    show
      step.project (certifiedStepwiseFold prev (emptyTrajectory resolve))
      =
      step.target.one
    rw [ih]
    cases hSource
    exact step.preserves_identity

theorem certifiedStepwiseFold_composition
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (chain : CertifiedFoldChain resolve C M)
    (a b : TrajectoryBoundary resolve) :
    certifiedStepwiseFold chain (composeTrajectory resolve a b)
    =
    terminalMul chain
      (certifiedStepwiseFold chain a)
      (certifiedStepwiseFold chain b) := by
  induction chain with
  | nil =>
    rfl
  | cons prev step hSource ih =>
    show
      step.project
        (certifiedStepwiseFold prev (composeTrajectory resolve a b))
      =
      step.target.mul
        (step.project (certifiedStepwiseFold prev a))
        (step.project (certifiedStepwiseFold prev b))
    rw [ih]
    cases hSource
    exact step.preserves_composition
      (certifiedStepwiseFold prev a)
      (certifiedStepwiseFold prev b)

/-! ============================================================
    PART E — Raw composite and unique descent
============================================================ -/

def certifiedCompositeRaw
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (chain : CertifiedFoldChain resolve C M)
    (xs : List KernelExprContext) : C :=
  certifiedStepwiseFold chain (trajectoryProjection resolve xs)

theorem certifiedCompositeRaw_respects_historical
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (chain : CertifiedFoldChain resolve C M)
    {xs ys : List KernelExprContext}
    (h : HistoricalEquivalent resolve xs ys) :
    certifiedCompositeRaw chain xs = certifiedCompositeRaw chain ys := by
  show
    certifiedStepwiseFold chain (trajectoryProjection resolve xs)
    =
    certifiedStepwiseFold chain (trajectoryProjection resolve ys)
  unfold trajectoryProjection
  rw [h]

theorem certifiedCompositeRaw_identity
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (chain : CertifiedFoldChain resolve C M) :
    certifiedCompositeRaw chain [] = terminalOne chain := by
  show
    certifiedStepwiseFold chain (trajectoryProjection resolve [])
    =
    terminalOne chain
  rw [trajectoryProjection_nil]
  exact certifiedStepwiseFold_identity chain

theorem certifiedCompositeRaw_composition
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (chain : CertifiedFoldChain resolve C M)
    (xs ys : List KernelExprContext) :
    certifiedCompositeRaw chain (xs ++ ys)
    =
    terminalMul chain
      (certifiedCompositeRaw chain xs)
      (certifiedCompositeRaw chain ys) := by
  show
    certifiedStepwiseFold chain
      (trajectoryProjection resolve (xs ++ ys))
    =
    terminalMul chain
      (certifiedStepwiseFold chain (trajectoryProjection resolve xs))
      (certifiedStepwiseFold chain (trajectoryProjection resolve ys))
  rw [trajectoryProjection_append]
  exact certifiedStepwiseFold_composition chain
    (trajectoryProjection resolve xs)
    (trajectoryProjection resolve ys)

def certifiedChainTarget
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (chain : CertifiedFoldChain resolve C M) :
    CompatibleTargetFold resolve :=
{
  O := C
  oneO := terminalOne chain
  mulO := terminalMul chain
  f := certifiedCompositeRaw chain
  respects := by
    intro xs ys h
    exact certifiedCompositeRaw_respects_historical chain h
  identity_law := certifiedCompositeRaw_identity chain
  composition_law := certifiedCompositeRaw_composition chain
}

def certifiedDirectDescend
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (chain : CertifiedFoldChain resolve C M) :
    TrajectoryBoundary resolve → C :=
  descend (certifiedChainTarget chain)

theorem certified_finite_fold_coherence
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (chain : CertifiedFoldChain resolve C M) :
    certifiedDirectDescend chain = certifiedStepwiseFold chain := by
  symm
  apply descend_unique
    (certifiedChainTarget chain)
    (certifiedStepwiseFold chain)
  · intro xs
    rfl
  · exact certifiedStepwiseFold_identity chain
  · exact certifiedStepwiseFold_composition chain

/-! ============================================================
    PART F — Connection to existing folds
============================================================ -/

def secondFold_conversion_status : String :=
  "OPEN: SecondFold lacks LocalMonoid source/target laws"

def thirdFold_conversion_status : String :=
  "OPEN: ThirdFold lacks LocalMonoid source/target laws"

/-! ============================================================
    PART G — No restoration through certified chains
============================================================ -/

def RawHistoryRecoverableFromCertifiedChain
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (chain : CertifiedFoldChain resolve C M) : Prop :=
  ∃ decode : C → List KernelExprContext,
    ∀ xs : List KernelExprContext,
      decode (certifiedCompositeRaw chain xs) = xs

theorem certified_fold_chain_cannot_restore_raw_history
    {resolve : KernelExpr → Store → Location}
    {C : Type}
    {M : LocalMonoid C}
    (chain : CertifiedFoldChain resolve C M) :
    ¬ RawHistoryRecoverableFromCertifiedChain chain := by
  intro ⟨decode, hDecode⟩
  have hEmpty :
      decode (certifiedCompositeRaw chain []) = [] :=
    hDecode []
  have hSwap :
      decode (certifiedCompositeRaw chain [swapContext, swapContext])
      =
      [swapContext, swapContext] :=
    hDecode [swapContext, swapContext]
  have hSame :
      certifiedCompositeRaw chain []
      =
      certifiedCompositeRaw chain [swapContext, swapContext] := by
    apply certifiedCompositeRaw_respects_historical
    show
      toTrajectoryBoundary resolve []
      =
      toTrajectoryBoundary resolve [swapContext, swapContext]
    rw [swap_pair_equals_empty_trajectory]
    rfl
  rw [hSame] at hEmpty
  have hContra :
      [] = [swapContext, swapContext] := by
    calc
      [] = decode (certifiedCompositeRaw chain [swapContext, swapContext]) := hEmpty.symm
      _ = [swapContext, swapContext] := hSwap
  injection hContra

#check RawHistoryRecoverableFromChain
#check arbitrary_fold_chain_cannot_restore_raw_history
#check LocalMonoid
#check CompatibleFoldStep
#check CertifiedFoldChain
#check certifiedStepwiseFold
#check certifiedStepwiseFold_identity
#check certifiedStepwiseFold_composition
#check certifiedCompositeRaw
#check certifiedCompositeRaw_respects_historical
#check certified_finite_fold_coherence
#check certified_fold_chain_cannot_restore_raw_history

end KernelExprContext

namespace KernelExprContext

/-! ============================================================
    Return characterisation on the trajectory boundary
============================================================ -/

def ReturnsTo
    (resolve : KernelExpr → Store → Location)
    (xs extension : List KernelExprContext) : Prop :=
  trajectoryProjection resolve (xs ++ extension)
  =
  trajectoryProjection resolve xs

def FoldKernel
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) : Prop :=
  trajectoryProjection resolve xs =
  trajectoryProjection resolve ys

theorem returnsTo_iff_foldKernel
    (resolve : KernelExpr → Store → Location)
    (xs extension : List KernelExprContext) :
    ReturnsTo resolve xs extension
    ↔
    FoldKernel resolve (xs ++ extension) xs := by
  rfl

def NontrivialReturn
    (resolve : KernelExpr → Store → Location)
    (xs extension : List KernelExprContext) : Prop :=
  extension ≠ [] ∧
  ReturnsTo resolve xs extension

theorem nontrivial_return_exists
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    NontrivialReturn resolve xs (neutralPairs 1) := by
  constructor
  · exact neutralPairs_distinct 1 0 (by decide)
  · unfold ReturnsTo
    exact right_neutral_insertion resolve xs 1

theorem returns_to_neutral_family
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext)
    (n : Nat) :
    ReturnsTo resolve xs (neutralPairs n) := by
  unfold ReturnsTo
  exact right_neutral_insertion resolve xs n

theorem arbitrarily_long_return_extensions
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext)
    (B : Nat) :
    ∃ extension : List KernelExprContext,
      ReturnsTo resolve xs extension ∧
      extension.length > B := by
  refine ⟨neutralPairs (B + 1), ?_, ?_⟩
  · exact returns_to_neutral_family resolve xs (B + 1)
  · have hLen : (neutralPairs (B + 1)).length = 2 * (B + 1) :=
      neutralPairs_length (B + 1)
    omega

theorem distinct_raw_same_folded
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext)
    (m n : Nat)
    (h : m ≠ n) :
    xs ++ neutralPairs m ≠ xs ++ neutralPairs n
    ∧
    trajectoryProjection resolve (xs ++ neutralPairs m)
    =
    trajectoryProjection resolve (xs ++ neutralPairs n) := by
  constructor
  · exact right_insertion_injective xs m n h
  · have hM : trajectoryProjection resolve (xs ++ neutralPairs m) =
        trajectoryProjection resolve xs := by
      exact (returns_to_neutral_family resolve xs m)
    have hN : trajectoryProjection resolve (xs ++ neutralPairs n) =
        trajectoryProjection resolve xs := by
      exact (returns_to_neutral_family resolve xs n)
    rw [hM, hN]

theorem return_closure_under_concatenation
    (resolve : KernelExpr → Store → Location)
    (xs a b : List KernelExprContext)
    (ha : ReturnsTo resolve xs a)
    (hb : ReturnsTo resolve xs b) :
    ReturnsTo resolve xs (a ++ b) := by
  unfold ReturnsTo at *
  rw [← List.append_assoc]
  rw [trajectoryProjection_append]
  rw [ha]
  exact hb

theorem return_transport_right
    (resolve : KernelExpr → Store → Location)
    (xs extension suffix : List KernelExprContext)
    (h : ReturnsTo resolve xs extension) :
    FoldKernel resolve
      (xs ++ extension ++ suffix)
      (xs ++ suffix) := by
  unfold FoldKernel ReturnsTo at *
  rw [trajectoryProjection_append]
  rw [h]
  rw [← trajectoryProjection_append]

theorem return_transport_left
    (resolve : KernelExpr → Store → Location)
    (pref xs extension : List KernelExprContext)
    (h : ReturnsTo resolve xs extension) :
    FoldKernel resolve
      (pref ++ xs ++ extension)
      (pref ++ xs) := by
  unfold FoldKernel ReturnsTo at *
  -- pref ++ xs ++ extension = (pref ++ xs) ++ extension
  rw [trajectoryProjection_append]
  -- = compose (traj (pref ++ xs)) (traj extension)
  -- traj (pref ++ xs) = compose (traj pref) (traj xs)
  have hRight : trajectoryProjection resolve (pref ++ xs) =
      composeTrajectory resolve
        (trajectoryProjection resolve pref)
        (trajectoryProjection resolve xs) := by
    exact trajectoryProjection_append resolve pref xs
  rw [hRight]
  -- now compose (compose (traj pref) (traj xs)) (traj extension)
  -- = compose (traj pref) (compose (traj xs) (traj extension)) by assoc
  rw [composeTrajectory_assoc]
  -- now compose (traj pref) (compose (traj xs) (traj extension))
  have hExt : composeTrajectory resolve
      (trajectoryProjection resolve xs)
      (trajectoryProjection resolve extension)
    =
    trajectoryProjection resolve xs := by
    rw [← trajectoryProjection_append]
    exact h
  rw [hExt]

theorem observable_invariant_around_return
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (obs : List KernelExprContext → O)
    (hInv : HistoryObservableInvariant resolve obs)
    (xs extension : List KernelExprContext)
    (h : ReturnsTo resolve xs extension) :
    obs (xs ++ extension) = obs xs := by
  have hEq : HistoricalEquivalent resolve (xs ++ extension) xs := by
    unfold HistoricalEquivalent
    exact h
  exact hInv (xs ++ extension) xs hEq

theorem neutral_return_preserves_observable
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (obs : List KernelExprContext → O)
    (hInv : HistoryObservableInvariant resolve obs)
    (xs : List KernelExprContext)
    (n : Nat) :
    obs (xs ++ neutralPairs n) = obs xs := by
  exact observable_invariant_around_return
    resolve obs hInv xs (neutralPairs n)
    (returns_to_neutral_family resolve xs n)

theorem quotient_return_condition
    (resolve : KernelExpr → Store → Location)
    (xs extension : List KernelExprContext) :
    ReturnsTo resolve xs extension
    ↔
    composeTrajectory resolve
      (trajectoryProjection resolve xs)
      (trajectoryProjection resolve extension)
    =
    trajectoryProjection resolve xs := by
  unfold ReturnsTo
  rw [trajectoryProjection_append]

theorem identity_class_implies_return
    (resolve : KernelExpr → Store → Location)
    (xs extension : List KernelExprContext)
    (h : trajectoryProjection resolve extension = emptyTrajectory resolve) :
    ReturnsTo resolve xs extension := by
  unfold ReturnsTo
  rw [trajectoryProjection_append]
  rw [h]
  exact composeTrajectory_id_right resolve (trajectoryProjection resolve xs)

-- Converse left OPEN: cancellation not available

end KernelExprContext

namespace KernelExprContext

/-! ============================================================
    Transport-generated folded position
============================================================ -/

def generatedFoldedPosition
    (resolve : KernelExpr → Store → Location)
    (start traj : List KernelExprContext) :
    TrajectoryBoundary resolve :=
  trajectoryProjection resolve (start ++ traj)

theorem identity_position
    (resolve : KernelExpr → Store → Location)
    (start : List KernelExprContext) :
    generatedFoldedPosition resolve start [] =
    trajectoryProjection resolve start := by
  unfold generatedFoldedPosition
  rw [List.append_nil]

theorem composition_of_position
    (resolve : KernelExpr → Store → Location)
    (start t1 t2 : List KernelExprContext) :
    generatedFoldedPosition resolve start (t1 ++ t2)
    =
    generatedFoldedPosition resolve (start ++ t1) t2 := by
  unfold generatedFoldedPosition
  rw [List.append_assoc]

theorem reassociation_invariance
    (resolve : KernelExpr → Store → Location)
    (start t1 t2 t3 : List KernelExprContext) :
    generatedFoldedPosition resolve start ((t1 ++ t2) ++ t3)
    =
    generatedFoldedPosition resolve start (t1 ++ (t2 ++ t3)) := by
  unfold generatedFoldedPosition
  rw [List.append_assoc]

theorem returnsTo_iff_same_position
    (resolve : KernelExpr → Store → Location)
    (xs extension : List KernelExprContext) :
    ReturnsTo resolve xs extension
    ↔
    generatedFoldedPosition resolve xs extension
    =
    trajectoryProjection resolve xs := by
  unfold ReturnsTo generatedFoldedPosition
  rfl

-- Chirality, rotation, thread count: NOT YET ENCODED in source.
-- Traversal count as raw length is not determined by folded position
-- (already established by neutralPairs).

theorem traversal_count_not_determined_by_position
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    ∃ ext1 ext2 : List KernelExprContext,
      generatedFoldedPosition resolve xs ext1 =
        generatedFoldedPosition resolve xs ext2
      ∧
      ext1.length ≠ ext2.length := by
  refine ⟨neutralPairs 0, neutralPairs 1, ?_, ?_⟩
  · unfold generatedFoldedPosition
    rw [returns_to_neutral_family resolve xs 0,
        returns_to_neutral_family resolve xs 1]
  · have h0 : (neutralPairs 0).length = 0 := by
      simp [neutralPairs]
    have h1 : (neutralPairs 1).length = 2 := by
      exact neutralPairs_length 1
    omega

end KernelExprContext

namespace KernelExprContext

/-! ============================================================
    Packaging of generated-position invariants
============================================================ -/

structure GeneratedPositionInvariants
    (resolve : KernelExpr → Store → Location) where
  position :
    List KernelExprContext →
    List KernelExprContext →
    TrajectoryBoundary resolve
  identity :
    ∀ start,
      position start [] =
      trajectoryProjection resolve start
  composition :
    ∀ start t1 t2,
      position start (t1 ++ t2) =
      position (start ++ t1) t2
  reassociation :
    ∀ start t1 t2 t3,
      position start ((t1 ++ t2) ++ t3) =
      position start (t1 ++ (t2 ++ t3))
  return_iff :
    ∀ start extension,
      ReturnsTo resolve start extension ↔
      position start extension =
      trajectoryProjection resolve start

def generatedPositionInvariants
    (resolve : KernelExpr → Store → Location) :
    GeneratedPositionInvariants resolve where
  position := generatedFoldedPosition resolve
  identity := identity_position resolve
  composition := composition_of_position resolve
  reassociation := reassociation_invariance resolve
  return_iff := returnsTo_iff_same_position resolve

structure ReturnInvariants
    (resolve : KernelExpr → Store → Location) where
  closure :
    ∀ xs a b,
      ReturnsTo resolve xs a →
      ReturnsTo resolve xs b →
      ReturnsTo resolve xs (a ++ b)
  right_transport :
    ∀ xs extension suffix,
      ReturnsTo resolve xs extension →
      FoldKernel resolve
        (xs ++ extension ++ suffix)
        (xs ++ suffix)
  left_transport :
    ∀ pref xs extension,
      ReturnsTo resolve xs extension →
      FoldKernel resolve
        (pref ++ xs ++ extension)
        (pref ++ xs)
  observable_stability :
    ∀ {O : Type}
      (obs : List KernelExprContext → O),
      HistoryObservableInvariant resolve obs →
      ∀ xs extension,
        ReturnsTo resolve xs extension →
        obs (xs ++ extension) = obs xs

def returnInvariants
    (resolve : KernelExpr → Store → Location) :
    ReturnInvariants resolve where
  closure := return_closure_under_concatenation resolve
  right_transport := return_transport_right resolve
  left_transport := return_transport_left resolve
  observable_stability := observable_invariant_around_return resolve

def PathPositionSeparated
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ xs ext1 ext2 : List KernelExprContext,
    ext1 ≠ ext2
    ∧
    generatedFoldedPosition resolve xs ext1 =
      generatedFoldedPosition resolve xs ext2

theorem path_position_separated
    (resolve : KernelExpr → Store → Location) :
    PathPositionSeparated resolve := by
  refine ⟨[], neutralPairs 0, neutralPairs 1, ?_, ?_⟩
  · exact neutralPairs_distinct 0 1 (by decide)
  · unfold generatedFoldedPosition
    rw [returns_to_neutral_family resolve [] 0,
        returns_to_neutral_family resolve [] 1]

def TraversalCountPositionSeparated
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ xs ext1 ext2 : List KernelExprContext,
    generatedFoldedPosition resolve xs ext1 =
      generatedFoldedPosition resolve xs ext2
    ∧
    ext1.length ≠ ext2.length

theorem traversal_count_position_separated
    (resolve : KernelExpr → Store → Location) :
    TraversalCountPositionSeparated resolve := by
  rcases traversal_count_not_determined_by_position resolve [] with
    ⟨ext1, ext2, hPos, hLen⟩
  exact ⟨[], ext1, ext2, hPos, hLen⟩

def UnboundedFiniteReturns
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ xs : List KernelExprContext,
  ∀ B : Nat,
    ∃ extension : List KernelExprContext,
      ReturnsTo resolve xs extension
      ∧
      extension.length > B

theorem unbounded_finite_returns
    (resolve : KernelExpr → Store → Location) :
    UnboundedFiniteReturns resolve := by
  intro xs B
  exact arbitrarily_long_return_extensions resolve xs B

structure FoldPositionInvariantStructure
    (resolve : KernelExpr → Store → Location) where
  generated :
    GeneratedPositionInvariants resolve
  returns :
    ReturnInvariants resolve
  path_position_separation :
    PathPositionSeparated resolve
  traversal_count_position_separation :
    TraversalCountPositionSeparated resolve
  unbounded_finite_returns :
    UnboundedFiniteReturns resolve

def foldPositionInvariantStructure
    (resolve : KernelExpr → Store → Location) :
    FoldPositionInvariantStructure resolve where
  generated := generatedPositionInvariants resolve
  returns := returnInvariants resolve
  path_position_separation := path_position_separated resolve
  traversal_count_position_separation := traversal_count_position_separated resolve
  unbounded_finite_returns := unbounded_finite_returns resolve

theorem generatedPosition_eq_quotientComposition
    (resolve : KernelExpr → Store → Location)
    (start traj : List KernelExprContext) :
    generatedFoldedPosition resolve start traj
    =
    composeTrajectory resolve
      (trajectoryProjection resolve start)
      (trajectoryProjection resolve traj) := by
  unfold generatedFoldedPosition
  exact trajectoryProjection_append resolve start traj

def PositionReassociationInvariant
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ start t1 t2 t3,
    generatedFoldedPosition resolve start ((t1 ++ t2) ++ t3)
    =
    generatedFoldedPosition resolve start (t1 ++ (t2 ++ t3))

theorem position_reassociation_invariant
    (resolve : KernelExpr → Store → Location) :
    PositionReassociationInvariant resolve := by
  intro start t1 t2 t3
  exact reassociation_invariance resolve start t1 t2 t3

theorem generated_position_distinctions
    (resolve : KernelExpr → Store → Location) :
    PathPositionSeparated resolve
    ∧
    TraversalCountPositionSeparated resolve
    ∧
    UnboundedFiniteReturns resolve := by
  exact ⟨
    path_position_separated resolve,
    traversal_count_position_separated resolve,
    unbounded_finite_returns resolve
  ⟩

end KernelExprContext

namespace KernelExprContext

/-! ============================================================
    Explicit open-boundary packaging
============================================================ -/

def ReturnImpliesIdentityClass
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ xs extension,
    ReturnsTo resolve xs extension →
    trajectoryProjection resolve extension =
      emptyTrajectory resolve

def ReturnWithoutIdentityExtension
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ xs extension,
    ReturnsTo resolve xs extension
    ∧
    trajectoryProjection resolve extension ≠
      emptyTrajectory resolve

theorem returnWithoutIdentity_iff_not_implies
    (resolve : KernelExpr → Store → Location) :
    ReturnWithoutIdentityExtension resolve
    ↔
    ¬ ReturnImpliesIdentityClass resolve := by
  constructor
  · intro ⟨xs, extension, hRet, hNotId⟩
    intro hImpl
    exact hNotId (hImpl xs extension hRet)
  · intro hNot
    unfold ReturnImpliesIdentityClass at hNot
    have hEx : ∃ xs, ¬ ∀ extension, ReturnsTo resolve xs extension →
        trajectoryProjection resolve extension = emptyTrajectory resolve :=
      Classical.not_forall.mp hNot
    rcases hEx with ⟨xs, hNotExt⟩
    have hExExt : ∃ extension, ¬ (ReturnsTo resolve xs extension →
        trajectoryProjection resolve extension = emptyTrajectory resolve) :=
      Classical.not_forall.mp hNotExt
    rcases hExExt with ⟨extension, hNotImp⟩
    have hRet : ReturnsTo resolve xs extension := by
      apply Classical.byContradiction
      intro hNotRet
      exact hNotImp (fun h => False.elim (hNotRet h))
    have hNotId : trajectoryProjection resolve extension ≠ emptyTrajectory resolve := by
      intro hId
      exact hNotImp (fun _ => hId)
    exact ⟨xs, extension, hRet, hNotId⟩

def RightCancellation
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ a b c : TrajectoryBoundary resolve,
    composeTrajectory resolve a c =
      composeTrajectory resolve b c →
    a = b

def LeftCancellation
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ a b c : TrajectoryBoundary resolve,
    composeTrajectory resolve c a =
      composeTrajectory resolve c b →
    a = b

def RightCancellationCollision
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ a b c : TrajectoryBoundary resolve,
    a ≠ b ∧
    composeTrajectory resolve a c =
      composeTrajectory resolve b c

def LeftCancellationCollision
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ a b c : TrajectoryBoundary resolve,
    a ≠ b ∧
    composeTrajectory resolve c a =
      composeTrajectory resolve c b

theorem rightCollision_implies_not_cancellation
    (resolve : KernelExpr → Store → Location) :
    RightCancellationCollision resolve →
    ¬ RightCancellation resolve := by
  intro ⟨a, b, c, hNe, hComp⟩
  intro hCanc
  exact hNe (hCanc a b c hComp)

theorem leftCollision_implies_not_cancellation
    (resolve : KernelExpr → Store → Location) :
    LeftCancellationCollision resolve →
    ¬ LeftCancellation resolve := by
  intro ⟨a, b, c, hNe, hComp⟩
  intro hCanc
  exact hNe (hCanc a b c hComp)

def ContextActionFaithful
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ ctx1 ctx2,
    ContextActEqual resolve ctx1 ctx2 →
    ctx1 = ctx2

def ContextActionCollision
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ ctx1 ctx2 : KernelExprContext,
    ctx1 ≠ ctx2 ∧
    ContextActEqual resolve ctx1 ctx2

theorem contextCollision_implies_not_faithful
    (resolve : KernelExpr → Store → Location) :
    ContextActionCollision resolve →
    ¬ ContextActionFaithful resolve := by
  intro ⟨ctx1, ctx2, hNe, hEq⟩
  intro hFaith
  exact hNe (hFaith ctx1 ctx2 hEq)

structure ParityBoundary
    (resolve : KernelExpr → Store → Location) where
  preserved : Prop
  collision : Prop
  exclusive : collision ↔ ¬ preserved

def parityBoundary
    (resolve : KernelExpr → Store → Location) :
    ParityBoundary resolve where
  preserved := ParityPreserved resolve
  collision := ParityCollision resolve
  exclusive := parityCollision_iff_not_preserved resolve

structure ModBoundary
    (resolve : KernelExpr → Store → Location)
    (k : Nat) where
  preserved : Prop
  collision : Prop
  exclusive : collision ↔ ¬ preserved

def modBoundary
    (resolve : KernelExpr → Store → Location)
    (k : Nat) :
    ModBoundary resolve k where
  preserved := ModPreserved resolve k
  collision := ModCollision resolve k
  exclusive := modCollision_iff_not_preserved resolve k

def ScalarDepthCandidate
    (resolve : KernelExpr → Store → Location)
    (depth : TrajectoryBoundary resolve → Nat) : Prop :=
  Function.Injective depth

def ScalarDepthExists
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ depth : TrajectoryBoundary resolve → Nat,
    ScalarDepthCandidate resolve depth

structure FDHTOpenBoundaries
    (resolve : KernelExpr → Store → Location) where
  return_identity : Prop
  right_cancellation : Prop
  left_cancellation : Prop
  context_action_faithfulness : Prop
  parity : Prop
  modulo : Nat → Prop
  scalar_depth_exists : Prop

def fdhtOpenBoundaries
    (resolve : KernelExpr → Store → Location) :
    FDHTOpenBoundaries resolve where
  return_identity := ReturnImpliesIdentityClass resolve
  right_cancellation := RightCancellation resolve
  left_cancellation := LeftCancellation resolve
  context_action_faithfulness := ContextActionFaithful resolve
  parity := ParityPreserved resolve
  modulo := fun k => ModPreserved resolve k
  scalar_depth_exists := ScalarDepthExists resolve

-- Known side: identity class implies return remains the previously proved direction.
-- Converse remains the open ReturnImpliesIdentityClass.

end KernelExprContext

namespace KernelExprContext

theorem identity_singleton_equals_empty_trajectory
    (resolve : KernelExpr → Store → Location) :
    toTrajectoryBoundary resolve [identityContext]
    =
    emptyTrajectory resolve := by
  apply Quotient.sound
  intro q
  change
    plugPersistent resolve identityContext q = q
  exact plugPersistent_identity resolve q

end KernelExprContext

namespace KernelExprContext

theorem parity_breaking_fold_witness
    (resolve : KernelExpr → Store → Location) :
    ∃ xs ys : List KernelExprContext,
      FoldKernel resolve xs ys
      ∧
      LengthParity xs ≠ LengthParity ys := by
  refine ⟨[], [identityContext], ?_, ?_⟩

  · unfold FoldKernel
    change
      emptyTrajectory resolve
      =
      toTrajectoryBoundary resolve [identityContext]
    exact
      (identity_singleton_equals_empty_trajectory resolve).symm

  · unfold LengthParity
    decide

end KernelExprContext

namespace KernelExprContext

theorem parity_collision
    (resolve : KernelExpr → Store → Location) :
    ParityCollision resolve := by
  exact parity_breaking_fold_witness resolve

end KernelExprContext

namespace KernelExprContext

theorem parity_not_preserved
    (resolve : KernelExpr → Store → Location) :
    ¬ ParityPreserved resolve := by
  exact
    (parityCollision_iff_not_preserved resolve).mp
      (parity_collision resolve)

end KernelExprContext

namespace KernelExprContext

/-! ============================================================
    Modulo-k classification via singleton identity collision
============================================================ -/

theorem empty_identity_singleton_foldKernel
    (resolve : KernelExpr → Store → Location) :
    FoldKernel resolve [] [identityContext] := by
  unfold FoldKernel
  exact (identity_singleton_equals_empty_trajectory resolve).symm

theorem empty_length :
    ([] : List KernelExprContext).length = 0 := by
  rfl

theorem identity_singleton_length :
    [identityContext].length = 1 := by
  rfl

theorem empty_lengthMod
    (k : Nat) :
    LengthMod k [] = 0 := by
  unfold LengthMod
  rfl

theorem identity_singleton_lengthMod_zero :
    LengthMod 0 [identityContext] = 1 := by
  unfold LengthMod
  rfl

theorem identity_singleton_lengthMod_one :
    LengthMod 1 [identityContext] = 0 := by
  unfold LengthMod
  rfl

theorem identity_singleton_lengthMod_ge_two
    (k : Nat)
    (hk : 2 ≤ k) :
    LengthMod k [identityContext] = 1 := by
  unfold LengthMod
  have hLen : [identityContext].length = 1 := identity_singleton_length
  rw [hLen]
  have hLt : 1 < k := Nat.lt_of_lt_of_le (by decide) hk
  exact Nat.mod_eq_of_lt hLt

theorem mod1_preserved
    (resolve : KernelExpr → Store → Location) :
    ModPreserved resolve 1 := by
  intro xs ys _
  unfold LengthMod
  simp [Nat.mod_one]

def lengthMod1Boundary
    (resolve : KernelExpr → Store → Location) :
    TrajectoryBoundary resolve → Nat :=
  lengthModBoundary resolve 1 (mod1_preserved resolve)

theorem lengthMod1Boundary_mk
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    lengthMod1Boundary resolve
      (trajectoryProjection resolve xs)
    =
    LengthMod 1 xs := by
  rfl

theorem mod0_collision
    (resolve : KernelExpr → Store → Location) :
    ModCollision resolve 0 := by
  refine ⟨[], [identityContext], ?_, ?_⟩
  · exact empty_identity_singleton_foldKernel resolve
  · have h0 : LengthMod 0 [] = 0 := empty_lengthMod 0
    have h1 : LengthMod 0 [identityContext] = 1 := identity_singleton_lengthMod_zero
    rw [h0, h1]
    decide

theorem mod0_not_preserved
    (resolve : KernelExpr → Store → Location) :
    ¬ ModPreserved resolve 0 := by
  exact (modCollision_iff_not_preserved resolve 0).mp (mod0_collision resolve)

theorem mod_collision_of_two_le
    (resolve : KernelExpr → Store → Location)
    (k : Nat)
    (hk : 2 ≤ k) :
    ModCollision resolve k := by
  refine ⟨[], [identityContext], ?_, ?_⟩
  · exact empty_identity_singleton_foldKernel resolve
  · have h0 : LengthMod k [] = 0 := empty_lengthMod k
    have h1 : LengthMod k [identityContext] = 1 := identity_singleton_lengthMod_ge_two k hk
    rw [h0, h1]
    decide

theorem mod_not_preserved_of_two_le
    (resolve : KernelExpr → Store → Location)
    (k : Nat)
    (hk : 2 ≤ k) :
    ¬ ModPreserved resolve k := by
  exact
    (modCollision_iff_not_preserved resolve k).mp
      (mod_collision_of_two_le resolve k hk)

theorem modPreserved_iff_eq_one
    (resolve : KernelExpr → Store → Location)
    (k : Nat) :
    ModPreserved resolve k ↔ k = 1 := by
  constructor
  · intro hPres
    cases k with
    | zero =>
        exact False.elim ((mod0_not_preserved resolve) hPres)
    | succ n =>
        cases n with
        | zero =>
            rfl
        | succ m =>
            have hk : 2 ≤ Nat.succ (Nat.succ m) := by
              omega
            exact False.elim
              ((mod_not_preserved_of_two_le
                resolve
                (Nat.succ (Nat.succ m))
                hk) hPres)
  · intro hk
    cases hk
    exact mod1_preserved resolve

theorem modCollision_iff_ne_one
    (resolve : KernelExpr → Store → Location)
    (k : Nat) :
    ModCollision resolve k ↔ k ≠ 1 := by
  constructor
  · intro hColl hEq
    rw [hEq] at hColl
    exact (modCollision_iff_not_preserved resolve 1).mp hColl (mod1_preserved resolve)
  · intro hNe
    cases k with
    | zero => exact mod0_collision resolve
    | succ n =>
      cases n with
      | zero => exact False.elim (hNe rfl)
      | succ m =>
        have hk : 2 ≤ Nat.succ (Nat.succ m) := by
          omega
        exact mod_collision_of_two_le resolve (Nat.succ (Nat.succ m)) hk

theorem mod_factorisation_exists_iff_eq_one
    (resolve : KernelExpr → Store → Location)
    (k : Nat) :
    (∃ modBoundary : TrajectoryBoundary resolve → Nat,
      ∀ xs,
        modBoundary (trajectoryProjection resolve xs)
        =
        LengthMod k xs)
    ↔
    k = 1 := by
  constructor
  · intro ⟨modB, hFact⟩
    apply Classical.byContradiction
    intro hNe
    have hColl : ModCollision resolve k :=
      (modCollision_iff_ne_one resolve k).mpr hNe
    have hBlock := mod_collision_blocks_factorisation resolve k hColl
    exact hBlock ⟨modB, hFact⟩
  · intro hEq
    rw [hEq]
    exact ⟨lengthMod1Boundary resolve, lengthMod1Boundary_mk resolve⟩

theorem parity_not_preserved_from_mod_classification
    (resolve : KernelExpr → Store → Location) :
    ¬ ParityPreserved resolve := by
  intro hParity
  have hMod2 : ModPreserved resolve 2 :=
    (parityPreserved_iff_mod2Preserved resolve).mp hParity
  have hEq : (2 : Nat) = 1 :=
    (modPreserved_iff_eq_one resolve 2).mp hMod2
  exact (by decide : (2 : Nat) ≠ 1) hEq

structure ModuloClassification
    (resolve : KernelExpr → Store → Location) where
  preserved_iff :
    ∀ k,
      ModPreserved resolve k ↔ k = 1
  collision_iff :
    ∀ k,
      ModCollision resolve k ↔ k ≠ 1
  factorisation_iff :
    ∀ k,
      (∃ modBoundary : TrajectoryBoundary resolve → Nat,
        ∀ xs,
          modBoundary (trajectoryProjection resolve xs)
          =
          LengthMod k xs)
      ↔
      k = 1

def moduloClassification
    (resolve : KernelExpr → Store → Location) :
    ModuloClassification resolve where
  preserved_iff := modPreserved_iff_eq_one resolve
  collision_iff := modCollision_iff_ne_one resolve
  factorisation_iff := mod_factorisation_exists_iff_eq_one resolve

end KernelExprContext

namespace KernelExprContext

/-! ============================================================
    Cancellation / return boundary
============================================================ -/

theorem leftCancellation_implies_returnIdentity
    (resolve : KernelExpr → Store → Location)
    (hCancel : LeftCancellation resolve) :
    ReturnImpliesIdentityClass resolve := by
  intro xs extension hRet
  have hComp :
      composeTrajectory resolve
        (trajectoryProjection resolve xs)
        (trajectoryProjection resolve extension)
      =
      trajectoryProjection resolve xs := by
    unfold ReturnsTo at hRet
    rw [trajectoryProjection_append] at hRet
    exact hRet
  have hId :
      composeTrajectory resolve
        (trajectoryProjection resolve xs)
        (emptyTrajectory resolve)
      =
      trajectoryProjection resolve xs :=
    composeTrajectory_id_right resolve (trajectoryProjection resolve xs)
  have hEq :
      trajectoryProjection resolve extension =
      emptyTrajectory resolve :=
    hCancel
      (trajectoryProjection resolve extension)
      (emptyTrajectory resolve)
      (trajectoryProjection resolve xs)
      (by rw [hComp, hId])
  exact hEq

theorem return_iff_identity_under_leftCancellation
    (resolve : KernelExpr → Store → Location)
    (hCancel : LeftCancellation resolve)
    (xs extension : List KernelExprContext) :
    ReturnsTo resolve xs extension
    ↔
    trajectoryProjection resolve extension =
      emptyTrajectory resolve := by
  constructor
  · intro hRet
    exact leftCancellation_implies_returnIdentity resolve hCancel xs extension hRet
  · intro hId
    exact identity_class_implies_return resolve xs extension hId

theorem returnWithoutIdentity_implies_not_leftCancellation
    (resolve : KernelExpr → Store → Location) :
    ReturnWithoutIdentityExtension resolve →
    ¬ LeftCancellation resolve := by
  intro hWit hCancel
  have hImpl := leftCancellation_implies_returnIdentity resolve hCancel
  exact (returnWithoutIdentity_iff_not_implies resolve).mp hWit hImpl

def RightStabilizer
    (resolve : KernelExpr → Store → Location)
    (q : TrajectoryBoundary resolve) :=
  { r : TrajectoryBoundary resolve //
      composeTrajectory resolve q r = q }

theorem empty_in_rightStabilizer
    (resolve : KernelExpr → Store → Location)
    (q : TrajectoryBoundary resolve) :
    ∃ r, r = emptyTrajectory resolve ∧
      composeTrajectory resolve q r = q := by
  refine ⟨emptyTrajectory resolve, rfl, composeTrajectory_id_right resolve q⟩

theorem returnsTo_iff_stabilizer
    (resolve : KernelExpr → Store → Location)
    (xs extension : List KernelExprContext) :
    ReturnsTo resolve xs extension
    ↔
    ∃ r : TrajectoryBoundary resolve,
      r = trajectoryProjection resolve extension ∧
      composeTrajectory resolve
        (trajectoryProjection resolve xs) r
      =
      trajectoryProjection resolve xs := by
  constructor
  · intro hRet
    unfold ReturnsTo at hRet
    rw [trajectoryProjection_append] at hRet
    exact ⟨trajectoryProjection resolve extension, rfl, hRet⟩
  · intro hMem
    rcases hMem with ⟨r, hEq, hComp⟩
    unfold ReturnsTo
    rw [trajectoryProjection_append]
    subst hEq
    exact hComp

def AllRightStabilizersTrivial
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ q r : TrajectoryBoundary resolve,
    composeTrajectory resolve q r = q →
    r = emptyTrajectory resolve

theorem allRightStabilizersTrivial_iff_returnIdentity
    (resolve : KernelExpr → Store → Location) :
    AllRightStabilizersTrivial resolve
    ↔
    ReturnImpliesIdentityClass resolve := by
  constructor
  · intro hTriv xs extension hRet
    have hMem :
        ∃ r : TrajectoryBoundary resolve,
          r = trajectoryProjection resolve extension ∧
          composeTrajectory resolve
            (trajectoryProjection resolve xs) r
          =
          trajectoryProjection resolve xs :=
      (returnsTo_iff_stabilizer resolve xs extension).mp hRet
    rcases hMem with ⟨r, hEq, hComp⟩
    have hTrivR :=
      hTriv (trajectoryProjection resolve xs) r hComp
    rw [hEq] at hTrivR
    exact hTrivR
  · intro hRetId q r hComp
    rcases trajectoryProjection_surjective resolve q with ⟨xs, hQ⟩
    rcases trajectoryProjection_surjective resolve r with ⟨extension, hR⟩
    have hRet : ReturnsTo resolve xs extension := by
      rw [← hQ, ← hR] at hComp
      exact
        (returnsTo_iff_stabilizer resolve xs extension).mpr
          ⟨trajectoryProjection resolve extension, rfl, hComp⟩
    have hIdExt :
        trajectoryProjection resolve extension =
          emptyTrajectory resolve :=
      hRetId xs extension hRet
    rw [← hR]
    exact hIdExt

structure ReturnCancellationBoundary
    (resolve : KernelExpr → Store → Location) where
  leftCancellation : Prop
  returnIdentity : Prop
  implication : leftCancellation → returnIdentity

def returnCancellationBoundary
    (resolve : KernelExpr → Store → Location) :
    ReturnCancellationBoundary resolve where
  leftCancellation := LeftCancellation resolve
  returnIdentity := ReturnImpliesIdentityClass resolve
  implication := leftCancellation_implies_returnIdentity resolve

end KernelExprContext

namespace KernelExprContext

/-! ============================================================
    Nontrivial stabilizer countermodel propositions
============================================================ -/

def NontrivialRightStabilizer
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ q r : TrajectoryBoundary resolve,
    r ≠ emptyTrajectory resolve
    ∧
    composeTrajectory resolve q r = q

theorem nontrivialRightStabilizer_iff_not_allTrivial
    (resolve : KernelExpr → Store → Location) :
    NontrivialRightStabilizer resolve
    ↔
    ¬ AllRightStabilizersTrivial resolve := by
  constructor
  · intro ⟨q, r, hNe, hComp⟩
    intro hTriv
    exact hNe (hTriv q r hComp)
  · intro hNot
    unfold AllRightStabilizersTrivial at hNot
    have hEx : ∃ q, ¬ ∀ r, composeTrajectory resolve q r = q → r = emptyTrajectory resolve :=
      Classical.not_forall.mp hNot
    rcases hEx with ⟨q, hNotR⟩
    have hExR : ∃ r, ¬ (composeTrajectory resolve q r = q → r = emptyTrajectory resolve) :=
      Classical.not_forall.mp hNotR
    rcases hExR with ⟨r, hNotImp⟩
    have hComp : composeTrajectory resolve q r = q := by
      apply Classical.byContradiction; intro hNotComp
      exact hNotImp (fun h => False.elim (hNotComp h))
    have hNe : r ≠ emptyTrajectory resolve := by
      intro hId
      exact hNotImp (fun _ => hId)
    exact ⟨q, r, hNe, hComp⟩

theorem nontrivialRightStabilizer_iff_returnWithoutIdentity
    (resolve : KernelExpr → Store → Location) :
    NontrivialRightStabilizer resolve
    ↔
    ReturnWithoutIdentityExtension resolve := by
  constructor
  · intro ⟨q, r, hNe, hComp⟩
    rcases trajectoryProjection_surjective resolve q with ⟨xs, hQ⟩
    rcases trajectoryProjection_surjective resolve r with ⟨extension, hR⟩
    have hRet : ReturnsTo resolve xs extension := by
      have hComp' : composeTrajectory resolve (trajectoryProjection resolve xs) (trajectoryProjection resolve extension) = trajectoryProjection resolve xs := by
        rw [hQ, hR]
        exact hComp
      exact
        (returnsTo_iff_stabilizer resolve xs extension).mpr
          ⟨trajectoryProjection resolve extension, rfl, hComp'⟩
    have hNotId : trajectoryProjection resolve extension ≠ emptyTrajectory resolve := by
      rw [hR]
      exact hNe
    exact ⟨xs, extension, hRet, hNotId⟩
  · intro ⟨xs, extension, hRet, hNotId⟩
    have hMem := (returnsTo_iff_stabilizer resolve xs extension).mp hRet
    rcases hMem with ⟨r, hEq, hComp⟩
    have hComp' :
        composeTrajectory resolve
          (trajectoryProjection resolve xs)
          (trajectoryProjection resolve extension)
        =
        trajectoryProjection resolve xs := by
      subst hEq
      exact hComp
    exact ⟨
      trajectoryProjection resolve xs,
      trajectoryProjection resolve extension,
      hNotId,
      hComp'
    ⟩

theorem nontrivialRightStabilizer_implies_not_leftCancellation
    (resolve : KernelExpr → Store → Location) :
    NontrivialRightStabilizer resolve →
    ¬ LeftCancellation resolve := by
  intro hNon
  exact returnWithoutIdentity_implies_not_leftCancellation resolve
    ((nontrivialRightStabilizer_iff_returnWithoutIdentity resolve).mp hNon)

theorem nontrivialRightStabilizer_implies_leftCollision
    (resolve : KernelExpr → Store → Location) :
    NontrivialRightStabilizer resolve →
    LeftCancellationCollision resolve := by
  intro ⟨q, r, hNe, hComp⟩
  refine ⟨r, emptyTrajectory resolve, q, hNe, ?_⟩
  rw [hComp]
  exact (composeTrajectory_id_right resolve q).symm

def NontrivialLeftStabilizer
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ q l : TrajectoryBoundary resolve,
    l ≠ emptyTrajectory resolve
    ∧
    composeTrajectory resolve l q = q

theorem nontrivialLeftStabilizer_implies_rightCollision
    (resolve : KernelExpr → Store → Location) :
    NontrivialLeftStabilizer resolve →
    RightCancellationCollision resolve := by
  intro ⟨q, l, hNe, hComp⟩
  refine ⟨l, emptyTrajectory resolve, q, hNe, ?_⟩
  rw [hComp]
  exact (composeTrajectory_id_left resolve q).symm

def AllLeftStabilizersTrivial
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ q l,
    composeTrajectory resolve l q = q →
    l = emptyTrajectory resolve

theorem nontrivialLeftStabilizer_iff_not_allLeftTrivial
    (resolve : KernelExpr → Store → Location) :
    NontrivialLeftStabilizer resolve
    ↔
    ¬ AllLeftStabilizersTrivial resolve := by
  constructor
  · intro ⟨q, l, hNe, hComp⟩
    intro hTriv
    exact hNe (hTriv q l hComp)
  · intro hNot
    unfold AllLeftStabilizersTrivial at hNot
    have hEx : ∃ q, ¬ ∀ l, composeTrajectory resolve l q = q → l = emptyTrajectory resolve :=
      Classical.not_forall.mp hNot
    rcases hEx with ⟨q, hNotL⟩
    have hExL : ∃ l, ¬ (composeTrajectory resolve l q = q → l = emptyTrajectory resolve) :=
      Classical.not_forall.mp hNotL
    rcases hExL with ⟨l, hNotImp⟩
    have hComp : composeTrajectory resolve l q = q := by
      apply Classical.byContradiction; intro hNotComp
      exact hNotImp (fun h => False.elim (hNotComp h))
    have hNe : l ≠ emptyTrajectory resolve := by
      intro hId
      exact hNotImp (fun _ => hId)
    exact ⟨q, l, hNe, hComp⟩

structure StabilizerCountermodelDependencies
    (resolve : KernelExpr → Store → Location) where
  rightStabilizer_to_returnCountermodel :
    NontrivialRightStabilizer resolve →
    ReturnWithoutIdentityExtension resolve
  rightStabilizer_to_leftCollision :
    NontrivialRightStabilizer resolve →
    LeftCancellationCollision resolve
  rightStabilizer_to_notLeftCancellation :
    NontrivialRightStabilizer resolve →
    ¬ LeftCancellation resolve
  leftStabilizer_to_rightCollision :
    NontrivialLeftStabilizer resolve →
    RightCancellationCollision resolve

def stabilizerCountermodelDependencies
    (resolve : KernelExpr → Store → Location) :
    StabilizerCountermodelDependencies resolve where
  rightStabilizer_to_returnCountermodel :=
    (nontrivialRightStabilizer_iff_returnWithoutIdentity resolve).mp
  rightStabilizer_to_leftCollision :=
    nontrivialRightStabilizer_implies_leftCollision resolve
  rightStabilizer_to_notLeftCancellation :=
    nontrivialRightStabilizer_implies_not_leftCancellation resolve
  leftStabilizer_to_rightCollision :=
    nontrivialLeftStabilizer_implies_rightCollision resolve

end KernelExprContext

namespace KernelExprContext

theorem nontrivialLeftStabilizer_implies_not_rightCancellation
    (resolve : KernelExpr → Store → Location) :
    NontrivialLeftStabilizer resolve →
    ¬ RightCancellation resolve := by
  intro hStab
  apply rightCollision_implies_not_cancellation resolve
  exact nontrivialLeftStabilizer_implies_rightCollision resolve hStab

end KernelExprContext

namespace KernelExprContext

/-! ============================================================
    Stabilizer / cancellation symmetry packaging
============================================================ -/

namespace KernelExprContext

/-!
# FDHT Stabilizer / Cancellation Boundary Module

This module packages the currently established implication structure
between nontrivial stabilizers, cancellation collisions, cancellation
failure, and stabilizer triviality.

No existence theorem for a nontrivial stabilizer is asserted here.
The left/right cancellation questions remain open.
-/

/-! ## Right-stabilizer branch -/

theorem rightStabilizer_countermodel_chain
    (resolve : KernelExpr → Store → Location) :
    NontrivialRightStabilizer resolve →
    LeftCancellationCollision resolve ∧
    ¬ LeftCancellation resolve := by
  intro h
  exact ⟨
    nontrivialRightStabilizer_implies_leftCollision resolve h,
    nontrivialRightStabilizer_implies_not_leftCancellation resolve h
  ⟩

theorem rightStabilizer_triviality_boundary
    (resolve : KernelExpr → Store → Location) :
    NontrivialRightStabilizer resolve ↔
    ¬ AllRightStabilizersTrivial resolve := by
  exact nontrivialRightStabilizer_iff_not_allTrivial resolve

theorem leftCollision_implies_notLeftCancellation
    (resolve : KernelExpr → Store → Location) :
    LeftCancellationCollision resolve →
    ¬ LeftCancellation resolve := by
  exact leftCollision_implies_not_cancellation resolve


/-! ## Left-stabilizer branch -/

theorem leftStabilizer_countermodel_chain
    (resolve : KernelExpr → Store → Location) :
    NontrivialLeftStabilizer resolve →
    RightCancellationCollision resolve ∧
    ¬ RightCancellation resolve := by
  intro h
  exact ⟨
    nontrivialLeftStabilizer_implies_rightCollision resolve h,
    nontrivialLeftStabilizer_implies_not_rightCancellation resolve h
  ⟩

theorem leftStabilizer_triviality_boundary
    (resolve : KernelExpr → Store → Location) :
    NontrivialLeftStabilizer resolve ↔
    ¬ AllLeftStabilizersTrivial resolve := by
  exact nontrivialLeftStabilizer_iff_not_allLeftTrivial resolve

theorem rightCollision_implies_notRightCancellation
    (resolve : KernelExpr → Store → Location) :
    RightCancellationCollision resolve →
    ¬ RightCancellation resolve := by
  exact rightCollision_implies_not_cancellation resolve


/-! ## Return-specific right-stabilizer branch -/

theorem rightStabilizer_iff_returnCountermodel
    (resolve : KernelExpr → Store → Location) :
    NontrivialRightStabilizer resolve ↔
    ReturnWithoutIdentityExtension resolve := by
  exact nontrivialRightStabilizer_iff_returnWithoutIdentity resolve

theorem rightTrivial_iff_returnIdentity
    (resolve : KernelExpr → Store → Location) :
    AllRightStabilizersTrivial resolve ↔
    ReturnImpliesIdentityClass resolve := by
  exact allRightStabilizersTrivial_iff_returnIdentity resolve

theorem leftCancellation_implies_allRightTrivial
    (resolve : KernelExpr → Store → Location) :
    LeftCancellation resolve →
    AllRightStabilizersTrivial resolve := by
  intro hCancel

  have hReturn :
      ReturnImpliesIdentityClass resolve :=
    leftCancellation_implies_returnIdentity resolve hCancel

  exact
    (allRightStabilizersTrivial_iff_returnIdentity resolve).2
      hReturn


/-! ## Symmetric dependency package -/

structure StabilizerSymmetryDependencies
    (resolve : KernelExpr → Store → Location) where

  right_to_leftCollision :
    NontrivialRightStabilizer resolve →
    LeftCancellationCollision resolve

  right_to_notLeftCancellation :
    NontrivialRightStabilizer resolve →
    ¬ LeftCancellation resolve

  left_to_rightCollision :
    NontrivialLeftStabilizer resolve →
    RightCancellationCollision resolve

  left_to_notRightCancellation :
    NontrivialLeftStabilizer resolve →
    ¬ RightCancellation resolve

  right_triviality_iff :
    NontrivialRightStabilizer resolve ↔
    ¬ AllRightStabilizersTrivial resolve

  left_triviality_iff :
    NontrivialLeftStabilizer resolve ↔
    ¬ AllLeftStabilizersTrivial resolve


def stabilizerSymmetryDependencies
    (resolve : KernelExpr → Store → Location) :
    StabilizerSymmetryDependencies resolve :=
{
  right_to_leftCollision :=
    nontrivialRightStabilizer_implies_leftCollision resolve

  right_to_notLeftCancellation :=
    nontrivialRightStabilizer_implies_not_leftCancellation resolve

  left_to_rightCollision :=
    nontrivialLeftStabilizer_implies_rightCollision resolve

  left_to_notRightCancellation :=
    nontrivialLeftStabilizer_implies_not_rightCancellation resolve

  right_triviality_iff :=
    nontrivialRightStabilizer_iff_not_allTrivial resolve

  left_triviality_iff :=
    nontrivialLeftStabilizer_iff_not_allLeftTrivial resolve
}


/-! ## Boundary-status package

These fields record propositions only.
They do not assert that any OPEN proposition holds or fails.
-/

structure StabilizerBoundaryStatus
    (resolve : KernelExpr → Store → Location) where
  rightNontrivial : Prop
  leftNontrivial : Prop
  leftCancellation : Prop
  rightCancellation : Prop
  allRightTrivial : Prop
  allLeftTrivial : Prop


def stabilizerBoundaryStatus
    (resolve : KernelExpr → Store → Location) :
    StabilizerBoundaryStatus resolve :=
{
  rightNontrivial :=
    NontrivialRightStabilizer resolve

  leftNontrivial :=
    NontrivialLeftStabilizer resolve

  leftCancellation :=
    LeftCancellation resolve

  rightCancellation :=
    RightCancellation resolve

  allRightTrivial :=
    AllRightStabilizersTrivial resolve

  allLeftTrivial :=
    AllLeftStabilizersTrivial resolve
}


/-!
## Proven dependency graph

Right branch:

  NontrivialRightStabilizer
        ├─> LeftCancellationCollision
        ├─> ¬ LeftCancellation
        ├─↔ ¬ AllRightStabilizersTrivial
        └─↔ ReturnWithoutIdentityExtension

Left branch:

  NontrivialLeftStabilizer
        ├─> RightCancellationCollision
        ├─> ¬ RightCancellation
        └─↔ ¬ AllLeftStabilizersTrivial

Return-specific right branch:

  LeftCancellation
        ─> AllRightStabilizersTrivial
        ↔  ReturnImpliesIdentityClass

OPEN converse edges intentionally NOT encoded as theorems:

  LeftCancellationCollision
        -> NontrivialRightStabilizer

  RightCancellationCollision
        -> NontrivialLeftStabilizer

  ¬ LeftCancellation
        -> NontrivialRightStabilizer

  ¬ RightCancellation
        -> NontrivialLeftStabilizer

  AllRightStabilizersTrivial
        -> LeftCancellation

  AllLeftStabilizersTrivial
        -> RightCancellation

No existence theorem for either nontrivial stabilizer is asserted.
-/

end KernelExprContext

namespace KernelExprContext

/-! ## Compile-time smoke tests

These checks protect the stabilizer/cancellation theorem surface.

They do NOT establish any OPEN proposition and do not construct
nontrivial stabilizer witnesses.
-/

section StabilizerBoundarySmokeTests

variable (resolve : KernelExpr → Store → Location)

-- Core propositions remain available.
#check NontrivialRightStabilizer resolve
#check NontrivialLeftStabilizer resolve
#check AllRightStabilizersTrivial resolve
#check AllLeftStabilizersTrivial resolve

#check LeftCancellation resolve
#check RightCancellation resolve
#check LeftCancellationCollision resolve
#check RightCancellationCollision resolve

-- Right-stabilizer dependency chain.
#check nontrivialRightStabilizer_implies_leftCollision resolve
#check nontrivialRightStabilizer_implies_not_leftCancellation resolve
#check nontrivialRightStabilizer_iff_not_allTrivial resolve
#check nontrivialRightStabilizer_iff_returnWithoutIdentity resolve
#check rightStabilizer_countermodel_chain resolve
#check rightStabilizer_triviality_boundary resolve

-- Left-stabilizer dependency chain.
#check nontrivialLeftStabilizer_implies_rightCollision resolve
#check nontrivialLeftStabilizer_implies_not_rightCancellation resolve
#check nontrivialLeftStabilizer_iff_not_allLeftTrivial resolve
#check leftStabilizer_countermodel_chain resolve
#check leftStabilizer_triviality_boundary resolve

-- Collision implies non-cancellation.
#check leftCollision_implies_notLeftCancellation resolve
#check rightCollision_implies_notRightCancellation resolve

-- Return-specific right-action branch.
#check ReturnImpliesIdentityClass resolve
#check ReturnWithoutIdentityExtension resolve
#check leftCancellation_implies_returnIdentity resolve
#check leftCancellation_implies_allRightTrivial resolve
#check allRightStabilizersTrivial_iff_returnIdentity resolve

-- Packaged dependency structures.
#check StabilizerCountermodelDependencies resolve
#check stabilizerCountermodelDependencies resolve

#check StabilizerSymmetryDependencies resolve
#check stabilizerSymmetryDependencies resolve

#check StabilizerBoundaryStatus resolve
#check stabilizerBoundaryStatus resolve

end StabilizerBoundarySmokeTests

section StabilizerBoundarySmokeExamples

variable (resolve : KernelExpr → Store → Location)

example
    (h : NontrivialRightStabilizer resolve) :
    ¬ LeftCancellation resolve :=
  nontrivialRightStabilizer_implies_not_leftCancellation resolve h

example
    (h : NontrivialLeftStabilizer resolve) :
    ¬ RightCancellation resolve :=
  nontrivialLeftStabilizer_implies_not_rightCancellation resolve h

example
    (h : NontrivialRightStabilizer resolve) :
    LeftCancellationCollision resolve :=
  nontrivialRightStabilizer_implies_leftCollision resolve h

example
    (h : NontrivialLeftStabilizer resolve) :
    RightCancellationCollision resolve :=
  nontrivialLeftStabilizer_implies_rightCollision resolve h

example
    (h : LeftCancellation resolve) :
    AllRightStabilizersTrivial resolve :=
  leftCancellation_implies_allRightTrivial resolve h

example :
    NontrivialRightStabilizer resolve ↔
    ¬ AllRightStabilizersTrivial resolve :=
  rightStabilizer_triviality_boundary resolve

example :
    NontrivialLeftStabilizer resolve ↔
    ¬ AllLeftStabilizersTrivial resolve :=
  leftStabilizer_triviality_boundary resolve

end StabilizerBoundarySmokeExamples

/-! ## Negative boundary regression guards

These examples deliberately require hypotheses for OPEN propositions.
They ensure downstream results cannot be obtained without explicitly
supplying the unresolved assumption.
-/

section StabilizerBoundaryNegativeGuards

variable (resolve : KernelExpr → Store → Location)

-- A nontrivial right stabilizer is not manufactured.
example
    (h : NontrivialRightStabilizer resolve) :
    ¬ LeftCancellation resolve :=
  nontrivialRightStabilizer_implies_not_leftCancellation resolve h

-- A nontrivial left stabilizer is not manufactured.
example
    (h : NontrivialLeftStabilizer resolve) :
    ¬ RightCancellation resolve :=
  nontrivialLeftStabilizer_implies_not_rightCancellation resolve h

-- Return -> identity requires the unresolved cancellation hypothesis.
example
    (hCancel : LeftCancellation resolve) :
    ReturnImpliesIdentityClass resolve :=
  leftCancellation_implies_returnIdentity resolve hCancel

-- Trivial right stabilizers follow from left cancellation,
-- but cancellation itself is not asserted.
example
    (hCancel : LeftCancellation resolve) :
    AllRightStabilizersTrivial resolve :=
  leftCancellation_implies_allRightTrivial resolve hCancel

-- Collision only gives non-cancellation in the proved direction.
example
    (hCollision : LeftCancellationCollision resolve) :
    ¬ LeftCancellation resolve :=
  leftCollision_implies_notLeftCancellation resolve hCollision

example
    (hCollision : RightCancellationCollision resolve) :
    ¬ RightCancellation resolve :=
  rightCollision_implies_notRightCancellation resolve hCollision

end StabilizerBoundaryNegativeGuards

/-! ## Accidental-provability guards

These examples are deliberately unprovable under the current calculus.
They fail to type-check if any of the listed OPEN propositions
become theorems without additional hypotheses.
-/

section AccidentalProvabilityGuards

variable (resolve : KernelExpr → Store → Location)

-- These must remain unprovable.
-- example : LeftCancellation resolve := sorry
-- example : RightCancellation resolve := sorry
-- example : NontrivialRightStabilizer resolve := sorry
-- example : NontrivialLeftStabilizer resolve := sorry

-- These converses must remain unprovable.
-- example (h : LeftCancellationCollision resolve) : NontrivialRightStabilizer resolve := sorry
-- example (h : RightCancellationCollision resolve) : NontrivialLeftStabilizer resolve := sorry
-- example (h : AllRightStabilizersTrivial resolve) : LeftCancellation resolve := sorry
-- example (h : AllLeftStabilizersTrivial resolve) : RightCancellation resolve := sorry

end AccidentalProvabilityGuards


end KernelExprContext

theorem FoldKernel_refl
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    FoldKernel resolve xs xs :=
  rfl

theorem FoldKernel_symm
    (resolve : KernelExpr → Store → Location)
    {xs ys : List KernelExprContext}
    (h : FoldKernel resolve xs ys) :
    FoldKernel resolve ys xs :=
  h.symm

theorem FoldKernel_trans
    (resolve : KernelExpr → Store → Location)
    {xs ys zs : List KernelExprContext}
    (hxy : FoldKernel resolve xs ys)
    (hyz : FoldKernel resolve ys zs) :
    FoldKernel resolve xs zs :=
  hxy.trans hyz

theorem FoldKernel_equivalence
    (resolve : KernelExpr → Store → Location) :
    (∀ xs, FoldKernel resolve xs xs)
    ∧
    (∀ {xs ys},
      FoldKernel resolve xs ys →
      FoldKernel resolve ys xs)
    ∧
    (∀ {xs ys zs},
      FoldKernel resolve xs ys →
      FoldKernel resolve ys zs →
      FoldKernel resolve xs zs) :=
  ⟨FoldKernel_refl resolve,
   fun h => FoldKernel_symm resolve h,
   fun hxy hyz => FoldKernel_trans resolve hxy hyz⟩

theorem FoldKernel_congr
    (resolve : KernelExpr → Store → Location)
    {xs xs' ys ys' : List KernelExprContext}
    (hx : FoldKernel resolve xs xs')
    (hy : FoldKernel resolve ys ys') :
    FoldKernel resolve
      (xs ++ ys)
      (xs' ++ ys') := by
  unfold FoldKernel at *
  rw [trajectoryProjection_append, trajectoryProjection_append, hx, hy]

def FoldKernelSetoid
    (resolve : KernelExpr → Store → Location) :
    Setoid (List KernelExprContext) where
  r := FoldKernel resolve
  iseqv :=
  {
    refl := FoldKernel_refl resolve
    symm := fun h => FoldKernel_symm resolve h
    trans := fun hxy hyz => FoldKernel_trans resolve hxy hyz
  }

def FoldKernelQuotient
    (resolve : KernelExpr → Store → Location) :=
  Quotient (FoldKernelSetoid resolve)

def QuotientHomKernel
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) : Prop :=
  trajectoryProjection resolve xs =
  trajectoryProjection resolve ys

theorem quotientHomKernel_eq_FoldKernel
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) :
    QuotientHomKernel resolve xs ys
    ↔
    FoldKernel resolve xs ys :=
  Iff.rfl

def foldKernelToTrajectory
    (resolve : KernelExpr → Store → Location) :
    FoldKernelQuotient resolve → TrajectoryBoundary resolve :=
  Quotient.lift
    (trajectoryProjection resolve)
    (fun _ _ h => h)

def trajectoryToFoldKernel
    (resolve : KernelExpr → Store → Location) :
    TrajectoryBoundary resolve → FoldKernelQuotient resolve :=
  Quotient.lift
    (fun xs => Quotient.mk (FoldKernelSetoid resolve) xs)
    (by
      intro xs ys h
      apply Quotient.sound
      exact Quotient.sound h)

theorem foldKernel_trajectory_left_inv
    (resolve : KernelExpr → Store → Location)
    (q : FoldKernelQuotient resolve) :
    trajectoryToFoldKernel resolve
      (foldKernelToTrajectory resolve q) = q := by
  induction q using Quotient.ind with
  | _ xs =>
    rfl

theorem foldKernel_trajectory_right_inv
    (resolve : KernelExpr → Store → Location)
    (t : TrajectoryBoundary resolve) :
    foldKernelToTrajectory resolve
      (trajectoryToFoldKernel resolve t) = t := by
  induction t using Quotient.ind with
  | _ xs =>
    rfl

structure LocalEquiv (A B : Type) where
  toFun : A → B
  invFun : B → A
  left_inv : ∀ a, invFun (toFun a) = a
  right_inv : ∀ b, toFun (invFun b) = b

def FoldKernelQuotient_equiv_TrajectoryBoundary
    (resolve : KernelExpr → Store → Location) :
    LocalEquiv (FoldKernelQuotient resolve) (TrajectoryBoundary resolve) :=
{
  toFun := foldKernelToTrajectory resolve
  invFun := trajectoryToFoldKernel resolve
  left_inv := foldKernel_trajectory_left_inv resolve
  right_inv := foldKernel_trajectory_right_inv resolve
}

def foldKernelQuotientOne
    (resolve : KernelExpr → Store → Location) :
    FoldKernelQuotient resolve :=
  Quotient.mk (FoldKernelSetoid resolve) []

def foldKernelQuotientMul
    (resolve : KernelExpr → Store → Location)
    (qx qy : FoldKernelQuotient resolve) :
    FoldKernelQuotient resolve :=
  Quotient.liftOn₂ qx qy
    (fun xs ys => Quotient.mk (FoldKernelSetoid resolve) (xs ++ ys))
    (by
      intro xs ys xs' ys' hx hy
      apply Quotient.sound
      exact FoldKernel_congr resolve hx hy)

theorem foldKernelQuotient_one_mul
    (resolve : KernelExpr → Store → Location)
    (q : FoldKernelQuotient resolve) :
    foldKernelQuotientMul resolve
      (foldKernelQuotientOne resolve) q = q := by
  induction q using Quotient.ind with
  | _ xs =>
    apply Quotient.sound
    show FoldKernel resolve ([] ++ xs) xs
    unfold FoldKernel
    rw [trajectoryProjection_append, trajectoryProjection_nil,
        composeTrajectory_id_left]

theorem foldKernelQuotient_mul_one
    (resolve : KernelExpr → Store → Location)
    (q : FoldKernelQuotient resolve) :
    foldKernelQuotientMul resolve
      q (foldKernelQuotientOne resolve) = q := by
  induction q using Quotient.ind with
  | _ xs =>
    apply Quotient.sound
    show FoldKernel resolve (xs ++ []) xs
    unfold FoldKernel
    rw [trajectoryProjection_append, trajectoryProjection_nil,
        composeTrajectory_id_right]

theorem foldKernelQuotient_mul_assoc
    (resolve : KernelExpr → Store → Location)
    (a b c : FoldKernelQuotient resolve) :
    foldKernelQuotientMul resolve
      (foldKernelQuotientMul resolve a b) c
    =
    foldKernelQuotientMul resolve
      a (foldKernelQuotientMul resolve b c) := by
  induction a using Quotient.ind with
  | _ xs =>
    induction b using Quotient.ind with
    | _ ys =>
      induction c using Quotient.ind with
      | _ zs =>
        apply Quotient.sound
        show FoldKernel resolve ((xs ++ ys) ++ zs) (xs ++ (ys ++ zs))
        unfold FoldKernel
        rw [trajectoryProjection_append, trajectoryProjection_append,
            trajectoryProjection_append, trajectoryProjection_append,
            composeTrajectory_assoc]

def foldKernelQuotientMonoid
    (resolve : KernelExpr → Store → Location) :
    LocalMonoid (FoldKernelQuotient resolve) :=
{
  one := foldKernelQuotientOne resolve
  mul := foldKernelQuotientMul resolve
  one_mul := foldKernelQuotient_one_mul resolve
  mul_one := foldKernelQuotient_mul_one resolve
  mul_assoc := foldKernelQuotient_mul_assoc resolve
}

structure LocalMonoidEquiv
    (A B : Type)
    (MA : LocalMonoid A)
    (MB : LocalMonoid B) where
  equiv : LocalEquiv A B
  map_one : equiv.toFun MA.one = MB.one
  map_mul :
    ∀ a b,
      equiv.toFun (MA.mul a b) =
      MB.mul (equiv.toFun a) (equiv.toFun b)

theorem foldKernelQuotient_equiv_map_one
    (resolve : KernelExpr → Store → Location) :
    (FoldKernelQuotient_equiv_TrajectoryBoundary resolve).toFun
      (foldKernelQuotientMonoid resolve).one
    =
    (trajectoryLocalMonoid resolve).one := by
  rfl

theorem foldKernelQuotient_equiv_map_mul
    (resolve : KernelExpr → Store → Location)
    (a b : FoldKernelQuotient resolve) :
    (FoldKernelQuotient_equiv_TrajectoryBoundary resolve).toFun
      ((foldKernelQuotientMonoid resolve).mul a b)
    =
    (trajectoryLocalMonoid resolve).mul
      ((FoldKernelQuotient_equiv_TrajectoryBoundary resolve).toFun a)
      ((FoldKernelQuotient_equiv_TrajectoryBoundary resolve).toFun b) := by
  induction a using Quotient.ind with
  | _ xs =>
    induction b using Quotient.ind with
    | _ ys =>
      rfl

def FoldKernelQuotient_monoidEquiv_TrajectoryBoundary
    (resolve : KernelExpr → Store → Location) :
    LocalMonoidEquiv
      (FoldKernelQuotient resolve)
      (TrajectoryBoundary resolve)
      (foldKernelQuotientMonoid resolve)
      (trajectoryLocalMonoid resolve) :=
{
  equiv := FoldKernelQuotient_equiv_TrajectoryBoundary resolve
  map_one := foldKernelQuotient_equiv_map_one resolve
  map_mul := foldKernelQuotient_equiv_map_mul resolve
}





/-! ============================================================
    Trajectory projection as local monoid homomorphism
============================================================ -/

def rawHistoryLocalMonoid :
    LocalMonoid (List KernelExprContext) :=
{
  one := []
  mul := List.append
  one_mul := by
    intro xs
    rfl
  mul_one := by
    intro xs
    exact List.append_nil xs
  mul_assoc := by
    intro xs ys zs
    exact List.append_assoc xs ys zs
}

structure LocalMonoidHom
    (A B : Type)
    (MA : LocalMonoid A)
    (MB : LocalMonoid B) where
  toFun : A → B
  map_one :
    toFun MA.one =
    MB.one
  map_mul :
    ∀ x y,
      toFun (MA.mul x y) =
      MB.mul (toFun x) (toFun y)

def trajectoryQuotientHom
    (resolve : KernelExpr → Store → Location) :
    LocalMonoidHom
      (List KernelExprContext)
      (TrajectoryBoundary resolve)
      rawHistoryLocalMonoid
      (trajectoryLocalMonoid resolve) :=
{
  toFun := trajectoryProjection resolve
  map_one := trajectoryProjection_nil resolve
  map_mul := trajectoryProjection_append resolve
}

theorem trajectoryQuotientHom_apply
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    (trajectoryQuotientHom resolve).toFun xs =
    trajectoryProjection resolve xs :=
  rfl

def Surjective {A B : Type} (f : A → B) : Prop :=
  ∀ b, ∃ a, f a = b

theorem trajectoryQuotientHom_surjective
    (resolve : KernelExpr → Store → Location) :
    Surjective (trajectoryQuotientHom resolve).toFun :=
  trajectoryProjection_surjective resolve

theorem trajectoryQuotientHom_kernel_iff
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) :
    (trajectoryQuotientHom resolve).toFun xs =
      (trajectoryQuotientHom resolve).toFun ys
    ↔
    FoldKernel resolve xs ys :=
  Iff.rfl

theorem foldKernelEquiv_recovers_projection
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    (FoldKernelQuotient_equiv_TrajectoryBoundary resolve).toFun
      (Quotient.mk _ xs)
    =
    trajectoryProjection resolve xs :=
  rfl

theorem foldKernelMonoidEquiv_recovers_projection
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    (FoldKernelQuotient_monoidEquiv_TrajectoryBoundary resolve).equiv.toFun
      (Quotient.mk _ xs)
    =
    (trajectoryQuotientHom resolve).toFun xs :=
  rfl

structure TrajectoryProjectionFirstIso
    (resolve : KernelExpr → Store → Location) where
  projection :
    LocalMonoidHom
      (List KernelExprContext)
      (TrajectoryBoundary resolve)
      rawHistoryLocalMonoid
      (trajectoryLocalMonoid resolve)
  surjective :
    Surjective projection.toFun
  kernel_exact :
    ∀ xs ys,
      projection.toFun xs = projection.toFun ys
      ↔
      FoldKernel resolve xs ys
  quotientEquiv :
    LocalMonoidEquiv
      (FoldKernelQuotient resolve)
      (TrajectoryBoundary resolve)
      (foldKernelQuotientMonoid resolve)
      (trajectoryLocalMonoid resolve)
  representative_recovery :
    ∀ xs,
      quotientEquiv.equiv.toFun (Quotient.mk _ xs)
      =
      projection.toFun xs

def trajectoryProjectionFirstIso
    (resolve : KernelExpr → Store → Location) :
    TrajectoryProjectionFirstIso resolve :=
{
  projection := trajectoryQuotientHom resolve
  surjective := trajectoryQuotientHom_surjective resolve
  kernel_exact := trajectoryQuotientHom_kernel_iff resolve
  quotientEquiv := FoldKernelQuotient_monoidEquiv_TrajectoryBoundary resolve
  representative_recovery := foldKernelMonoidEquiv_recovers_projection resolve
}


/-! ## Main FDHT trajectory quotient API -/

/--
The FDHT trajectory projection first-isomorphism theorem.

The raw-history projection is surjective, its exact kernel is `FoldKernel`,
and quotienting raw histories by that kernel yields the trajectory-boundary
monoid, with representative projection preserved by the quotient equivalence.
-/
theorem trajectoryProjection_first_isomorphism
    (resolve : KernelExpr → Store → Location) :
    let F := trajectoryProjectionFirstIso resolve
    Surjective F.projection.toFun
    ∧
    (∀ xs ys : List KernelExprContext,
      F.projection.toFun xs = F.projection.toFun ys
      ↔ FoldKernel resolve xs ys)
    ∧
    (∀ xs : List KernelExprContext,
      F.quotientEquiv.equiv.toFun
        (Quotient.mk (FoldKernelSetoid resolve) xs)
      =
      F.projection.toFun xs) := by
  dsimp only
  refine ⟨
    trajectoryQuotientHom_surjective resolve,
    ?_,
    ?_
  ⟩
  · intro xs ys
    exact trajectoryQuotientHom_kernel_iff resolve xs ys
  · intro xs
    exact foldKernelMonoidEquiv_recovers_projection resolve xs

/-! ============================================================
    Stage 4 — Local pairwise reconstruction obstruction
============================================================ -/

theorem collapsed_pair_blocks_common_reconstruction
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (hxy : xs ≠ ys)
    (hcollapse : toTrajectoryBoundary resolve xs = toTrajectoryBoundary resolve ys) :
    ¬ ∃ recover : TrajectoryBoundary resolve → List KernelExprContext,
      recover (toTrajectoryBoundary resolve xs) = xs ∧
      recover (toTrajectoryBoundary resolve ys) = ys := by
  intro ⟨recover, hxs, hys⟩
  have : xs = ys := by
    calc
      xs = recover (toTrajectoryBoundary resolve xs) := hxs.symm
      _ = recover (toTrajectoryBoundary resolve ys) := by rw [hcollapse]
      _ = ys := hys
  exact hxy this

theorem swap_pair_blocks_common_reconstruction
    (resolve : KernelExpr → Store → Location) :
    ¬ ∃ recover : TrajectoryBoundary resolve → List KernelExprContext,
      recover (toTrajectoryBoundary resolve []) = [] ∧
      recover (toTrajectoryBoundary resolve [swapContext, swapContext]) =
        [swapContext, swapContext] := by
  apply collapsed_pair_blocks_common_reconstruction
  · intro h
    injection h
  · exact (swap_pair_equals_empty_trajectory resolve).symm
