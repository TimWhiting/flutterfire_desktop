// Copyright 2021 Invertase Limited. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

/// Support for Firebase installations methods
/// with pure dart implementation.
///
library flutterfire_installations_dart;

import 'dart:async';

import 'package:firebase_core_dart/firebase_core_dart.dart';
import 'package:firebaseapis/firebaseinstallations/v1.dart' as api;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:storagebox/storagebox.dart';

part 'src/exceptions.dart';
part 'src/storage.dart';

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
  api.FirebaseinstallationsApi _client =
      api.FirebaseinstallationsApi(http.Client());

  /// Sets the Http Client used for making request for testing
  @visibleForTesting
  // ignore: use_setters_to_change_properties
  void setApiClient(http.Client client) {
    _client = api.FirebaseinstallationsApi(client);
  }

  String? _installationId;

  /// Deletes the Firebase Installation and all associated data.
  Future<void> delete() async {
    await _client.projects.installations.delete(
      'projects/${app.options.projectId}/installations/$_installationId',
    );
  }

  /// Creates a Firebase Installation if there isn't one for the app and
  /// returns the Installation ID.
  Future<String> getId() async {
    if (_installationId == null) {
      final result = await _client.projects.installations.create(
        api.GoogleFirebaseInstallationsV1Installation(
          appId: app.options.appId,
          fid: 'fid',
          sdkVersion: 'FIS_v2',
        ),
        'projects/${app.options.projectId}',
      );
      _installationId = result.fid;
    }
    if (_installationId != null) {
      _idStream.add(_installationId!);
    }
    return _installationId!;
  }

  /// Returns an Authentication Token for the current Firebase Installation.
  Future<String> getToken(bool forceRefresh) async {
    final result = await _client.projects.installations.authTokens.generate(
      api.GoogleFirebaseInstallationsV1GenerateAuthTokenRequest(),
      _installationId!,
    );

    return result.token!;
  }

  final _idStream = StreamController<String>.broadcast();

  /// Sends a new event via a [Stream] whenever the Installation ID changes.
  Stream<String> get onIdChange {
    final s = _idStream.stream;
    if (_installationId != null) {
      _idStream.add(_installationId!);
    }
    return s;
  }
}
