import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

import 'package:era_wallet/phase6b/report_export_io.dart' as native;
import 'package:era_wallet/phase6b/report_export_web.dart' as web;
import 'package:era_wallet/phase6b/test_report.dart';

void main() {
  group('native report export', () {
    late Directory documentsDirectory;

    setUp(() async {
      documentsDirectory = await Directory.systemTemp.createTemp(
        'era-report-export-test-',
      );
    });

    tearDown(() async {
      if (await documentsDirectory.exists()) {
        await documentsDirectory.delete(recursive: true);
      }
    });

    test(
      'atomically saves JSON and Markdown in the documents directory',
      () async {
        final report = _report();
        final saved = await native.Phase6bReportExporter(
          documentsDirectory: () async => documentsDirectory,
        ).save(report);

        expect(saved.jsonPath, contains('ERA Wallet'));
        expect(saved.jsonPath, contains('Phase6B Reports'));
        expect(saved.jsonPath, contains('session-name-'));
        expect(
          await File(saved.jsonPath).readAsString(),
          report.exportPayload.json,
        );
        expect(
          await File(saved.markdownPath).readAsString(),
          report.exportPayload.markdown,
        );

        final reportDirectory = File(saved.jsonPath).parent;
        final temporaryFiles = await reportDirectory
            .list()
            .where(
              (entity) =>
                  entity.path.endsWith('.tmp') || entity.path.endsWith('.bak'),
            )
            .toList();
        expect(temporaryFiles, isEmpty);
      },
    );

    test(
      'sanitizes a deterministic stem and atomically replaces its files',
      () async {
        final exporter = native.Phase6bReportExporter(
          documentsDirectory: () async => documentsDirectory,
        );
        final first = await exporter.save(
          _report(postStateVerification: 'First observation'),
          fileStem: 'final/report:*',
        );
        final finalReport = _report(postStateVerification: 'Final observation');
        final second = await exporter.save(
          finalReport,
          fileStem: 'final/report:*',
        );

        expect(second.jsonPath, first.jsonPath);
        expect(second.markdownPath, first.markdownPath);
        expect(
          second.jsonPath,
          endsWith('${Platform.pathSeparator}final-report--.json'),
        );
        expect(
          await File(second.jsonPath).readAsString(),
          finalReport.exportPayload.json,
        );
        expect(
          await File(second.markdownPath).readAsString(),
          finalReport.exportPayload.markdown,
        );
        expect(await File(second.jsonPath).parent.list().length, 2);
      },
    );

    test('rejects an empty deterministic stem', () async {
      final exporter = native.Phase6bReportExporter(
        documentsDirectory: () async => documentsDirectory,
      );

      await expectLater(
        exporter.save(_report(), fileStem: '  '),
        throwsArgumentError,
      );
    });

    test(
      'restores the previous pair when replacement is interrupted',
      () async {
        final original = _report(postStateVerification: 'Original pair');
        final normal = native.Phase6bReportExporter(
          documentsDirectory: () async => documentsDirectory,
        );
        final saved = await normal.save(original, fileStem: 'rollback-report');
        final interrupted = native.Phase6bReportExporter(
          documentsDirectory: () async => documentsDirectory,
          pairWriteCheckpoint: (checkpoint) async {
            if (checkpoint == 'json-replaced') {
              throw const FileSystemException('fixture interruption');
            }
          },
        );

        await expectLater(
          interrupted.save(
            _report(postStateVerification: 'Must not replace original'),
            fileStem: 'rollback-report',
          ),
          throwsA(isA<FileSystemException>()),
        );
        expect(
          await File(saved.jsonPath).readAsString(),
          original.exportPayload.json,
        );
        expect(
          await File(saved.markdownPath).readAsString(),
          original.exportPayload.markdown,
        );
        final leftovers = await File(saved.jsonPath).parent
            .list()
            .where(
              (entity) =>
                  entity.path.endsWith('.tmp') || entity.path.endsWith('.bak'),
            )
            .toList();
        expect(leftovers, isEmpty);
      },
    );
  });

  group('web report export', () {
    test(
      'save explicitly reports that documents-directory storage is absent',
      () async {
        final exporter = web.Phase6bReportExporter();

        await expectLater(
          exporter.save(_report(), fileStem: 'final-report'),
          throwsA(
            isA<UnsupportedError>().having(
              (error) => error.message,
              'message',
              contains('not supported on web'),
            ),
          ),
        );
      },
    );

    test(
      'shares in-memory JSON and Markdown with download-safe names',
      () async {
        ShareParams? captured;
        final exporter = web.Phase6bReportExporter(
          share: (params) async {
            captured = params;
            return ShareResult.unavailable;
          },
        );
        final report = _report();

        await exporter.share(report, fileStem: 'deterministic-session-report');

        final params = captured!;
        expect(params.downloadFallbackEnabled, isTrue);
        expect(params.files, hasLength(2));
        expect(params.fileNameOverrides, hasLength(2));
        expect(params.fileNameOverrides![0], endsWith('.json'));
        expect(params.fileNameOverrides![1], endsWith('.md'));
        expect(params.fileNameOverrides, const [
          'deterministic-session-report.json',
          'deterministic-session-report.md',
        ]);
        expect(
          await params.files![0].readAsString(),
          report.exportPayload.json,
        );
        expect(
          await params.files![1].readAsString(),
          report.exportPayload.markdown,
        );
      },
    );
  });
}

Phase6bTestReport _report({
  String postStateVerification = 'No post-state expected',
}) {
  final startedAt = DateTime.utc(2026, 1, 2, 3, 4, 5);
  return Phase6bTestReport(
    walletAppVersion: '1.0.0+1',
    platform: 'test',
    endpoint: 'wss://example.invalid',
    genesisHash: '0xgenesis',
    runtimeSpecName: 'era',
    runtimeSpecVersion: 9,
    metadataFingerprint: 'sha256:test',
    testSessionId: 'session/name?',
    startedAt: startedAt,
    endedAt: startedAt.add(const Duration(minutes: 1)),
    participatingPublicAddresses: const ['era-public-address'],
    stages: const [],
    settlementResult: 'Not exercised',
    claimResult: 'Not exercised',
    postStateVerification: postStateVerification,
  );
}
