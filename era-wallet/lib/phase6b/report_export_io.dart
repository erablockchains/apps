import 'dart:io';
import 'dart:ui' show Rect;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'report_export_types.dart';
import 'test_report.dart';

export 'report_export_types.dart';

class Phase6bReportExporter {
  final Future<Directory> Function() documentsDirectory;
  final Future<void> Function(String checkpoint)? pairWriteCheckpoint;

  Phase6bReportExporter({
    Future<Directory> Function()? documentsDirectory,
    this.pairWriteCheckpoint,
  }) : documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory;

  Future<Phase6bSavedReport> save(
    Phase6bTestReport report, {
    String? fileStem,
  }) async {
    final root = await documentsDirectory();
    final separator = Platform.pathSeparator;
    final directory = Directory(
      '${root.path}${separator}ERA Wallet${separator}Phase6B Reports',
    );
    await directory.create(recursive: true);
    final stem = fileStem == null
        ? _defaultFileStem(report)
        : _safeProvidedFileStem(fileStem);
    final base = '${directory.path}$separator$stem';
    final payload = report.exportPayload;
    final jsonFile = File('$base.json');
    final markdownFile = File('$base.md');
    await _writePairAtomically(
      jsonFile: jsonFile,
      json: payload.json,
      markdownFile: markdownFile,
      markdown: payload.markdown,
    );
    return Phase6bSavedReport(
      jsonPath: jsonFile.path,
      markdownPath: markdownFile.path,
    );
  }

  Future<ShareResult> share(
    Phase6bTestReport report, {
    String? fileStem,
    Rect? sharePositionOrigin,
  }) async {
    final saved = await save(report, fileStem: fileStem);
    return SharePlus.instance.share(
      ShareParams(
        subject: 'ERA Phase 6B lifecycle report ${report.testSessionId}',
        text: report.copySummary,
        files: [
          XFile(saved.jsonPath, mimeType: 'application/json'),
          XFile(saved.markdownPath, mimeType: 'text/markdown'),
        ],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Future<void> _writePairAtomically({
    required File jsonFile,
    required String json,
    required File markdownFile,
    required String markdown,
  }) async {
    final nonce = DateTime.now().microsecondsSinceEpoch;
    final jsonTemporary = File('${jsonFile.path}.$nonce.tmp');
    final markdownTemporary = File('${markdownFile.path}.$nonce.tmp');
    final jsonBackup = File('${jsonFile.path}.$nonce.bak');
    final markdownBackup = File('${markdownFile.path}.$nonce.bak');
    var jsonHadOriginal = false;
    var markdownHadOriginal = false;
    var jsonBackedUp = false;
    var markdownBackedUp = false;
    var replacementCommitted = false;
    try {
      await jsonTemporary.writeAsString(json, flush: true);
      await markdownTemporary.writeAsString(markdown, flush: true);
      jsonHadOriginal = await jsonFile.exists();
      markdownHadOriginal = await markdownFile.exists();
      if (jsonHadOriginal) {
        await jsonFile.rename(jsonBackup.path);
        jsonBackedUp = true;
      }
      if (markdownHadOriginal) {
        await markdownFile.rename(markdownBackup.path);
        markdownBackedUp = true;
      }
      await jsonTemporary.rename(jsonFile.path);
      await pairWriteCheckpoint?.call('json-replaced');
      await markdownTemporary.rename(markdownFile.path);
      replacementCommitted = true;
    } catch (_) {
      if ((jsonBackedUp || !jsonHadOriginal) && await jsonFile.exists()) {
        await jsonFile.delete();
      }
      if ((markdownBackedUp || !markdownHadOriginal) &&
          await markdownFile.exists()) {
        await markdownFile.delete();
      }
      if (jsonBackedUp && await jsonBackup.exists()) {
        await jsonBackup.rename(jsonFile.path);
        jsonBackedUp = false;
      }
      if (markdownBackedUp && await markdownBackup.exists()) {
        await markdownBackup.rename(markdownFile.path);
        markdownBackedUp = false;
      }
      rethrow;
    } finally {
      await _deleteBestEffort(jsonTemporary);
      await _deleteBestEffort(markdownTemporary);
    }
    // The pair is already committed. Backup cleanup must never turn a
    // successful replacement into a rollback that can delete one side.
    if (replacementCommitted) {
      await _deleteBestEffort(jsonBackup);
      await _deleteBestEffort(markdownBackup);
    }
  }

  Future<void> _deleteBestEffort(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // A stale uniquely named backup is safer than deleting a committed pair.
    }
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
