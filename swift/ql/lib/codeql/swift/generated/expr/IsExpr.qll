// generated by codegen/codegen.py
/**
 * This module provides the generated definition of `IsExpr`.
 * INTERNAL: Do not import directly.
 */

private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.expr.CheckedCastExpr

module Generated {
  /**
   * INTERNAL: Do not reference the `Generated::IsExpr` class directly.
   * Use the subclass `IsExpr`, where the following predicates are available.
   */
  class IsExpr extends Synth::TIsExpr, CheckedCastExpr {
    override string getAPrimaryQlClass() { result = "IsExpr" }
  }
}
