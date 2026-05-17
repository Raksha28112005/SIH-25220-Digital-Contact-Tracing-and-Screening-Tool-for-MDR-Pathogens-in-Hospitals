
<div align="center">

# 🦠 SIH-25220 · Digital Contact Tracing & Screening Tool for MDR Pathogens in Hospitals

**Smart India Hackathon 2024 · Problem Statement SIH-25220**  
*Team CodeDivas · #70925 · Ministry of Health & Family Welfare*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-54C5F8?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-≥2.17-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![ONNX](https://img.shields.io/badge/ONNX-Runtime-005CED?style=flat-square)](https://onnxruntime.ai)
[![AWS](https://img.shields.io/badge/AWS-ap--south--1-FF9900?style=flat-square&logo=amazon-aws)](https://aws.amazon.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20·%20iOS%20·%20Windows%20·%20Web-blue?style=flat-square)](https://flutter.dev/multi-platform)
[![License](https://img.shields.io/badge/License-Open%20Source%20SIH-green?style=flat-square)](#)

**A real-time, cross-platform AI-powered tool for MDR pathogen contact tracing, risk scoring, and outbreak prevention in clinical environments.**

</div>

---

## 📑 Table of Contents

1. [Project Overview & Problem Statement](#-project-overview--problem-statement)
2. [System Architecture](#-system-architecture)
3. [Technology Stack](#-technology-stack)
4. [Features & App Screens](#-features--app-screens)
5. [Machine Learning Pipeline](#-machine-learning-pipeline)
6. [Database Schema](#-database-schema)
7. [Risk Assessment Data Flow](#-risk-assessment-data-flow)
8. [Setup & Installation](#-setup--installation)
9. [Societal Impact](#-societal-impact)
10. [Folder Structure](#-folder-structure)
11. [Team](#-team)

---

## 🔬 Project Overview & Problem Statement

### The Problem

**Multi-Drug Resistant (MDR) pathogens** — including MRSA, CRE (Carbapenem-Resistant Enterobacteriaceae), and VRE (Vancomycin-Resistant Enterococcus) — pose a critical, growing threat in hospital settings worldwide, and especially across India's healthcare system.

These pathogens spread silently through:
- Direct patient-to-patient and HCW-to-patient contacts
- Shared medical equipment (ventilators, nebulizers, catheters)
- Patient movements across wards and units (especially ICU transfers)
- Environmental contamination of surfaces

**Manual contact tracing is broken:** it is slow (takes hours to days), error-prone, dependent on human memory, and fundamentally unable to scale to the complexity of a modern hospital floor.

> **SIH Problem Statement #25220** (Ministry of Health and Family Welfare): *"Development of a Digital Contact Tracing and Screening Tool for Multi-Drug Resistant (MDR) Pathogens in Hospitals"*

### Our Solution

Team CodeDivas (#70925) built a **fully offline-capable, cross-platform mobile + desktop application** in Flutter that:

- Automatically logs all patient contacts, ward movements, and equipment usage at the point of care
- Runs a **trained ONNX ML model on-device** to score each patient's MDR infection probability using 19 clinical features
- Combines ML risk with a rule-based **Exposure Risk Engine** for a robust final risk score
- Provides doctors with real-time **Outbreak Alerts** and a detailed risk explanation per patient
- Syncs all data to an **AWS cloud backend** for hospital-wide epidemiological visibility
- Includes a **Digital Twin** module for 3D spatial visualization of patient positions and contact networks

---

## 🏗 System Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER — Flutter App                       │
│          Dart · Material Design 3 · Seed Color: #B3E5FC                  │
│   Android │ iOS │ Windows │ Web │ Linux                                   │
│   ┌───────────────────────┐    ┌───────────────────────┐                 │
│   │   👨‍⚕️ Doctor Login     │    │   👩‍⚕️ Nurse Login      │                 │
│   └───────────────────────┘    └───────────────────────┘                 │
└──────────────────────────────────────────────────────────────────────────┘
          │                                    │
┌─────────▼──────────────┐     ┌───────────────▼──────────────┐
│     DOCTOR SCREENS      │     │        NURSE SCREENS          │
│ • Patient Overview      │     │ • Add Patient                 │
│ • Outbreak Alerts       │     │ • Log Movement                │
│ • Risk Evaluation       │     │ • Equipment Usage             │
│ • Backend Tester        │     │ • Contact Events              │
└────────────────────────┘     │ • Clinical Data               │
                                │ • Sync to Cloud               │
                                └──────────────────────────────┘
          │                                    │
┌─────────▼────────────────────────────────────▼──────────────────────────┐
│                          BUSINESS LOGIC LAYER                             │
│  PatientService │ ContactService │ MovementService │ EquipmentService    │
│  ClinicalService │ RiskService │ SyncService │ BackendTester             │
└──────────────────────────────────────────────────────────────────────────┘
     │                      │                         │
┌────▼──────┐    ┌──────────▼──────────┐    ┌────────▼──────────┐
│  SQLite   │    │   ONNX Runtime      │    │  Exposure Risk    │
│  Local DB │    │   mdr.onnx          │    │  Engine           │
│  (offline)│    │   19-feature model  │    │  (rule-based)     │
└─────┬─────┘    └──────────┬──────────┘    └────────┬──────────┘
      │                     │                         │
      │              ┌──────▼──────────────┐          │
      │              │  FINAL RISK SCORE   │          │
      │              │  0.7×ML + 0.3×Exp  │◄─────────┘
      │              └─────────────────────┘
      │
┌─────▼─────────────────────────────────────────────────────────────────┐
│                        CLOUD LAYER (AWS)                               │
│   API Gateway (ap-south-1) │ Lambda │ DynamoDB/RDS                   │
│   REST POST /sync │ JSON payload │ Offline-first queuing             │
└────────────────────────────────────────────────────────────────────────┘
```

**Digital Twin Module** (separate): Spatial hospital floor mapping, patient location visualization, contact network graph, and outbreak heatmap overlay — built to give infection control teams a bird's-eye view.

---

## 🛠 Technology Stack

| Layer | Technology | Details |
|-------|-----------|---------|
| **Frontend** | Flutter 3.x | Dart ≥2.17, Material Design 3 |
| **Mobile/Desktop** | Android, iOS, Windows, Web, Linux | Single codebase |
| **Local DB** | SQLite via `sqflite ^2.3.0` | `sqflite_common_ffi` for desktop |
| **ML Inference** | ONNX Runtime (`onnxruntime ^1.4.1`) | On-device, 19 input features |
| **ML Training** | Python 3 + scikit-learn + XGBoost | Logistic Regression, RF, XGBoost, DT |
| **ONNX Export** | `skl2onnx` | Converts trained model → `mdr.onnx` |
| **Cloud Sync** | AWS API Gateway | Region: `ap-south-1` (Mumbai) |
| **Networking** | `http ^1.2.0` | REST JSON, offline queue |
| **QR Scanning** | `flutter_zxing`, `mobile_scanner ^3.5.7` | Patient wristband ID scanning |

---

## 📱 Features & App Screens

### 👨‍⚕️ Doctor Features

| Screen | What it does |
|--------|-------------|
| **Patient Overview** | View all registered patients with real-time MDR status flags |
| **Outbreak Alerts** | Real-time warnings when cluster contact patterns are detected |
| **Risk Evaluation** | Enter any Patient ID → get full ML + exposure risk score with explanation |
| **Backend Tester** | Validate DB connectivity and test patient data pipeline |

### 👩‍⚕️ Nurse Features

| Screen | What it does |
|--------|-------------|
| **Add Patient** | Register patient: ID, name, age, ward, MDR known status |
| **Log Movement** | Track ward-to-ward patient transitions with timestamps and duration |
| **Equipment Usage** | Log ventilator, nebulizer, catheter use + shared-with-others flag |
| **Contact Events** | Record HCW–patient and patient–patient contacts with start/end times |
| **Clinical Data** | Enter temperature, comorbidities score, MDR lab result, antibiotic history |
| **Sync to Cloud** | Push all locally pending records to AWS API Gateway |

### 🔒 Shared / Core Features

- **Role-Based Login** — Doctor vs Nurse screens are fully separated, no cross-role data leakage
- **Offline-First Architecture** — Fully functional without internet; `sync_status=0/1` tracks what needs syncing
- **QR Code Scanning** — Scan patient wristband QR codes for fast, error-free patient lookup
- **Digital Twin** — 3D floor map visualization of patient contacts and outbreak zones
- **Risk Scoring** — Hybrid: `70% ONNX ML probability + 30% rule-based exposure score`
- **Human-Readable Explanations** — "High risk because: age ≥ 60, fever, previous MDR infection"

---

## 🤖 Machine Learning Pipeline

```
┌──────────────┐    ┌───────────────────┐    ┌────────────────────┐
│ Data         │    │ Feature           │    │ Python Training    │
│ Collection   │───►│ Engineering       │───►│                    │
│              │    │                   │    │ • Logistic Regr.   │
│ • Patient    │    │ 19 Features:      │    │ • Random Forest    │
│   surveys    │    │ timestamp, age,   │    │ • XGBoost          │
│ • Lab data   │    │ gender, ward,     │    │ • Decision Tree    │
│ • Movement   │    │ movement_path,    │    └────────┬───────────┘
│   logs       │    │ equipment_used,   │             │
│ • Equipment  │    │ sputum_result,    │    ┌────────▼───────────┐
│   records    │    │ antibiotic,       │    │ ONNX Export        │
└──────────────┘    │ duration_hours,   │    │ (skl2onnx)         │
                    │ temp_c, HR, BP,   │    │ → mdr.onnx         │
                    │ WBC, nurse_count, │    └────────┬───────────┘
                    │ surface_score,    │             │
                    │ ventilation,      │    ┌────────▼───────────┐
                    │ prior_admissions, │    │ On-Device ONNX     │
                    │ resistance_marker │    │ Inference (Flutter)│
                    └───────────────────┘    │ P(MDR) → 0 to 1   │
                                             └────────────────────┘
```

### Risk Score Formula

```dart
// lib/backend/services/risk_service.dart

final double backendRisk = ExposureRiskEngine.calculateExposureRisk(
  movements: movements,
  equipmentUsages: equipmentUsages,
  contactEvents: contactEvents,
);

final double mlRisk = _computeMlClinicalRisk(
  age: age,
  obs: clinicalObs,
  durationHours: durationHours,
);

// Hybrid weighted combination
final double finalRisk = (0.7 * mlRisk) + (0.3 * backendRisk);
```

### Clinical Risk Weights (Logistic Regression)

| Feature | Coefficient |
|---------|------------|
| Lab MDR Positive | **+1.5** (strongest predictor) |
| Previous MDR History | **+1.2** |
| Comorbidities Score | +0.4 per point |
| Temperature (above 37°C) | +0.5 per degree |
| Exposure Duration | +0.15 per hour |
| Age | +0.03 per year |

### Exposure Risk Engine Rules

- **ICU time > 0 min** → +5 pts; **> 60 min** → +3 more pts
- **Visited ≥ 3 wards** → +4 pts
- **Ventilator use** → +5 pts; **shared** → +2 more
- **Nebulizer use** → +4 pts; **shared** → +2 more
- **Catheter/central line** → +3 pts
- **Contact ≥ 15 min** → +3 pts; **≥ 60 min** → +2 more
- **≥ 5 contact events** → +4 pts
- Normalized to 0–1 range

---

## 🗄 Database Schema

All tables stored in **SQLite** locally. Every table has `sync_status INTEGER` (0 = pending, 1 = synced).

### `patients`
| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT PRIMARY KEY | Hospital patient ID |
| `name` | TEXT | Patient full name |
| `age` | INTEGER | Used in ML risk model |
| `ward` | TEXT | Current ward (ICU, Gen, etc.) |
| `is_mdr_known` | INTEGER | 0/1 boolean MDR status flag |
| `sync_status` | INTEGER | Cloud sync tracking |

### `contact_events`
| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER PRIMARY KEY | Auto-increment |
| `patient_id` | TEXT FK | → patients.id |
| `contact_patient_id` | TEXT FK | The other patient/HCW |
| `start_time` | TEXT | ISO 8601 datetime |
| `end_time` | TEXT | ISO 8601 datetime |
| `sync_status` | INTEGER | |

### `movements`
| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER PRIMARY KEY | |
| `patient_id` | TEXT FK | |
| `ward` | TEXT | Destination ward |
| `timestamp` | TEXT | When movement occurred |
| `duration_minutes` | INTEGER | Time spent in ward |

### `clinical_observations`
| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER PRIMARY KEY | |
| `patient_id` | TEXT FK | |
| `temperature` | REAL | °C — used in risk model |
| `comorbidities_score` | INTEGER | 0–5 scale |
| `previous_mdr_history` | INTEGER | Boolean 0/1 |
| `lab_mdr_positive` | INTEGER | Current lab result |

**Additional tables:** `equipment_usage` · `risk_scores` · `user_roles`

---

## 🌊 Risk Assessment Data Flow

```
① Nurse Input        ② SQLite Store       ③ Dual Scoring         ④ Combine
┌──────────────┐    ┌──────────────┐    ┌───────────────────┐    ┌──────────────┐
│ Log contact  │    │ Local DB     │    │ ONNX Runtime      │    │ Risk Service │
│ Log movement │───►│ sync_status=0│───►│ 19 features → P() │───►│ 0.7×ML       │
│ Log equip.   │    │              │    ├───────────────────┤    │ + 0.3×Exp    │
│ Add clinical │    └──────────────┘    │ Exposure Engine   │    │ = Final 0–1  │
└──────────────┘                        │ Rules → 0–1 score │    └──────┬───────┘
                                        └───────────────────┘           │
                                                                         ▼
⑥ Doctor View        ⑤ Persist in DB                          Save to risk_scores
┌──────────────┐    ┌──────────────┐                          + explanation text
│ HIGH / MED   │◄───│ risk_scores  │◄─────────────────────────────────────────────
│ Risk + text  │    │ table        │
│ Outbreak ?   │    └──────────────┘
└──────────────┘
        │
        ▼ (when online)
  SyncService → AWS API Gateway → Cloud DB
```

---

## ⚙️ Setup & Installation

### Prerequisites

- **Flutter SDK** ≥ 3.0 (`dart ≥ 2.17`)
- **Android Studio** or **VS Code** with Flutter/Dart plugins
- **Android SDK** (for Android builds) or **Xcode** (for iOS builds)
- **Python 3.8+** with `pandas`, `scikit-learn`, `xgboost`, `skl2onnx` *(only needed for ML retraining)*
- **Git**

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/Raksha28112005/SIH-25220-Digital-Contact-Tracing-and-Screening-Tool-for-MDR-Pathogens-in-Hospitals.git

# 2. Navigate to the Flutter app
cd "SIH project/SIH25220_70925_CodeDivas/FRONTEND_BACKEND/MDRR"

# 3. Install Flutter dependencies
flutter pub get

# 4. Verify ONNX model is present
ls assets/models/mdr.onnx  # Should exist

# 5. Run on your target platform
flutter run                   # Android device/emulator
flutter run -d windows        # Windows desktop
flutter run -d chrome         # Web browser (SQLite DB disabled on web)
```

### ML Retraining (Optional)

```bash
cd "SIH project/SIH25220_70925_CodeDivas/Machine_Learning/ml_model_training"

# Run any of the model notebooks/scripts
# e.g., XG_Boost/ or Random Forest/

# After training, export to ONNX
python -c "
from skl2onnx import convert_sklearn
# ... convert your trained model
# Save to MDRR/assets/models/mdr.onnx
"
```

### AWS Configuration

In `lib/backend/services/sync_service.dart`, update the endpoint:

```dart
static const String baseUrl =
    'https://YOUR_API_GATEWAY_ID.execute-api.ap-south-1.amazonaws.com';
```

---

## 🌍 Societal Impact

### Why this matters for India and the world

| Impact Area | Description |
|-------------|-------------|
| 🏥 **Hospital Infection Control** | Enables infection control teams to trace MDR contacts within hours instead of days, preventing cluster outbreaks before they escalate into full hospital-wide events |
| 💊 **Antibiotic Stewardship** | Earlier identification of high-risk patients allows targeted antibiotic therapy, reducing empirical broad-spectrum use — directly slowing AMR evolution |
| 📊 **Public Health Surveillance** | Cloud-aggregated data creates a real-time AMR epidemiology layer supporting ICMR's National Action Plan on AMR and WHO surveillance requirements |
| 🧠 **AI-Driven Decision Support** | Provides evidence-based risk stratification at point-of-care without requiring specialist consultation — critical for under-resourced hospitals |
| 📱 **Offline-First for Rural India** | Fully functional on Android without internet. Data queues locally and syncs when available — making digital contact tracing accessible to Tier-2/3 hospitals and PHCs |
| 💰 **Economic Savings** | HAIs cost India's healthcare system billions annually in extended ICU stays and repeat treatments. Early MDR detection significantly reduces per-case cost |

### Target Beneficiaries

- Government Hospitals · Private Hospital Chains · AIIMS & Medical Colleges
- ICU & Critical Care Units · District Health Authorities
- ICMR / WHO Surveillance Networks
- Infection Control Nurses · Microbiologists · Epidemiologists

---

## 📂 Folder Structure

```
SIH-25220/
├── README.md
└── SIH project/
    └── SIH25220_70925_CodeDivas/
        ├── FRONTEND_BACKEND/
        │   ├── DIGITAL TWIN DOCUMENTATION.pdf
        │   ├── FRONTEND DOCUMENTATION.pdf
        │   ├── backend documentation.docx
        │   ├── DIGITAL_TWIN/              # Hospital 3D map module
        │   └── MDRR/                      # Main Flutter application
        │       ├── pubspec.yaml
        │       ├── assets/models/
        │       │   └── mdr.onnx           # Trained ONNX model
        │       ├── lib/
        │       │   ├── main.dart          # App entry + role login + home screen
        │       │   ├── screens/
        │       │   │   ├── patient_form_screen.dart
        │       │   │   ├── patient_overview_screen.dart
        │       │   │   ├── contact_screen.dart
        │       │   │   ├── movement_screen.dart
        │       │   │   ├── equipment_screen.dart
        │       │   │   ├── clinical_data_screen.dart
        │       │   │   └── outbreak_alerts_screen.dart
        │       │   ├── backend/
        │       │   │   ├── models/
        │       │   │   │   ├── patient.dart
        │       │   │   │   ├── contact_event.dart
        │       │   │   │   ├── movement.dart
        │       │   │   │   ├── equipment_usage.dart
        │       │   │   │   ├── clinical_observation.dart
        │       │   │   │   └── risk_score.dart
        │       │   │   ├── services/
        │       │   │   │   ├── patient_service.dart
        │       │   │   │   ├── contact_service.dart
        │       │   │   │   ├── movement_service.dart
        │       │   │   │   ├── equipment_service.dart
        │       │   │   │   ├── clinical_service.dart
        │       │   │   │   ├── risk_service.dart      # Hybrid risk engine (70/30)
        │       │   │   │   ├── exposure_risk_engine.dart  # Rule-based exposure
        │       │   │   │   ├── mdr_onnx_model.dart    # ONNX inference wrapper
        │       │   │   │   ├── ml_service.dart
        │       │   │   │   ├── sync_service.dart      # AWS cloud sync
        │       │   │   │   └── backend_tester.dart
        │       │   │   └── db/
        │       │   │       └── app_database.dart      # SQLite init + all tables
        │       │   └── utils/
        │       └── android/ ios/ windows/ linux/ web/ macos/
        ├── Machine_Learning/
        │   ├── DataCollection&Survey.pdf
        │   ├── ML MODEL DOCUMENTATION.pdf
        │   └── ml_model_training/
        │       ├── Logistic_regression/
        │       ├── Random Forest/
        │       ├── XG_Boost/
        │       └── decision_tree/
        ├── NOVELTY.pdf
        └── PRESENTATION.pdf
```

---

## 👥 Team

| | |
|--|--|
| **Team Name** | CodeDivas |
| **Team Number** | #70925 |
| **Hackathon** | Smart India Hackathon 2024 |
| **Problem Statement** | SIH-25220 |
| **Ministry** | Ministry of Health & Family Welfare, Government of India |
| **Repository** | [Raksha28112005/SIH-25220](https://github.com/Raksha28112005/SIH-25220-Digital-Contact-Tracing-and-Screening-Tool-for-MDR-Pathogens-in-Hospitals) |

---

<div align="center">

**Built with ❤️ by Team CodeDivas for Smart India Hackathon 2024**

*Protecting patients. Containing outbreaks. Empowering clinicians.*

`Flutter` · `Dart` · `SQLite` · `ONNX Runtime` · `AWS API Gateway` · `Python ML`

</div>
