// generated by codegen/codegen.py
/**
 * This module provides the generated definition of `DynamicSubscriptExpr`.
 * INTERNAL: Do not import directly.
 */

private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.expr.DynamicLookupExpr

module Generated {
  /**
   * INTERNAL: Do not reference the `Generated::DynamicSubscriptExpr` class directly.
   * Use the subclass `DynamicSubscriptExpr`, where the following predicates are available.
   */
  class DynamicSubscriptExpr extends Synth::TDynamicSubscriptExpr, DynamicLookupExpr {
    override string getAPrimaryQlClass() { result = "DynamicSubscriptExpr" }
  }
}
