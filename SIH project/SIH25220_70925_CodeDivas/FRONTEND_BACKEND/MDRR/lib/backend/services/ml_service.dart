// lib/backend/services/ml_service.dart

class MlService {
  /// TEMP: dummy model until real TFLite is integrated
  static Future<double> getClinicalRisk(String patientId) async {
    // Later: load patient's clinical data & call TFLite model
    // For now, just return a medium risk 0.5
    return 0.5;
  }
}
