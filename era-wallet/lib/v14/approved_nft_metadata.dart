import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

const String kEraMetadataGatewayOrigin = 'https://metadata.eraprojects.org';

class ApprovedNftMetadataBinding {
  final int bytes;
  final String sha256;

  const ApprovedNftMetadataBinding({required this.bytes, required this.sha256});
}

const Map<String, ApprovedNftMetadataBinding> kApprovedNftMetadata = {
  'bafkreigneb4mdfbsrjf764whskvoo2pqsl5d2kjc6kyxsnyz5ikxcede6m':
      ApprovedNftMetadataBinding(
        bytes: 594,
        sha256:
            'cd2078c194328a4bff72c792aae769f092fa3d2922f2b1793719ea15711064f3',
      ),
  'bafkreifnjhrm572sicfwfx6wurmavad4vkab3tdfk4btxob43shh6qhiey':
      ApprovedNftMetadataBinding(
        bytes: 542,
        sha256:
            'ad49e2ceff52408b62dfd6a4580a807caa801dcc6557033bb83cdc8e7f40e826',
      ),
  'bafkreiby6jtpx5bdtosvclzjssu4rze37w7ehdlluilefjadhs737mwonu':
      ApprovedNftMetadataBinding(
        bytes: 558,
        sha256:
            '38f266fbf4239ba5512f2994a9c8e49bfdbe438d6ba21642a4033cbfbfb2ce6d',
      ),
  'bafkreihxzvde4g7s2p6c3k7rkdtbumeobgtfe6fgp2dca7cugc3mns6noq':
      ApprovedNftMetadataBinding(
        bytes: 558,
        sha256:
            'f7cd464e1bf2d3fc2dabf150e61a308e09a65278a67e86207c5430b6c6cbcd74',
      ),
};

typedef ApprovedMetadataFetcher =
    Future<Uint8List> Function(Uri uri, int expectedBytes);

class VerifiedNftMetadata {
  final String uri;
  final String cid;
  final Uri retrievedFrom;
  final String sha256;
  final Map<String, Object?> json;

  const VerifiedNftMetadata({
    required this.uri,
    required this.cid,
    required this.retrievedFrom,
    required this.sha256,
    required this.json,
  });
}

class ApprovedNftMetadataResolver {
  final Uri gatewayOrigin;
  final ApprovedMetadataFetcher fetcher;

  ApprovedNftMetadataResolver({
    Uri? gatewayOrigin,
    ApprovedMetadataFetcher? fetcher,
  }) : gatewayOrigin = _validateGateway(
         gatewayOrigin ?? Uri.parse(kEraMetadataGatewayOrigin),
       ),
       fetcher = fetcher ?? NativeMetadataHttpFetcher().fetch;

  Future<VerifiedNftMetadata> resolve(String uri) async {
    final cid = _approvedCid(uri);
    final binding = kApprovedNftMetadata[cid]!;
    final retrieval = gatewayOrigin.resolve('/ipfs/$cid');
    final bytes = await fetcher(retrieval, binding.bytes);
    if (bytes.length != binding.bytes) {
      throw StateError(
        'NFT metadata length does not match the approved record.',
      );
    }
    final digest = await Sha256().hash(bytes);
    final sha256 = digest.bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    if (sha256 != binding.sha256) {
      throw StateError('NFT metadata hash does not match the approved record.');
    }
    final decoded = jsonDecode(utf8.decode(bytes, allowMalformed: false));
    if (decoded is! Map) {
      throw const FormatException('NFT metadata must be a JSON object.');
    }
    return VerifiedNftMetadata(
      uri: uri,
      cid: cid,
      retrievedFrom: retrieval,
      sha256: sha256,
      json: decoded.cast<String, Object?>(),
    );
  }
}

class NativeMetadataHttpFetcher {
  final Duration timeout;

  const NativeMetadataHttpFetcher({this.timeout = const Duration(seconds: 8)});

  Future<Uint8List> fetch(Uri uri, int expectedBytes) async {
    if (uri.scheme != 'https' || uri.userInfo.isNotEmpty) {
      throw StateError('NFT metadata retrieval requires plain HTTPS.');
    }
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.getUrl(uri).timeout(timeout);
      request.followRedirects = false;
      request.maxRedirects = 0;
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(timeout);
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'NFT metadata request returned HTTP ${response.statusCode}.',
          uri: uri,
        );
      }
      if (response.contentLength >= 0 &&
          response.contentLength != expectedBytes) {
        throw StateError('NFT metadata Content-Length is not approved.');
      }
      final output = BytesBuilder(copy: false);
      var received = 0;
      await for (final chunk in response.timeout(timeout)) {
        received += chunk.length;
        if (received > expectedBytes) {
          throw StateError('NFT metadata exceeds the approved length.');
        }
        output.add(chunk);
      }
      return output.takeBytes();
    } finally {
      client.close(force: true);
    }
  }
}

Uri _validateGateway(Uri uri) {
  if (uri.scheme != 'https' ||
      uri.userInfo.isNotEmpty ||
      uri.path != '' && uri.path != '/' ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw ArgumentError('A plain HTTPS metadata gateway origin is required.');
  }
  return Uri(
    scheme: 'https',
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
  );
}

String _approvedCid(String uri) {
  final parsed = Uri.tryParse(uri);
  if (parsed == null ||
      parsed.scheme != 'ipfs' ||
      parsed.host.isEmpty ||
      parsed.path.isNotEmpty ||
      parsed.hasQuery ||
      parsed.hasFragment ||
      parsed.userInfo.isNotEmpty) {
    throw StateError('NFT metadata reference is not an approved IPFS URI.');
  }
  final cid = parsed.host;
  if (!kApprovedNftMetadata.containsKey(cid)) {
    throw StateError('NFT metadata CID is not in the approved V14 set.');
  }
  return cid;
}
