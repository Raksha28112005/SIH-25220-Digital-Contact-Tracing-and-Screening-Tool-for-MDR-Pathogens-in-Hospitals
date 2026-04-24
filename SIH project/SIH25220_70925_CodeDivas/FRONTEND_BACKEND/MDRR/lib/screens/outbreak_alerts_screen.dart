import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../backend/models/patient.dart';
import '../backend/models/risk_score.dart';
import '../backend/services/patient_service.dart';
import '../backend/services/risk_service.dart';

class OutbreakAlertsScreen extends StatefulWidget {
  const OutbreakAlertsScreen({super.key});

  @override
  State<OutbreakAlertsScreen> createState() => _OutbreakAlertsScreenState();
}

class _OutbreakAlertsScreenState extends State<OutbreakAlertsScreen> {
  final _patientService = PatientService();
  final _riskService = RiskService();

  bool _loading = false;
  List<_PatientRiskView> _results = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Outbreak Alerts',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
      ),

      // --------------------- BODY --------------------
      body: Column(
        children: [
          // 🔹 Top Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Run Outbreak Detection",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF37474F),
                  ),
                ),
                const SizedBox(height: 8),

                FilledButton.icon(
                  onPressed: _loading ? null : _runScan,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.warning_amber_rounded),
                  label: const Text("Scan Environment"),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5C6BC0),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ---------------- LIST -----------------
          Expanded(child: _buildBody(theme)),
        ],
      ),
    );
  }

  // ------------------------------------------
  // BUILD BODY CONTENT
  // ------------------------------------------
  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF5C6BC0)));
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety_rounded,
                size: 70, color: const Color(0xFF5C6BC0)),
            const SizedBox(height: 12),
            const Text(
              "No alerts yet.\nAdd patients and log movements/contacts,\nthen run the scan.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF37474F)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _results[index];

        return _buildRiskCard(item, theme);
      },
    );
  }

  // ------------------------------------------
  // RISK CARD UI
  // ------------------------------------------
  Widget _buildRiskCard(_PatientRiskView item, ThemeData theme) {
    final risk = item.riskScore;
    final patient = item.patient;

    final riskPercent = (risk.finalRisk * 100).toStringAsFixed(1);
    final color = _riskColor(risk.riskCategory);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 🔹 Colored circle
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.15),
              child: Text(
                risk.riskCategory.substring(0, 1),
                style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(width: 16),

            // 🔹 Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${patient.name} (${patient.id})",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF37474F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ward: ${patient.ward}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF546E7A),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 🔹 Risk chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${risk.riskCategory} Risk • $riskPercent%",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------
  // RUN SCAN
  // ------------------------------------------
  Future<void> _runScan() async {
    final messenger = ScaffoldMessenger.of(context);

    if (kIsWeb) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Outbreak scan uses local DB. Run on Android/Windows for real data.',
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final patients = await _patientService.getAllPatients();
      final List<_PatientRiskView> results = [];

      for (final p in patients) {
        final risk = await _riskService.evaluatePatientRisk(p.id);

        if (risk.riskCategory != 'LOW') {
          results.add(_PatientRiskView(patient: p, riskScore: risk));
        }
      }

      results.sort(
        (a, b) => b.riskScore.finalRisk.compareTo(a.riskScore.finalRisk),
      );

      if (!mounted) return;

      setState(() {
        _results = results;
      });

      if (results.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No medium/high-risk patients detected.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error during scan: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ------------------- COLORS --------------------
  Color _riskColor(String category) {
    switch (category.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFEF5350);
      case 'MEDIUM':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFF66BB6A);
    }
  }
}

class _PatientRiskView {
  final Patient patient;
  final RiskScore riskScore;

  _PatientRiskView({
    required this.patient,
    required this.riskScore,
  });
}