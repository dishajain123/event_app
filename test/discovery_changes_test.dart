import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:event_app/core/network/discovery_changes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('split SSE packets refresh immediately and disconnect reconnects',
      () async {
    final streams = <StreamController<Uint8List>>[];
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final stream = StreamController<Uint8List>();
      streams.add(stream);
      handler.resolve(Response(
          requestOptions: options, data: ResponseBody(stream.stream, 200)));
    }));
    var updates = 0;
    final connection = DiscoveryChanges(dio, () => updates++);
    connection.connect();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    streams.single.add(Uint8List.fromList(utf8.encode('event: cha')));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(updates, 0);
    streams.single.add(Uint8List.fromList(utf8.encode('nged\ndata: {}\n\n')));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(updates, 1);
    await streams.single.close();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(streams, hasLength(2));
    streams.last
        .add(Uint8List.fromList(utf8.encode('event: changed\ndata: {}\n\n')));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(updates, 2);
    connection.close();
    await streams.last.close();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    expect(streams, hasLength(2));
    dio.close();
  });
}
