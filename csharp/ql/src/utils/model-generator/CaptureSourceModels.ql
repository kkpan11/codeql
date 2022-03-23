/**
 * @name Capture source models.
 * @description Finds APIs that act as sources as they expose already known sources.
 * @id csharp/utils/model-generator/sink-models
 */

private import internal.ModelGeneratorUtils
private import internal.CaptureModels

from TargetApi api, string sink
where sink = captureSource(api)
select sink order by sink
