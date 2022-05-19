// Copyright 2022 Invertase Limited. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.
// ignore_for_file: public_member_api_docs, library_private_types_in_public_api

part of '../../firebase_remote_config_dart.dart';

@visibleForTesting
class RemoteConfigApiClient {
  RemoteConfigApiClient(
    this.projectId,
    this.namespace,
    this.apiKey,
    this.appId,
    this.storage,
    this.storageCache,
  );
  final remoteConfigClient = api.FirebaseRemoteConfigApi(Client());

  final _RemoteConfigStorage storage;
  final _RemoteConfigStorageCache storageCache;
  final String projectId;
  final String appId;
  final String namespace;
  final String apiKey;

  bool isCachedDataFresh(
    Duration cacheMaxAge,
    DateTime? lastSuccessfulFetchTimestamp,
  ) {
    if (lastSuccessfulFetchTimestamp == null) {
      return false;
    }

    final cacheAgeMillis = DateTime.now().millisecondsSinceEpoch -
        lastSuccessfulFetchTimestamp.millisecondsSinceEpoch;
    return cacheAgeMillis <= cacheMaxAge.inMilliseconds;
  }

  Future<Map> fetch({
    String? eTag,
    required Duration cacheMaxAge,
  }) async {
    final lastSuccessfulFetchTimestamp = storage.lastFetchTime;
    final lastSuccessfulFetchResponse =
        storage.getLastSuccessfulFetchResponse();

    if (lastSuccessfulFetchResponse != null &&
        isCachedDataFresh(cacheMaxAge, lastSuccessfulFetchTimestamp)) {
      return lastSuccessfulFetchResponse;
    }

    print('Calling api');
    final response = await remoteConfigClient.projects.namespaces.fetch(
      api.FetchRemoteConfigRequest(
        appId: appId,
        appInstanceId: '1', // TODO: get from installations
        sdkVersion: '0.1.0', // TODO: Sync with pubspec
      ),
      projectId,
      'firebase',
    );
    // print('Calling api');
    // final response = await remoteConfigClient.projects.namespaces
    //     .getRemoteConfig('projects/$projectId');

    storageCache.setLastFetchTime(DateTime.now());
    print('Got ${response.entries}');

    storage.setLastSuccessfulFetchResponse({});
    return {};
  }
}
