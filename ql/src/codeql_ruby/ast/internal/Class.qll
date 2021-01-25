private import codeql_ruby.AST
private import codeql_ruby.ast.internal.Expr
private import codeql_ruby.ast.internal.TreeSitter

module Class {
  class Range extends ExprSequence::Range, @class {
    final override Generated::Class generated;

    final override Expr getExpr(int i) { result = generated.getChild(i) }

    final string getName() {
      result = generated.getName().(Generated::Token).getValue() or
      result = this.getNameScopeResolution().getName()
    }

    final ScopeResolution getNameScopeResolution() { result = generated.getName() }

    final string getSuperclassName() {
      result = generated.getSuperclass().getChild().(Generated::Token).getValue() or
      result = generated.getSuperclass().getChild().(ScopeResolution).getName()
    }

    final Expr getSuperclassExpr() { result = generated.getSuperclass().getChild() }
  }
}

module SingletonClass {
  class Range extends ExprSequence::Range, @singleton_class {
    final override Generated::SingletonClass generated;

    final override Expr getExpr(int i) { result = generated.getChild(i) }

    final Expr getValue() { result = generated.getValue() }

    // TODO: delete me
    final AstNode getAstNodeValue() { result = generated.getValue() }
  }
}

module Module {
  class Range extends ExprSequence::Range, @module {
    final override Generated::Module generated;

    final override Expr getExpr(int n) { result = generated.getChild(n) }

    final string getName() {
      result = generated.getName().(Generated::Token).getValue() or
      result = this.getNameScopeResolution().getName()
    }

    final ScopeResolution getNameScopeResolution() { result = generated.getName() }
  }
}
