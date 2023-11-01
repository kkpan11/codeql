/** Provides classes relating to declarations and type members. */

import Callable
import Element
import Modifier
import Variable
private import dotnet
private import Implements
private import TypeRef

/**
 * A declaration.
 *
 * Either a modifiable (`Modifiable`) or an assignable (`Assignable`).
 */
class Declaration extends DotNet::Declaration, Element, @declaration {
  override ValueOrRefType getDeclaringType() { none() }

  /** Holds if this declaration is unconstructed and in source code. */
  final predicate isSourceDeclaration() { this.fromSource() and this.isUnboundDeclaration() }

  override string toString() { result = this.getName() }

  /**
   * Gets the fully qualified name of this declaration, including types, for example
   * the fully qualified name with types of `M` on line 3 is `N.C.M(int, string)` in
   *
   * ```csharp
   * namespace N {
   *   class C {
   *     void M(int i, string s) { }
   *   }
   * }
   * ```
   */
  string getQualifiedNameWithTypes() {
    exists(string qual |
      qual = this.getDeclaringType().getQualifiedName() and
      if this instanceof NestedType
      then result = qual + "+" + this.toStringWithTypes()
      else result = qual + "." + this.toStringWithTypes()
    )
  }

  /**
   * Holds if this declaration has been generated by the compiler, for example
   * implicit constructors or accessors.
   */
  predicate isCompilerGenerated() { compiler_generated(this) }
}

/** A declaration that can have a modifier. */
class Modifiable extends Declaration, @modifiable {
  /** Gets a modifier of this declaration. */
  Modifier getAModifier() { has_modifiers(this, result) }

  /** Holds if this declaration has `name` as a modifier. */
  predicate hasModifier(string name) { this.getAModifier().hasName(name) }

  /** Holds if this declaration is `static`. */
  predicate isStatic() { this.hasModifier("static") }

  /** Holds if this declaration is `public`. */
  predicate isPublic() { this.hasModifier("public") }

  /** Holds if this declaration is `protected`. */
  predicate isProtected() { this.hasModifier("protected") }

  /** Holds if this declaration is `internal`. */
  predicate isInternal() { this.hasModifier("internal") }

  /** Holds if this declaration is `private`. */
  predicate isPrivate() { this.hasModifier("private") }

  /** Holds if this declaration has the modifier `new`. */
  predicate isNew() { this.hasModifier("new") }

  /** Holds if this declaration is `sealed`. */
  predicate isSealed() { this.hasModifier("sealed") }

  /** Holds if this declaration is `abstract`. */
  predicate isAbstract() { this.hasModifier("abstract") }

  /** Holds if this declaration is `extern`. */
  predicate isExtern() { this.hasModifier("extern") }

  /** Holds if this declaration is `partial`. */
  predicate isPartial() { this.hasModifier("partial") }

  /** Holds if this declaration is `const`. */
  predicate isConst() { this.hasModifier("const") }

  /** Holds if this declaration has the modifier `required`. */
  predicate isRequired() { this.hasModifier("required") }

  /** Holds if this declaration is `file` local. */
  predicate isFile() { this.hasModifier("file") }

  /** Holds if this declaration is `unsafe`. */
  predicate isUnsafe() {
    this.hasModifier("unsafe")
    or
    exists(Type t, Type child |
      t = this.(Parameterizable).getAParameter().getType() or
      t = this.(Property).getType() or
      t = this.(Callable).getReturnType() or
      t = this.(DelegateType).getReturnType()
    |
      child = t.getAChild*() and
      (
        child instanceof PointerType
        or
        child instanceof FunctionPointerType
      )
    )
  }

  /** Holds if this declaration is `async`. */
  predicate isAsync() { this.hasModifier("async") }

  private predicate isReallyPrivate() {
    this.isPrivate() and
    not this.isProtected() and
    // Rare case when a member is defined with the same name in multiple assemblies with different visibility
    not this.isPublic()
  }

  /**
   * Holds if this declaration is effectively `private`. A declaration is considered
   * effectively `private` if it can only be referenced from
   * - the declaring and its nested types, similarly to `private` declarations, and
   * - the enclosing types.
   *
   * Note that explicit interface implementations are also considered effectively
   * `private` if the implemented interface is itself effectively `private`. Finally,
   * `private protected` members are not considered effectively `private`, because
   * they can be overridden within the declaring assembly.
   */
  predicate isEffectivelyPrivate() {
    this.isReallyPrivate() or
    this.getDeclaringType+().(Modifiable).isReallyPrivate() or
    this.(Virtualizable).getExplicitlyImplementedInterface().isEffectivelyPrivate()
  }

  private predicate isReallyInternal() {
    (
      this.isInternal() and not this.isProtected()
      or
      this.isPrivate() and this.isProtected()
    ) and
    // Rare case when a member is defined with the same name in multiple assemblies with different visibility
    not this.isPublic()
  }

