// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vidThumbnailHash() => r'5dd0bb1d63ed31d5c133d5e666bd874f023da69c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [vidThumbnail].
@ProviderFor(vidThumbnail)
const vidThumbnailProvider = VidThumbnailFamily();

/// See also [vidThumbnail].
class VidThumbnailFamily extends Family<AsyncValue<String>> {
  /// See also [vidThumbnail].
  const VidThumbnailFamily();

  /// See also [vidThumbnail].
  VidThumbnailProvider call(
    String filename,
  ) {
    return VidThumbnailProvider(
      filename,
    );
  }

  @override
  VidThumbnailProvider getProviderOverride(
    covariant VidThumbnailProvider provider,
  ) {
    return call(
      provider.filename,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vidThumbnailProvider';
}

/// See also [vidThumbnail].
class VidThumbnailProvider extends FutureProvider<String> {
  /// See also [vidThumbnail].
  VidThumbnailProvider(
    String filename,
  ) : this._internal(
          (ref) => vidThumbnail(
            ref as VidThumbnailRef,
            filename,
          ),
          from: vidThumbnailProvider,
          name: r'vidThumbnailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vidThumbnailHash,
          dependencies: VidThumbnailFamily._dependencies,
          allTransitiveDependencies:
              VidThumbnailFamily._allTransitiveDependencies,
          filename: filename,
        );

  VidThumbnailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filename,
  }) : super.internal();

  final String filename;

  @override
  Override overrideWith(
    FutureOr<String> Function(VidThumbnailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VidThumbnailProvider._internal(
        (ref) => create(ref as VidThumbnailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filename: filename,
      ),
    );
  }

  @override
  FutureProviderElement<String> createElement() {
    return _VidThumbnailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VidThumbnailProvider && other.filename == filename;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filename.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VidThumbnailRef on FutureProviderRef<String> {
  /// The parameter `filename` of this provider.
  String get filename;
}

class _VidThumbnailProviderElement extends FutureProviderElement<String>
    with VidThumbnailRef {
  _VidThumbnailProviderElement(super.provider);

  @override
  String get filename => (origin as VidThumbnailProvider).filename;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
