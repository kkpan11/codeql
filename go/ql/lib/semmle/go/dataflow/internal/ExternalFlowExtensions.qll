/**
 * This module provides extensible predicates for defining MaD models.
 */

/**
 * Holds if a source model exists for the given parameters.
 */
extensible predicate sourceModel(
  string package, string type, boolean subtypes, string name, string signature, string ext,
  string output, string kind, string provenance, QlBuiltins::ExtensionId madId
);

/**
 * Holds if a sink model exists for the given parameters.
 */
extensible predicate sinkModel(
  string package, string type, boolean subtypes, string name, string signature, string ext,
  string input, string kind, string provenance, QlBuiltins::ExtensionId madId
);

/**
 * Holds if a summary model exists for the given parameters.
 */
extensible predicate summaryModel(
  string package, string type, boolean subtypes, string name, string signature, string ext,
  string input, string output, string kind, string provenance, QlBuiltins::ExtensionId madId
);
