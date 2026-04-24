// lib/utils/pathogen_data.dart

class PathogenInfo {
  final String name;
  final String syndrome;
  final String transmission;

  const PathogenInfo({
    required this.name,
    required this.syndrome,
    required this.transmission,
  });
}

/// Your table converted to Dart:
const List<PathogenInfo> pathogenInfos = [
  PathogenInfo(
    name: 'Acinetobacter baumannii',
    syndrome: 'Other',
    transmission:
        'Contact with contaminated surfaces and equipment; possible airborne spread in ICU dust.',
  ),
  PathogenInfo(
    name: 'Dengue virus',
    syndrome: 'AUFI',
    transmission: 'Vector-borne via Aedes mosquitoes.',
  ),
  PathogenInfo(
    name: 'Dengue virus (neuro)',
    syndrome: 'AES',
    transmission: 'Vector-borne via Aedes mosquitoes.',
  ),
  PathogenInfo(
    name: 'E. coli',
    syndrome: 'Acute Diarrhoeal Disease',
    transmission:
        'Fecal–oral route; contaminated food/water or hands.',
  ),
  PathogenInfo(
    name: 'E. coli (ESBL)',
    syndrome: 'Other',
    transmission:
        'Fecal–oral route; contaminated surfaces and devices.',
  ),
  PathogenInfo(
    name: 'Influenza A/B',
    syndrome: 'ARI',
    transmission: 'Respiratory droplets, aerosols and contact.',
  ),
  PathogenInfo(
    name: 'Japanese Encephalitis virus',
    syndrome: 'AES',
    transmission: 'Vector-borne via Culex mosquitoes.',
  ),
  PathogenInfo(
    name: 'Klebsiella pneumoniae',
    syndrome: 'Other',
    transmission:
        'Contact via hands of healthcare workers and invasive devices.',
  ),
  PathogenInfo(
    name: 'Leptospira sp.',
    syndrome: 'AUFI',
    transmission:
        'Water/soil contaminated with infected animal urine.',
  ),
  PathogenInfo(
    name: 'Mycobacterium tuberculosis',
    syndrome: 'ARI',
    transmission: 'Airborne transmission via droplet nuclei.',
  ),
  PathogenInfo(
    name: 'Nipah virus',
    syndrome: 'AES',
    transmission:
        'Zoonotic (bats/pigs), contaminated food, respiratory droplets.',
  ),
  PathogenInfo(
    name: 'Plasmodium sp.',
    syndrome: 'AUFI',
    transmission:
        'Vector-borne via Anopheles mosquitoes.',
  ),
  PathogenInfo(
    name: 'Pseudomonas aeruginosa',
    syndrome: 'Other',
    transmission:
        'Contact with contaminated water, equipment, and hospital surfaces.',
  ),
  PathogenInfo(
    name: 'RSV',
    syndrome: 'ARI',
    transmission:
        'Respiratory droplets and contact with respiratory secretions.',
  ),
  PathogenInfo(
    name: 'Rotavirus',
    syndrome: 'Acute Diarrhoeal Disease',
    transmission:
        'Fecal–oral; contaminated hands and surfaces.',
  ),
  PathogenInfo(
    name: 'SARS-CoV-2',
    syndrome: 'ARI',
    transmission:
        'Respiratory droplets, aerosols, surface contact.',
  ),
  PathogenInfo(
    name: 'Salmonella Typhi',
    syndrome: 'AUFI',
    transmission:
        'Fecal–oral via contaminated food and water.',
  ),
  PathogenInfo(
    name: 'Shigella sp.',
    syndrome: 'Acute Diarrhoeal Disease',
    transmission:
        'Fecal–oral transmission via contaminated food/water.',
  ),
  PathogenInfo(
    name: 'Streptococcus pneumoniae',
    syndrome: 'ARI',
    transmission: 'Respiratory droplets.',
  ),
  PathogenInfo(
    name: 'Vibrio cholerae',
    syndrome: 'Acute Diarrhoeal Disease',
    transmission:
        'Fecal–oral via contaminated water/food.',
  ),
];

/// Unique syndrome values for the second dropdown.
const List<String> syndromeOptions = [
  'ARI',
  'AUFI',
  'AES',
  'Acute Diarrhoeal Disease',
  'Other',
];

PathogenInfo? findPathogenByName(String name) {
  for (final p in pathogenInfos) {
    if (p.name == name) return p;
  }
  return null;
}
