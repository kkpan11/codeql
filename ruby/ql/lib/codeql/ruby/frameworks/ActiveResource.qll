/**
 * Provides modeling for the `ActiveResource` library.
 * Version: 6.0.0.
 */

private import ruby
private import codeql.ruby.Concepts
private import codeql.ruby.controlflow.CfgNodes
private import codeql.ruby.ast.internal.Module
private import codeql.ruby.DataFlow
private import codeql.ruby.ApiGraphs

/**
 * Provides modeling for the `ActiveResource` library.
 * Version: 6.0.0.
 */
module ActiveResource {
  /**
   * An ActiveResource model class. This is any (transitive) subclass of ActiveResource.
   */
  private API::Node modelApiNode() {
    result = API::getTopLevelMember("ActiveResource").getMember("Base").getASubclass+()
  }

  /**
   * An ActiveResource class.
   *
   * ``rb
   * class Person < ActiveResource::Base
   * end
   * ```
   */
  class ModelClass extends ClassDeclaration {
    API::Node model;

    ModelClass() {
      model = modelApiNode() and
      this.getSuperclassExpr() = model.getAValueReachableFromSource().asExpr().getExpr()
    }

    API::Node getModelApiNode() { result = model }

    SiteAssignCall getASiteAssignment() { result.getModelClass() = this }

    predicate disablesCertificateValidation(SiteAssignCall c) {
      c = this.getASiteAssignment() and
      c.disablesCertificateValidation()
    }
  }

  /**
   * A call to a class method on an ActiveResource model class.
   *
   * ```rb
   * class Person < ActiveResource::Base
   * end
   *
   * Person.find(1)
   * ```
   */
  class ModelClassMethodCall extends DataFlow::CallNode {
    API::Node model;

    ModelClassMethodCall() {
      model = modelApiNode() and
      this = classMethodCall(model, _)
    }

    ModelClass getModelClass() { result.getModelApiNode() = model }
  }

  /**
   * A call to `site=` on an ActiveResource model class.
   * This sets the base URL for all HTTP requests made by this class.
   */
  private class SiteAssignCall extends DataFlow::CallNode {
    API::Node model;

    SiteAssignCall() { model = modelApiNode() and this = classMethodCall(model, "site=") }

    /**
     * A node that contributes to the URLs used for HTTP requests by the parent
     * class.
     */
    DataFlow::Node getAUrlPart() { result = this.getArgument(0) }

    ModelClass getModelClass() { result.getModelApiNode() = model }

    predicate disablesCertificateValidation() {
      this.getAUrlPart().asExpr().getConstantValue().getString().regexpMatch("^http(^s)")
    }
  }

  /**
   * A call to the `find` class method, which returns an ActiveResource model
   * object.
   *
   * ```rb
   * alice = Person.find(1)
   * ```
   */
  class FindCall extends ModelClassMethodCall {
    FindCall() { this.getMethodName() = "find" }
  }

  /**
   * A call to the `create(!)` class method, which returns an ActiveResource model
   * object.
   *
   * ```rb
   * alice = Person.create(name: "alice")
   * ```
   */
  class CreateCall extends ModelClassMethodCall {
    CreateCall() { this.getMethodName() = ["create", "create!"] }
  }

  /**
   * A call to a method that sends a custom HTTP request outside of the
   * ActiveResource conventions. This typically returns an ActiveResource model
   * object. It may return a collection, but we don't currently model that.
   *
   * ```rb
   * alice = Person.get(:active)
   * ```
   */
  class CustomHttpCall extends ModelClassMethodCall {
    CustomHttpCall() { this.getMethodName() = ["get", "post", "put", "patch", "delete"] }
  }

  /**
   * An ActiveResource model object.
   */
  class ModelInstance extends DataFlow::Node {
    ModelClass cls;