  /**
   * Holds if this declaration is effectively `internal`. A declaration is considered
   * effectively `internal` if it can only be referenced from the declaring assembly.
   *
   * Note that friend assemblies declared in `InternalsVisibleToAttribute` are not
   * considered. Explicit interface implementations are also considered effectively
   * `internal` if the implemented interface is itself effectively `internal`. Finally,
   * `internal protected` members are not considered effectively `internal`, because
   * they can be overridden outside the declaring assembly.
   */
  predicate isEffectivelyInternal() {
    this.isReallyInternal() or
    this.getDeclaringType+().(Modifiable).isReallyInternal() or
    this.(Virtualizable).getExplicitlyImplementedInterface().isEffectivelyInternal()
  }

  /**
   * Holds if this declaration is effectively `public`, meaning that it can be
   * referenced outside the declaring assembly.
   */
  predicate isEffectivelyPublic() {
    not this.isEffectivelyPrivate() and not this.isEffectivelyInternal()
  }
}

/** A declaration that is a member of a type. */
class Member extends DotNet::Member, Modifiable, @member {
  /** Gets an access to this member. */
  MemberAccess getAnAccess() { result.getTarget() = this }

  override predicate isPublic() { Modifiable.super.isPublic() }

  override predicate isProtected() { Modifiable.super.isProtected() }

  override predicate isPrivate() { Modifiable.super.isPrivate() }

  override predicate isInternal() { Modifiable.super.isInternal() }

  override predicate isSealed() { Modifiable.super.isSealed() }

  override predicate isAbstract() { Modifiable.super.isAbstract() }

  override predicate isStatic() { Modifiable.super.isStatic() }

  override predicate isRequired() { Modifiable.super.isRequired() }

  override predicate isFile() { Modifiable.super.isFile() }
}

private class TOverridable = @virtualizable or @callable_accessor;

/**
 * A declaration that can be overridden or implemented. That is, a method,
 * a property, an indexer, an event, an accessor, or an operator.
 *
 * Unlike `Virtualizable`, this class includes accessors.
 */
class Overridable extends Declaration, TOverridable {
  /**
   * Gets any interface this member explicitly implements; this only applies
   * to members that can be declared on an interface, i.e. methods, properties,
   * indexers and events.
   */
  Interface getExplicitlyImplementedInterface() {
    explicitly_implements(this, result)
    or
    not explicitly_implements(this, any(Interface i)) and
    explicitly_implements(this, getTypeRef(result))
  }

  /**
   * Holds if this member implements an interface member explicitly.
   */
  predicate implementsExplicitInterface() { exists(this.getExplicitlyImplementedInterface()) }

  /** Holds if this member can be overridden or implemented. */
  predicate isOverridableOrImplementable() { none() }

  /** Gets the member that is immediately overridden by this member, if any. */
  Overridable getOverridee() {
    overrides(this, result)
    or
    // For accessors (which are `Callable`s), the extractor generates entries
    // in the `overrides` relation. However, we want the relation to be on
    // the declarations containing the accessors instead
    exists(Accessor accessorOverrider, Accessor accessorOverridee |
      accessorOverrider = this.(DeclarationWithAccessors).getAnAccessor() and
      accessorOverridee = result.(DeclarationWithAccessors).getAnAccessor() and
      overrides(accessorOverrider, accessorOverridee)
    )
  }

  /** Gets a member that immediately overrides this member, if any. */
  Overridable getAnOverrider() { this = result.getOverridee() }

  /** Holds if this member is overridden by some other member. */
  predicate isOverridden() { exists(this.getAnOverrider()) }

  /** Holds if this member overrides another member. */
  predicate overrides() { exists(this.getOverridee()) }

  /**
   * Gets the interface member that is immediately implemented by this member, if any.
   *
   * The type `t` is a type that implements the interface type in which
   * the result is declared, in such a way that this member is the
   * implementation of the result.
   *
   * Example:
   *
   * ```csharp
   * interface I { void M(); }
   *
   * class A { public void M() { } }
   *
   * class B : A, I { }
   *
   * class C : A, I { new public void M() }
   * ```
   *
   * In the example above, the following (and nothing else) holds:
   * `A.M.getImplementee(B) = I.M` and
   * `C.M.getImplementee(C) = I.M`.
   */
  Overridable getImplementee(ValueOrRefType t) { implements(this, result, t) }

  /** Gets the interface member that is immediately implemented by this member, if any. */
  Overridable getImplementee() { result = this.getImplementee(_) }

  /**
   * Gets a member that immediately implements this interface member, if any.
   *
   * The type `t` is a type that implements the interface type in which
   * this member is declared, in such a way that the result is the
   * implementation of this member.
   *
   * Example:
   *
   * ```csharp
   * interface I { void M(); }
   *
   * class A { public void M() { } }
   *
   * class B : A, I { }
   *
   * class C : A, I { new public void M() }
   * ```
   *
   * In the example above, the following (and nothing else) holds:
   * `I.M.getAnImplementor(B) = A.M` and
   * `I.M.getAnImplementor(C) = C.M`.
   */
  Overridable getAnImplementor(ValueOrRefType t) { this = result.getImplementee(t) }

