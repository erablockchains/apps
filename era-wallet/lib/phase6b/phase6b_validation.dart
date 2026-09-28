import 'dart:convert';

import '../era_chain.dart' show kEraDecimals, kEraUnit;

class Phase6bValidationException implements Exception {
  final String field;
  final String message;

  const Phase6bValidationException(this.field, this.message);

  @override
  String toString() => '$field: $message';
}

class ModelRegistrationInput {
  static const int maxHashBytes = 128;
  static const int maxMetadataUriBytes = 256;

  final List<int> modelHash;
  final List<int> metadataUri;

  const ModelRegistrationInput({
    required this.modelHash,
    required this.metadataUri,
  });

  void validate() {
    _bounded('Model hash', modelHash, maxHashBytes);
    _bounded('Metadata reference', metadataUri, maxMetadataUriBytes);
    Phase6bPublicInputSafety.validateBytes(
      field: 'Metadata reference',
      value: metadataUri,
    );
  }

  Map<String, Object> preview() => {
    'model_hash': _hex(modelHash),
    'model_hash_bytes': modelHash.length,
    'metadata_uri': _safeText(metadataUri),
    'metadata_uri_bytes': metadataUri.length,
  };
}

class PredictionSubmissionInput {
  static const int maxCategoryCodeBytes = 96;
  static const int maxHashBytes = 128;
  static const int maxMetadataUriBytes = 256;
  static const int maxExpiryBlock = 0xffffffff;

  final BigInt modelId;
  final String modelStatus;
  final bool modelActive;
  final bool signerAuthorized;
  final bool requireModelApproval;
  final List<int> categoryCode;
  final List<int> predictionHash;
  final List<int> metadataUri;
  final int confidence;
  final int expiresAt;
  final int currentFinalizedBlock;

  const PredictionSubmissionInput({
    required this.modelId,
    required this.modelStatus,
    required this.modelActive,
    required this.signerAuthorized,
    this.requireModelApproval = true,
    required this.categoryCode,
    required this.predictionHash,
    required this.metadataUri,
    required this.confidence,
    required this.expiresAt,
    required this.currentFinalizedBlock,
  });

  void validate() {
    if (modelId.isNegative) {
      throw const Phase6bValidationException('Model', 'Invalid model ID.');
    }
    if (modelStatus == 'Suspended' || modelStatus == 'Rejected') {
      throw Phase6bValidationException(
        'Model',
        modelStatus == 'Suspended'
            ? 'The model is suspended.'
            : 'The model is rejected.',
      );
    }
    if (requireModelApproval && modelStatus != 'Approved') {
      throw const Phase6bValidationException(
        'Model',
        'The model must be approved on chain.',
      );
    }
    if (!modelActive) {
      throw const Phase6bValidationException(
        'Model',
        'The model is not active.',
      );
    }
    if (!signerAuthorized) {
      throw const Phase6bValidationException(
        'Signer',
        'The selected account is not the owner or chain-derived submitter.',
      );
    }
    _bounded('Category code', categoryCode, maxCategoryCodeBytes);
    _bounded('Prediction hash', predictionHash, maxHashBytes);
    _bounded('Metadata reference', metadataUri, maxMetadataUriBytes);
    Phase6bPublicInputSafety.validateBytes(
      field: 'Category code',
      value: categoryCode,
    );
    Phase6bPublicInputSafety.validateBytes(
      field: 'Metadata reference',
      value: metadataUri,
    );
    if (confidence < 0 || confidence > 100) {
      throw const Phase6bValidationException(
        'Confidence',
        'Use a whole number from 0 to 100.',
      );
    }
    if (expiresAt <= currentFinalizedBlock) {
      throw const Phase6bValidationException(
        'Expiry block',
        'Expiry must be after the latest finalized block.',
      );
    }
    if (expiresAt > maxExpiryBlock) {
      throw const Phase6bValidationException(
        'Expiry block',
        'Expiry exceeds the runtime u32 block-number limit.',
      );
    }
  }
}

abstract final class Phase6bPublicInputSafety {
  static const int maxEvidenceReferenceBytes = 256;

  static void validateEvidenceReference(List<int> value) {
    _bounded('Evidence reference', value, maxEvidenceReferenceBytes);
    validateBytes(field: 'Evidence reference', value: value);
  }

  static void validateBytes({required String field, required List<int> value}) {
    late final String text;
    try {
      text = utf8.decode(value, allowMalformed: false).trim();
    } on FormatException {
      return;
    }
    if (text.isEmpty) return;
    if (_sensitiveLabel.hasMatch(text) ||
        _credentialBearingUri.hasMatch(text)) {
      throw Phase6bValidationException(
        field,
        'Do not place credentials, recovery material, or sensitive labels in '
        'public on-chain data.',
      );
    }
    final words = text.split(RegExp(r'\s+'));
    if (_mnemonicWordCounts.contains(words.length) &&
        words.every((word) => RegExp(r'^[a-z]{2,12}$').hasMatch(word))) {
      throw Phase6bValidationException(
        field,
        'This resembles a recovery phrase and cannot be published on chain.',
      );
    }
    if (RegExp(r'^(0x)?[0-9a-fA-F]{64,128}$').hasMatch(text)) {
      throw Phase6bValidationException(
        field,
        'This resembles private key material and cannot be published on chain.',
      );
    }
  }

