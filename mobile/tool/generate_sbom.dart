// Sinh SBOM định dạng SPDX 2.3 từ pubspec.lock.
// Chạy trong mobile/: dart run tool/generate_sbom.dart
import 'dart:convert';
import 'dart:io';

class LockedPackage {
  const LockedPackage({
    required this.name,
    required this.version,
    required this.source,
    this.sha256,
  });

  final String name;
  final String version;
  final String source;
  final String? sha256;
}

/// Đọc các gói trong nội dung pubspec.lock.
List<LockedPackage> parseLockPackages(String lockText) {
  final body = lockText.split(RegExp(r'^sdks:', multiLine: true)).first;
  final blocks = RegExp(
    r'^  ([a-zA-Z0-9_]+):\n((?:    .*\n)+)',
    multiLine: true,
  ).allMatches(body);
  return [
    for (final block in blocks)
      LockedPackage(
        name: block[1]!,
        version: RegExp(r'version: "([^"]+)"').firstMatch(block[2]!)![1]!,
        source: RegExp(r'^    source: (\S+)', multiLine: true)
            .firstMatch(block[2]!)![1]!,
        sha256: RegExp(r'sha256: "([0-9a-f]+)"').firstMatch(block[2]!)?[1],
      ),
  ];
}

/// Nhận diện giấy phép phổ biến từ văn bản LICENSE.
String detectLicense(String licenseText) {
  final text = licenseText.replaceAll(RegExp(r'\s+'), ' ');
  if (text.contains('Apache License')) return 'Apache-2.0';
  if (text.contains('Mozilla Public License')) return 'MPL-2.0';
  if (text.contains('Permission is hereby granted, free of charge')) {
    return 'MIT';
  }
  if (text.contains('Redistribution and use in source and binary forms')) {
    return text.contains('Neither the name') ? 'BSD-3-Clause' : 'BSD-2-Clause';
  }
  return 'NOASSERTION';
}

/// Thư mục gốc của từng gói, lấy từ .dart_tool/package_config.json.
Map<String, Directory> packageRoots(String packageConfigPath) {
  final file = File(packageConfigPath);
  final config = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  return {
    for (final entry in (config['packages']! as List).cast<Map>())
      entry['name'] as String: Directory.fromUri(
        file.absolute.uri.resolve('${entry['rootUri']}/'),
      ),
  };
}

String _licenseOf(LockedPackage package, Map<String, Directory> roots) {
  final root = roots[package.name];
  if (root == null) return 'NOASSERTION';
  final file = File('${root.path}/LICENSE');
  return file.existsSync()
      ? detectLicense(file.readAsStringSync())
      : 'NOASSERTION';
}

Map<String, Object?> buildSbom({
  required String appVersion,
  required DateTime created,
  required List<LockedPackage> packages,
  required String Function(LockedPackage package) licenseOf,
}) {
  String spdxId(String name) => 'SPDXRef-Package-${name.replaceAll('_', '-')}';
  return {
    'spdxVersion': 'SPDX-2.3',
    'dataLicense': 'CC0-1.0',
    'SPDXID': 'SPDXRef-DOCUMENT',
    'name': 'toado-$appVersion',
    'documentNamespace':
        'https://github.com/phamphuongphuongnd/taodo/sbom/$appVersion',
    'creationInfo': {
      'created': '${created.toUtc().toIso8601String().split('.').first}Z',
      'creators': ['Tool: toado-generate_sbom'],
    },
    'packages': [
      {
        'name': 'toado',
        'SPDXID': 'SPDXRef-Package-toado',
        'versionInfo': appVersion,
        'downloadLocation': 'https://github.com/phamphuongphuongnd/taodo',
        'filesAnalyzed': false,
        'licenseConcluded': 'NOASSERTION',
        'licenseDeclared': 'NOASSERTION',
        'copyrightText': 'NOASSERTION',
      },
      for (final package in packages)
        {
          'name': package.name,
          'SPDXID': spdxId(package.name),
          'versionInfo': package.version,
          'downloadLocation': package.source == 'hosted'
              ? 'https://pub.dev/packages/${package.name}/versions/${package.version}'
              : 'NOASSERTION',
          'filesAnalyzed': false,
          'licenseConcluded': licenseOf(package),
          'licenseDeclared': licenseOf(package),
          'copyrightText': 'NOASSERTION',
          if (package.sha256 != null)
            'checksums': [
              {'algorithm': 'SHA256', 'checksumValue': package.sha256},
            ],
        },
    ],
    'relationships': [
      {
        'spdxElementId': 'SPDXRef-DOCUMENT',
        'relationshipType': 'DESCRIBES',
        'relatedSpdxElement': 'SPDXRef-Package-toado',
      },
      for (final package in packages)
        {
          'spdxElementId': 'SPDXRef-Package-toado',
          'relationshipType': 'DEPENDS_ON',
          'relatedSpdxElement': spdxId(package.name),
        },
    ],
  };
}

void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final version = RegExp(
    r'^version: (\S+)\+\d+',
    multiLine: true,
  ).firstMatch(pubspec)![1]!;
  final packages = parseLockPackages(File('pubspec.lock').readAsStringSync());
  final roots = packageRoots('.dart_tool/package_config.json');
  // Font đóng gói trong assets, không nằm trong pubspec.lock.
  const font = LockedPackage(
    name: 'Manrope',
    version: 'google-fonts-2026-11-01',
    source: 'asset',
  );

  final sbom = buildSbom(
    appVersion: version,
    created: DateTime.now(),
    packages: [...packages, font],
    licenseOf: (package) =>
        package == font ? 'OFL-1.1' : _licenseOf(package, roots),
  );
  final output = File('../docs/compliance/sbom.spdx.json')
    ..createSync(recursive: true)
    ..writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(sbom)}\n',
    );
  final unknown = packages
      .where((package) => _licenseOf(package, roots) == 'NOASSERTION')
      .map((package) => package.name);
  stdout.writeln('${packages.length} goi -> ${output.path}');
  stdout.writeln('Chua nhan dien giay phep: ${unknown.join(', ')}');
}
