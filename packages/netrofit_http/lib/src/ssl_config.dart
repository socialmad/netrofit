import 'dart:typed_data';

/// Configuration for SSL/TLS certificate pinning.
///
/// Example:
/// ```dart
/// final sslConfig = SslConfig(
///   // Certificate pinning
///   certificates: [certificateBytes],
///   // Or public key pinning
///   publicKeyHashes: ['sha256/AAAA...'],
/// );
/// ```
class SslConfig {
  /// PEM-encoded certificates to pin.
  final List<Uint8List>? certificates;

  /// SHA-256 public key hashes to pin (in base64 format with "sha256/" prefix).
  final List<String>? publicKeyHashes;

  /// Path to certificate asset file.
  final String? certificateAssetPath;

  /// Whether to allow self-signed certificates (for development only).
  final bool allowSelfSigned;

  const SslConfig({
    this.certificates,
    this.publicKeyHashes,
    this.certificateAssetPath,
    this.allowSelfSigned = false,
  });

  /// Whether SSL pinning is enabled.
  bool get isEnabled =>
      (certificates != null && certificates!.isNotEmpty) ||
      (publicKeyHashes != null && publicKeyHashes!.isNotEmpty) ||
      certificateAssetPath != null;
}
