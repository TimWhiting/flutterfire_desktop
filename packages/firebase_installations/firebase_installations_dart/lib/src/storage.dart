// ignore_for_file: public_member_api_docs, library_private_types_in_public_api, unused_element

part of '../firebase_installations_dart.dart';

class FirebaseInstallationsStorage {
  final _storageBox = StorageBox('firebase-installations-store');

  _InstallationEntry? get(FirebaseApp app) {
    return _storageBox[app.key] == null
        ? null
        : _InstallationEntry.fromJson(_storageBox[app.key]! as Map);
  }

  void set(FirebaseApp app, _InstallationEntry value) {
    final old = get(app);

    _storageBox[app.key] = value.toJson();
    if (old == null || old.fid != value.fid) {
      FirebaseInstallations.instanceFor(app: app)._idStream.add(value.fid);
    }
  }

  void remove(FirebaseApp app) {
    _storageBox.remove(app.key);
  }

  void update(
    FirebaseApp app,
    _InstallationEntry? Function(_InstallationEntry?) updateFn,
  ) {
    final old = get(app);
    final newValue = updateFn(old);
    if (newValue == null) {
      _storageBox.remove(app.key);
    } else {
      _storageBox[app.key] = newValue;
    }
    if (newValue != null && (old == null || old.fid != newValue.fid)) {
      FirebaseInstallations.instanceFor(app: app)._idStream.add(newValue.fid);
    }
  }
}

extension on FirebaseApp {
  String get key => '$name!${options.appId}';
}

class _InstallationEntry {
  _InstallationEntry({
    required this.registrationStatus,
    required this.fid,
    this.registrationTime,
    this.refreshToken,
    this.authToken,
  });
  factory _InstallationEntry.fromJson(Map<dynamic, dynamic> json) {
    return _InstallationEntry(
      registrationStatus:
          RequestStatus.values.byName(json['registrationStatus']! as String),
      fid: json['fid'] as String,
      registrationTime: json['registrationTime'] == null
          ? null
          : DateTime.parse(json['registrationTime'] as String),
      refreshToken: json['refreshToken'] as String?,
      authToken: json['authToken'] == null
          ? null
          : _AuthToken.fromJson(json['authToken'] as Map<String, Object?>),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'registrationStatus': registrationStatus.name,
      'fid': fid,
      'registrationTime': registrationTime?.toIso8601String(),
      'refreshToken': refreshToken,
      'authToken': authToken?.toJson(),
    };
  }

  /// Status of the Firebase Installation registration on the server. */
  final RequestStatus registrationStatus;

  /// Firebase Installation ID */
  final String fid;

  /// Timestamp that shows the time when the current createInstallation
  /// request was initiated.
  /// Used for figuring out how long the registration status has been PENDING.
  final DateTime? registrationTime;

  /// Refresh Token returned from the server.
  /// Used for authenticating generateAuthToken requests.
  final String? refreshToken;

  /// Firebase Installation Authentication Token. */
  final _AuthToken? authToken;
}

class _AuthToken {
  _AuthToken({
    this.token,
    this.creationTime,
    this.expiresIn,
    required this.requestStatus,
    this.requestTime,
  });
  factory _AuthToken.fromJson(Map<String, Object?> json) {
    return _AuthToken(
      token: json['token'] as String?,
      creationTime: json['creationTime'] != null
          ? DateTime.parse(json['creationTime']! as String)
          : null,
      expiresIn: json['expiresIn'] != null
          ? Duration(seconds: json['expiresIn']! as int)
          : null,
      requestStatus:
          RequestStatus.values.byName(json['requestStatus']! as String),
      requestTime: json['requestTime'] != null
          ? DateTime.parse(json['requestTime']! as String)
          : null,
    );
  }
  _AuthToken.completed({
    required this.token,
    required this.creationTime,
    required this.expiresIn,
  })  : requestStatus = RequestStatus.completed,
        requestTime = null;
  _AuthToken.inProgress()
      : requestStatus = RequestStatus.inProgress,
        requestTime = DateTime.now(),
        token = null,
        creationTime = null,
        expiresIn = null;
  _AuthToken.notStarted()
      : requestStatus = RequestStatus.notStarted,
        requestTime = null,
        token = null,
        creationTime = null,
        expiresIn = null;

  final RequestStatus requestStatus;

  /// Unix timestamp when the current generateAuthRequest was initiated.
  /// Used for figuring out how long the request status has been IN_PROGRESS.
  final DateTime? requestTime;

  /// Firebase Installations Authentication Token.
  /// Only exists if requestStatus is COMPLETED.
  final String? token;

  /// Unix timestamp when Authentication Token was created.
  /// Only exists if requestStatus is COMPLETED.
  final DateTime? creationTime;

  /// Authentication Token time to live duration in milliseconds.
  /// Only exists if requestStatus is COMPLETED.
  final Duration? expiresIn;

  Map<String, Object?> toJson() {
    return {
      'requestTime': requestTime?.toIso8601String(),
      'requestStatus': requestStatus.name,
      'token': token,
      'creationTime': creationTime?.toIso8601String(),
      'expiresIn': expiresIn?.inSeconds,
    };
  }
}

enum RequestStatus {
  notStarted('NOT_STARTED'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED');

  const RequestStatus(this.text);
  final String text;
}