  static final RegExp _sensitiveLabel = RegExp(
    r'(^|[^a-z0-9])(mnemonic|seed([ _-]?phrase)?|recovery[ _-]?phrase|private[ _-]?key|secret[ _-]?key|pin([ _-]?code)?|passcode|password|passphrase|secure[ _-]?storage|biometric(s|[ _-]?(data|information))?|api[ _-]?key|access[ _-]?token|auth[ _-]?token|bearer[ _-]?token|refresh[ _-]?token|authorization([ _-]?header)?|client[ _-]?secret|credentials?)([^a-z0-9]|$)',
    caseSensitive: false,
  );

  static final RegExp _credentialBearingUri = RegExp(
    r'(^[a-z][a-z0-9+.-]*://[^/@\s]+@)|([?&](api[_-]?key|access[_-]?token|auth[_-]?token|token|client[_-]?secret)=)',
    caseSensitive: false,
  );

  static const Set<int> _mnemonicWordCounts = {12, 15, 18, 21, 24};
}

class Phase6bAmount {
  static BigInt parseStrict(String input) {
    final value = input.trim();
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      throw const Phase6bValidationException(
        'Amount',
        'Enter a positive ETKN amount using digits and an optional decimal.',
      );
    }
    final parts = value.split('.');
    final fraction = parts.length == 2 ? parts[1] : '';
    if (fraction.length > kEraDecimals) {
      throw const Phase6bValidationException(
        'Amount',
        'ETKN supports at most 18 decimal places; the value was not rounded.',
      );
    }
    final units =
        BigInt.parse(parts[0]) * kEraUnit +
        BigInt.parse(fraction.padRight(kEraDecimals, '0'));
    if (units <= BigInt.zero) {
      throw const Phase6bValidationException(
        'Amount',
        'Amount must be greater than zero.',
      );
    }
    return units;
  }

  static void validateStake({
    required BigInt amount,
    required BigInt minimumStake,
    required BigInt freeBalance,
    required BigInt estimatedFee,
    required BigInt existentialReserve,
  }) {
    if (amount <= BigInt.zero) {
      throw const Phase6bValidationException(
        'Amount',
        'Amount must be greater than zero.',
      );
    }
    if (amount < minimumStake) {
      throw Phase6bValidationException(
        'Amount',
        'Minimum on-chain stake is $minimumStake base units.',
      );
    }
    if (freeBalance.isNegative ||
        estimatedFee.isNegative ||
        existentialReserve.isNegative) {
      throw const Phase6bValidationException(
        'Balance',
        'Balance, fee, and reserve inputs must not be negative.',
      );
    }
    final spendable = freeBalance - estimatedFee - existentialReserve;
    if (spendable < amount) {
      throw const Phase6bValidationException(
        'Balance',
        'Insufficient spendable balance after fee and reserve.',
      );
    }
  }
}

class Phase6bPayoutPresentation {
  final BigInt userWinningStake;
  final BigInt totalWinningStake;
  final BigInt payoutPool;
  final BigInt? chainClaimableAmount;
  final bool alreadyClaimed;

  const Phase6bPayoutPresentation({
    required this.userWinningStake,
    required this.totalWinningStake,
    required this.payoutPool,
    required this.chainClaimableAmount,
    required this.alreadyClaimed,
  });

  BigInt? get nonAuthoritativeEstimate {
    if (totalWinningStake <= BigInt.zero || userWinningStake <= BigInt.zero) {
      return null;
    }
    return payoutPool * userWinningStake ~/ totalWinningStake;
  }

  BigInt? get displayedClaimable => chainClaimableAmount;

  String get qualification {
    if (alreadyClaimed) return 'Claimed';
    if (chainClaimableAmount != null) return 'Claimable (chain-derived)';
    if (nonAuthoritativeEstimate != null) return 'Estimate only';
    return 'Not claimable';
  }
}

void _bounded(String field, List<int> value, int maximum) {
  if (value.isEmpty) {
    throw Phase6bValidationException(field, 'This field is required.');
  }
  if (value.length > maximum) {
    throw Phase6bValidationException(
      field,
      'Maximum encoded length is $maximum bytes; received ${value.length}.',
    );
  }
  if (value.any((byte) => byte < 0 || byte > 255)) {
    throw Phase6bValidationException(field, 'Contains an invalid byte value.');
  }
}

String _hex(List<int> bytes) =>
    '0x${bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join()}';

String _safeText(List<int> bytes) {
  if (bytes.every((byte) => byte >= 32 && byte <= 126)) {
    return String.fromCharCodes(bytes);
  }
  return _hex(bytes);
}
