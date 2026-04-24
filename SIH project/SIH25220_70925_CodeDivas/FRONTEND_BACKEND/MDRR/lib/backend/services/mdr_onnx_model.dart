// lib/backend/services/mdr_onnx_model.dart

import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';

class MdrOnnxModel {
  MdrOnnxModel._internal();
  static final MdrOnnxModel _instance = MdrOnnxModel._internal();
  factory MdrOnnxModel() => _instance;

  OrtSession? _session;

  Future<void> _init() async {
    if (_session != null) return;

    OrtEnv.instance.init();

    // Make sure this matches pubspec.yaml and the actual file name
    const assetPath = 'assets/models/mdr.onnx';
    final raw = await rootBundle.load(assetPath);
    final bytes = raw.buffer.asUint8List();

    final sessionOptions = OrtSessionOptions();
    _session = OrtSession.fromBuffer(bytes, sessionOptions);
  }

  /// Call with map of ONNX inputs.
  /// Keys MUST match your model inputs exactly:
  /// timestamp, age, gender, ward, movement_path, equipment_used, ...
  Future<double> predictMdrProbability(
    Map<String, Object> featureValues,
  ) async {
    await _init();
    if (_session == null) {
      throw StateError('ONNX session not created');
    }

    final Map<String, OrtValue> inputs = {};

    // Explicit list of your 19 inputs in correct order
    const inputNames = [
      'timestamp',
      'age',
      'gender',
      'ward',
      'movement_path',
      'equipment_used',
      'sputum_result',
      'antibiotic_given',
      'duration_hours',
      'temp_c',
      'heart_rate',
      'systolic_bp',
      'diastolic_bp',
      'wbc_count',
      'nurse_contact_count',
      'surface_contamination_score',
      'ventilation_quality_index',
      'prior_admissions_6months',
      'antibiotic_resistance_marker',
    ];

        // Inputs that the ONNX model expects as int64
    const intInputs = {
      'prior_admissions_6months',
      'antibiotic_resistance_marker',
    };

    for (final name in inputNames) {
      final value = featureValues[name];
      if (value == null) {
        throw StateError('Missing value for ONNX input "$name"');
      }

      if (value is num) {
        if (intInputs.contains(name)) {
          // ONNX expects int64 for these
          inputs[name] = OrtValueTensor.createTensorWithDataList(
            <int>[value.toInt()],
            [1, 1],
          );
        } else {
          // float inputs
          inputs[name] = OrtValueTensor.createTensorWithDataList(
            <double>[value.toDouble()],
            [1, 1],
          );
        }
      } else if (value is String) {
        // string -> tensor shape [1, 1]
        inputs[name] = OrtValueTensor.createTensorWithDataList(
          <String>[value],
          [1, 1],
        );
      } else {
        throw StateError(
          'Unsupported type for "$name": ${value.runtimeType}',
        );
      }
    }











    final runOptions = OrtRunOptions();
    final outputs = _session!.run(runOptions, inputs);

    // clean up inputs + options
    for (final v in inputs.values) {
      v.release();
    }
    runOptions.release();

    if (outputs.isEmpty) {
      throw StateError('ONNX produced no outputs');
    }

    // skl2onnx usually puts probabilities in the second output
    final OrtValueTensor probTensor = (outputs.length > 1
            ? outputs[1]
            : outputs[0])!
        as OrtValueTensor;

    final value = probTensor.value;
    probTensor.release();

    double p;

    if (value is List) {
      if (value.isEmpty) {
        throw StateError('Empty probability tensor');
      }
      final first = value.first;
      if (first is List) {
        // e.g. [[0.2, 0.8]] → take prob of class 1 (last element)
        if (first.isEmpty) {
          throw StateError('Empty inner probability list');
        }
        p = (first.last as num).toDouble();
      } else if (first is num) {
        // e.g. [0.8]
        p = first.toDouble();
      } else {
        throw StateError('Unexpected probability tensor shape: $value');
      }
    } else if (value is num) {
      p = value.toDouble();
    } else {
      throw StateError(
        'Unexpected probability tensor type: ${value.runtimeType}',
      );
    }

    if (p < 0.0) p = 0.0;
    if (p > 1.0) p = 1.0;
    return p;
  }
}
