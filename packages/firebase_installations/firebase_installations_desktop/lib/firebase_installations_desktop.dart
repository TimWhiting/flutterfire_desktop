// Copyright 2021 Invertase Limited. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

library firebase_installations_desktop;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_dart/firebase_core_dart.dart' as core_dart;
import 'package:firebase_installations_dart/firebase_installations_dart.dart'
    as installations_dart;
import 'package:firebase_installations_platform_interface/firebase_installations_platform_interface.dart';
import 'package:meta/meta.dart';

/// Desktop implementation of FirebaseInstallationsPlatform for managing FirebaseInstallations
class FirebaseInstallationsDesktop extends FirebaseInstallationsPlatform {
  /// Constructs a FirebaseInstallationsDesktop
  FirebaseInstallationsDesktop({
    required FirebaseApp app,
  })  : _app = core_dart.Firebase.app(app.name),
        super(app);

  FirebaseInstallationsDesktop._()
      : _app = null,
        super(null);

  /// Called by PluginRegistry to register this plugin as the implementation for Desktop
  static void registerWith() {
    FirebaseInstallationsPlatform.instance =
        FirebaseInstallationsDesktop.instance;
  }

  /// Stub initializer to allow creating an instance without
  /// registering delegates or listeners.
  ///
  // ignore: prefer_constructors_over_static_methods
  static FirebaseInstallationsDesktop get instance {
    return FirebaseInstallationsDesktop._();
  }

  final core_dart.FirebaseApp? _app;

  /// The dart Installations instance for this app
  @visibleForTesting
  late final installations_dart.FirebaseInstallations dartInstallations =
      installations_dart.FirebaseInstallations.instanceFor(
    app: _app,
  );

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance or region is required by the user.
  @override
  @protected
  FirebaseInstallationsPlatform delegateFor({required FirebaseApp app}) {
    return this;
  }

  /// Deletes the Firebase Installation and all associated data.
  @override
  Future<void> delete() {
    return dartInstallations.delete();
  }

  /// Creates a Firebase Installation if there isn't one for the app and
  /// returns the Installation ID.
  @override
  Future<String> getId() {
    return dartInstallations.getId();
  }

  /// Returns an Authentication Token for the current Firebase Installation.
  @override
  Future<String> getToken(bool forceRefresh) {
    return dartInstallations.getToken();
  }

  /// Sends a new event via a [Stream] whenever the Installation ID changes.
  @override
  Stream<String> get onIdChange {
    return dartInstallations.onIdChange();
  }
}