    ModelInstance() {
      exists(API::Node model | model = modelApiNode() |
        this = model.getInstance().getAValueReachableFromSource() and
        cls.getModelApiNode() = model
      )
      or
      exists(FindCall call | call.flowsTo(this) | cls = call.getModelClass())
      or
      exists(CreateCall call | call.flowsTo(this) | cls = call.getModelClass())
      or
      exists(CustomHttpCall call | call.flowsTo(this) | cls = call.getModelClass())
      or
      exists(CollectionCall call |
        call.getMethodName() = ["first", "last"] and
        call.flowsTo(this)
      |
        cls = call.getCollection().getModelClass()
      )
    }

    ModelClass getModelClass() { result = cls }
  }

  /**
   * A call to a method on an ActiveResource model object.
   */
  class ModelInstanceMethodCall extends DataFlow::CallNode {
    ModelInstance i;

    ModelInstanceMethodCall() { this.getReceiver() = i }

    ModelInstance getInstance() { result = i }

    ModelClass getModelClass() { result = this.getReceiver().(ModelInstance).getModelClass() }
  }

  /**
   *A collection of ActiveResource model objects.
   */
  class Collection extends DataFlow::Node {
    ModelClassMethodCall classMethodCall;

    Collection() {
      exists(ModelClassMethodCall c | c.flowsTo(this) |
        c.getMethodName() = "all"
        or
        c.getMethodName() = "find" and
        c.getArgument(0).asExpr().getConstantValue().isStringlikeValue("all")
      )
    }

    ModelClass getModelClass() { result = classMethodCall.getModelClass() }
  }

  /**
   * A method call on a collection.
   */
  class CollectionCall extends DataFlow::CallNode {
    CollectionCall() { this.getReceiver() instanceof Collection }

    Collection getCollection() { result = this.getReceiver() }
  }

  private class ModelClassMethodCallAsHttpRequest extends HTTP::Client::Request::Range {
    ModelClassMethodCall call;
    ModelClass cls;

    ModelClassMethodCallAsHttpRequest() {
      this = call.asExpr().getExpr() and
      call.getModelClass() = cls and
      call.getMethodName() = ["all", "build", "create", "create!", "find", "first", "last"]
    }

    override string getFramework() { result = "ActiveResource" }

    override predicate disablesCertificateValidation(DataFlow::Node disablingNode) {
      cls.disablesCertificateValidation(disablingNode)
    }

    override DataFlow::Node getAUrlPart() { result = cls.getASiteAssignment().getAUrlPart() }

    override DataFlow::Node getResponseBody() { result = call }
  }

  private class ModelInstanceMethodCallAsHttpRequest extends HTTP::Client::Request::Range {
    ModelInstanceMethodCall call;
    ModelClass cls;

    ModelInstanceMethodCallAsHttpRequest() {
      this = call.asExpr().getExpr() and
      call.getModelClass() = cls and
      call.getMethodName() =
        [
          "exists?", "reload", "save", "save!", "destroy", "delete", "get", "patch", "post", "put",
          "update_attribute", "update_attributes"
        ]
    }

    override string getFramework() { result = "ActiveResource" }

    override predicate disablesCertificateValidation(DataFlow::Node disablingNode) {
      cls.disablesCertificateValidation(disablingNode)
    }

    override DataFlow::Node getAUrlPart() { result = cls.getASiteAssignment().getAUrlPart() }

    override DataFlow::Node getResponseBody() { result = call }
  }

  /**
   * A call to a class method.
   *
   * TODO: is this general enough to be useful elsewhere?
   *
   * Examples:
   * ```rb
   * class A
   *   def self.m; end
   *
   *   m # call
   * end
   *
   * A.m # call
   * ```
   */
  private DataFlow::CallNode classMethodCall(API::Node classNode, string methodName) {
    // A.m
    result = classNode.getAMethodCall(methodName)
    or
    // class A
    //   A.m
    //  end
    result.getReceiver().asExpr() instanceof ExprNodes::SelfVariableAccessCfgNode and
    result.asExpr().getExpr().getEnclosingModule().(ClassDeclaration).getSuperclassExpr() =
      classNode.getAValueReachableFromSource().asExpr().getExpr() and
    result.getMethodName() = methodName
  }
}
