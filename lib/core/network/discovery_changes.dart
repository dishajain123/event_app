import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

/// One cancellable SSE connection. A reconnect always triggers a fresh snapshot.
class DiscoveryChanges {
  final Dio dio;
  final void Function() onChange;
  CancelToken? _cancel;
  StreamSubscription<String>? _subscription;
  Timer? _retry;
  bool _closed = false;

  DiscoveryChanges(this.dio, this.onChange);

  Future<void> connect() async {
    if (_closed) return;
    final cancel = _cancel = CancelToken();
    try {
      final response = await dio.get<ResponseBody>('/discovery/changes',
          cancelToken: cancel,
          options: Options(
            responseType: ResponseType.stream,
            receiveTimeout: Duration.zero,
            headers: {'Accept': 'text/event-stream'},
          ));
      if (_closed) return;
      _subscription = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .timeout(const Duration(seconds: 45))
          .listen((line) {
        if (line == 'event: changed') onChange();
      },
              onError: (Object error) => _reconnect(),
              onDone: _reconnect,
              cancelOnError: true);
    } catch (_) {
      if (!cancel.isCancelled) _reconnect();
    }
  }

  void _reconnect() {
    if (_closed || _retry != null) return;
    _subscription?.cancel();
    _cancel?.cancel();
    _retry = Timer(const Duration(seconds: 1), () {
      _retry = null;
      connect();
    });
  }

  void close() {
    _closed = true;
    _retry?.cancel();
    _subscription?.cancel();
    _cancel?.cancel();
  }
}
