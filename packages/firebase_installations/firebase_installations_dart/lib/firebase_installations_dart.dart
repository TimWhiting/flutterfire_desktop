// Copyright 2021 Invertase Limited. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// Support for Firebase installations methods
/// with pure dart implementation.
///
library flutterfire_installations_dart;

import 'package:firebase_core_dart/firebase_core_dart.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

part 'src/exceptions.dart';

/// A [FirebaseInstallations] instance that provides an interface
/// for accessing the Firebase Installations API.
class FirebaseInstallations {
  /// Creates Firebase Installations
  @visibleForTesting
  FirebaseInstallations({required this.app});

  /// Gets the [FirebaseInstallations] instance for the given [app].
  factory FirebaseInstallations.instanceFor({
    FirebaseApp? app,
  }) {
    final _app = app ?? Firebase.app();
    if (_instances[_app] == null) {
      _instances[_app] = FirebaseInstallations(app: _app);
    }
    return _instances[_app]!;
  }

  static final Map<FirebaseApp, FirebaseInstallations> _instances = {};

  /// Gets the [FirebaseInstallations] instance for the default app
  // ignore: prefer_constructors_over_static_methods
  static FirebaseInstallations get instance {
    return FirebaseInstallations.instanceFor(app: Firebase.app());
  }

  /// The [FirebaseApp] instance used to create this [FirebaseInstallations] instance.
  final FirebaseApp app;

  /// Http client used for making requests
  http.Client _client = http.Client();

  /// Sets the Http Client used for making request for testing
  @visibleForTesting
  // ignore: use_setters_to_change_properties
  void setApiClient(http.Client client) {
    _client = client;
  }

  /// Deletes the Firebase Installation and all associated data.
  @override
  Future<void> delete() async {}

  /// Creates a Firebase Installation if there isn't one for the app and
  /// returns the Installation ID.
  @override
  Future<String> getId() {}

  /// Returns an Authentication Token for the current Firebase Installation.
  @override
  Future<String> getToken(bool forceRefresh) {}

  /// Sends a new event via a [Stream] whenever the Installation ID changes.
  @override
  Stream<String> get onIdChange {}
}
