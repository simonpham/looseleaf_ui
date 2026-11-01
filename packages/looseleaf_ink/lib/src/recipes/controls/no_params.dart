/// The params of a recipe that takes none (upstream `Record<string, never>`).
final class NoParams {
  /// No params.
  const NoParams();

  /// Upstream's params object, for memo keys: always `{}`.
  Map<String, Object?> toJson() => const {};
}
