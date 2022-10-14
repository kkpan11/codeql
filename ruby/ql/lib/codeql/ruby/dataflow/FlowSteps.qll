/**
 * Provides classes representing various flow steps for taint tracking.
 */

private import codeql.ruby.DataFlow
private import internal.DataFlowPrivate as DFPrivate

private class Unit = DFPrivate::Unit;

/**
 * A module importing the frameworks that implement additional flow steps,
 * ensuring that they are visible to the taint tracking library.
 */
private module Frameworks { }

/**
 * A unit class for adding additional taint steps.
 *
 * Extend this class to add additional taint steps that should apply to all
 * taint configurations.
 */
class AdditionalTaintStep extends Unit {
  /**
   * Holds if the step from `node1` to `node2` should be considered a taint
   * step for all configurations.
   */
  abstract predicate step(DataFlow::Node node1, DataFlow::Node node2);
}
