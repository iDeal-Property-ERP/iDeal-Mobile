/// Compatibility surface for existing feature instrumentation.
///
/// Firebase Performance is intentionally not part of the mobile runtime.
/// Keeping these no-op methods lets product flows shed that provider without
/// coupling their behavior to an analytics SDK.
class PerformanceMonitoringService {
  Future<void> initialize() async {}

  void startTrace(String name) {}

  void stopTrace(String name) {}

  void putAttribute(String traceName, String attribute, Object value) {}
}
