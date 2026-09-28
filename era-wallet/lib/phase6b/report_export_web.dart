import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';

import 'report_export_types.dart';
import 'test_report.dart';

export 'report_export_types.dart';

class Phase6bReportExporter {
  final Future<ShareResult> Function(ShareParams params) _share;

  Phase6bReportExporter({
    Future<ShareResult> Function(ShareParams params)? share,
  }) : _share = share ?? SharePlus.instance.share;

  Future<Phase6bSavedReport> save(
    Phase6bTestReport report, {
    String? fileStem,
  }) {
    return Future.error(
      UnsupportedError(
        'Saving Phase 6B reports to an application documents directory is '
        'not supported on web. Use share() to share or download the generated '
        'JSON and Markdown files.',
      ),
    );
  }

  Future<ShareResult> share(
    Phase6bTestReport report, {
    String? fileStem,
    Rect? sharePositionOrigin,
  }) {
    final payload = report.exportPayload;
    final stem = fileStem == null
        ? _defaultFileStem(report)
        : _safeProvidedFileStem(fileStem);
    final jsonName = '$stem.json';
    final markdownName = '$stem.md';

    return _share(
      ShareParams(
        subject: 'ERA Phase 6B lifecycle report ${report.testSessionId}',
        text: report.copySummary,
        files: [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(payload.json)),
            mimeType: 'application/json',
            name: jsonName,
          ),
          XFile.fromData(
            Uint8List.fromList(utf8.encode(payload.markdown)),
            mimeType: 'text/markdown',
            name: markdownName,
          ),
        ],
        fileNameOverrides: [jsonName, markdownName],
        downloadFallbackEnabled: true,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  static String _safeFilePart(String value) {
    final safe = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '-');
    return safe.length <= 80 ? safe : safe.substring(0, 80);
  }

  static String _defaultFileStem(Phase6bTestReport report) {
    final session = _safeFilePart(report.testSessionId);
    final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    return 'era-phase6b-$session-$stamp';
  }

  static String _safeProvidedFileStem(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(value, 'fileStem', 'Must not be empty.');
    }
    final safe = _safeFilePart(trimmed);
    if (safe == '.' || safe == '..') {
      throw ArgumentError.value(
        value,
        'fileStem',
        'Must identify a report artifact.',
      );
    }
    return safe;
  }
}
