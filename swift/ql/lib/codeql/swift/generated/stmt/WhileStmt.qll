// generated by codegen/codegen.py
/**
 * This module provides the generated definition of `WhileStmt`.
 * INTERNAL: Do not import directly.
 */

private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.stmt.LabeledConditionalStmt
import codeql.swift.elements.stmt.Stmt

module Generated {
  /**
   * INTERNAL: Do not reference the `Generated::WhileStmt` class directly.
   * Use the subclass `WhileStmt`, where the following predicates are available.
   */
  class WhileStmt extends Synth::TWhileStmt, LabeledConditionalStmt {
    override string getAPrimaryQlClass() { result = "WhileStmt" }

    /**
     * Gets the body of this while statement.
     */
    Stmt getBody() {
      result =
        Synth::convertStmtFromRaw(Synth::convertWhileStmtToRaw(this).(Raw::WhileStmt).getBody())
    }
  }
}
