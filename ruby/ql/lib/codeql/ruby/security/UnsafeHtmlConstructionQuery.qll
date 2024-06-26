/**
 * Provides a taint-tracking configuration for reasoning about HTML
 * constructed from library input vulnerabilities.
 *
 * Note, for performance reasons: only import this file if
 * `UnsafeHtmlConstructionFlow` is needed, otherwise
 * `UnsafeHtmlConstructionCustomizations` should be imported instead.
 */

import codeql.ruby.DataFlow
import UnsafeHtmlConstructionCustomizations::UnsafeHtmlConstruction
private import codeql.ruby.TaintTracking
private import codeql.ruby.dataflow.BarrierGuards

/**
 * A taint-tracking configuration for detecting unsafe HTML construction.
 * DEPRECATED: Use `UnsafeHtmlConstructionFlow`
 */
deprecated class Configuration extends TaintTracking::Configuration {
  Configuration() { this = "UnsafeHtmlConstruction" }

  override predicate isSource(DataFlow::Node source) { source instanceof Source }

  override predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  override predicate isSanitizer(DataFlow::Node node) { node instanceof Sanitizer }

  // override to require the path doesn't have unmatched return steps
  override DataFlow::FlowFeature getAFeature() {
    result instanceof DataFlow::FeatureHasSourceCallContext
  }
}

private module UnsafeHtmlConstructionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sink }

  predicate isBarrier(DataFlow::Node node) { node instanceof Sanitizer }

  // override to require the path doesn't have unmatched return steps
  DataFlow::FlowFeature getAFeature() { result instanceof DataFlow::FeatureHasSourceCallContext }
}

/**
 * Taint-tracking for detecting unsafe HTML construction.
 */
module UnsafeHtmlConstructionFlow = TaintTracking::Global<UnsafeHtmlConstructionConfig>;