  /** Gets a member that immediately implements this interface member, if any. */
  Overridable getAnImplementor() { this = result.getImplementee() }

  /**
   * Gets an interface member that is (transitively) implemented by this
   * member, if any. That is, either this member immediately implements
   * the interface member, or this member overrides (transitively) another
   * member that immediately implements the interface member.
   *
   * Note that this is generally *not* equivalent with
   * `getOverridee*().getImplementee()`, as the example below illustrates:
   *
   * ```csharp
   * interface I { void M(); }
   *
   * class A { public virtual void M() { } }
   *
   * class B : A, I { }
   *
   * class C : A { public override void M() }
   *
   * class D : B { public override void M() }
   * ```
   *
   * - If this member is `A.M` then `I.M = getAnUltimateImplementee()`.
   * - If this member is `C.M` then it is *not* the case that
   *   `I.M = getAnUltimateImplementee()`, because `C` is not a sub type of `I`.
   *   (An example where `getOverridee*().getImplementee()` would be incorrect.)
   * - If this member is `D.M` then `I.M = getAnUltimateImplementee()`.
   */
  pragma[nomagic]
  Overridable getAnUltimateImplementee() {
    exists(Overridable implementation, ValueOrRefType implementationType |
      implements(implementation, result, implementationType)
    |
      this = implementation
      or
      this.getOverridee+() = implementation and
      this.getDeclaringType().getABaseType+() = implementationType
    )
  }

  /**
   * Gets a member that (transitively) implements this interface member,
   * if any. That is, either this interface member is immediately implemented
   * by the result, or the result overrides (transitively) another member that
   * immediately implements this interface member.
   *
   * Note that this is generally *not* equivalent with
   * `getImplementor().getAnOverrider*()` (see `getImplementee`).
   */
  Overridable getAnUltimateImplementor() { this = result.getAnUltimateImplementee() }

  /** Holds if this interface member is implemented by some other member. */
  predicate isImplemented() { exists(this.getAnImplementor()) }

  /** Holds if this member implements (transitively) an interface member. */
  predicate implements() { exists(this.getAnUltimateImplementee()) }

  /**
   * Holds if this member overrides or implements (transitively)
   * `that` member.
   */
  predicate overridesOrImplements(Overridable that) {
    this.getOverridee+() = that or
    this.getAnUltimateImplementee() = that
  }

  /**
   * Holds if this member overrides or implements (reflexively, transitively)
   * `that` member.
   */
  predicate overridesOrImplementsOrEquals(Overridable that) {
    this = that or
    this.overridesOrImplements(that)
  }
}

/**
 * A member where the `virtual` modifier is valid. That is, a method,
 * a property, an indexer, an event, or an operator.
 *
 * Equivalently, these are the members that can be defined in an interface.
 *
 * Unlike `Overridable`, this class excludes accessors.
 */
class Virtualizable extends Overridable, Member, @virtualizable {
  /** Holds if this member has the modifier `override`. */
  predicate isOverride() { this.hasModifier("override") }

  /** Holds if this member is `virtual`. */
  predicate isVirtual() { this.hasModifier("virtual") }

  override predicate isPublic() {
    Member.super.isPublic() or
    this.implementsExplicitInterface()
  }

  override predicate isPrivate() {
    super.isPrivate() and
    not this.implementsExplicitInterface()
  }

  override predicate isOverridableOrImplementable() {
    not this.isSealed() and
    not this.getDeclaringType().isSealed() and
    (
      this.isVirtual() or
      this.isOverride() or
      this.isAbstract() or
      this.getDeclaringType() instanceof Interface
    )
  }
}

/**
 * A parameterizable declaration. Either a callable (`Callable`), a delegate
 * type (`DelegateType`), or an indexer (`Indexer`).
 */
class Parameterizable extends DotNet::Parameterizable, Declaration, @parameterizable {
  override Parameter getRawParameter(int i) { params(result, _, _, i, _, this, _) }

  override Parameter getParameter(int i) { params(result, _, _, i, _, this, _) }

  /**
   * Gets the type of the parameter, possibly prefixed
   * with `out`, `ref`, or `params`, where appropriate.
   */
  private string parameterTypeToString(int i) {
    exists(Parameter p, string prefix |
      p = this.getParameter(i) and
      result = prefix + p.getType().toStringWithTypes()
    |
      if p.isOut()
      then prefix = "out "
      else
        if p.isRef()
        then prefix = "ref "
        else
          if p.isParams()
          then prefix = "params "
          else prefix = ""
    )
  }

  /**
   * Gets the types of the parameters of this declaration as a
   * comma-separated string.
   */
  language[monotonicAggregates]
  string parameterTypesToString() {
    result =
      concat(int i | exists(this.getParameter(i)) | this.parameterTypeToString(i), ", " order by i)
  }
}
