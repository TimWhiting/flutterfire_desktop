// Copyright 2021 Invertase Limited. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

part of '../firebase_installations_dart.dart';

/// Generic exception related to Firebase Installations. Check the error code
/// and message for more details.
class FirebaseInstallationsException extends FirebaseException
    implements Exception {
  // ignore: public_member_api_docs
  @protected
  FirebaseInstallationsException({
    required String message,
    required String code,
    StackTrace? stackTrace,
    this.details,
  }) : super(
          plugin: 'firebase_Installations',
          message: message,
          code: code,
          stackTrace: stackTrace,
        );

  /// Additional data provided with the exception.
  final dynamic details;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! FirebaseInstallationsException) {
      return false;
    }
    return other.message == message &&
        other.code == code &&
        other.details == details;
  }

  @override
  int get hashCode => Object.hash(plugin, code, message, details);

  @override
  String toString() {
    var output = '[$plugin/$code] $message';
    if (details != null) {
      output += '\n$details';
    }
    if (stackTrace != null) {
      output += '\n\n${stackTrace.toString()}';
    }

    return output;
  }
}
