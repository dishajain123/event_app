import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/core/network/auth_interceptor.dart';
import 'package:event_app/core/storage/secure_token_storage.dart';
import 'package:event_app/core/providers/core_providers.dart';
import 'package:event_app/core/providers/discovery_refresh_provider.dart';
import 'package:event_app/features/staff_mode/accounts/staff_accounts_screen.dart';

class Tokens extends SecureTokenStorage {
  bool cleared = false;
  @override
  Future<String?> getAccessToken() async => 'old-token';
  @override
  Future<void> clear() async {
    cleared = true;
  }
}

class RecordingErrorHandler extends ErrorInterceptorHandler {
  DioException? forwarded;
  @override
  void next(DioException error) {
    forwarded = error;
  }
}

class IdleDiscovery extends DiscoveryRefresh {
  @override
  int build() => 0;
}

void main() {
  test('disabled account ends an issued session without refreshing tokens',
      () async {
    final tokens = Tokens();
    var expired = false;
    var refreshes = 0;
    final interceptor = AuthInterceptor(
        tokenStorage: tokens,
        refreshToken: () async {
          refreshes++;
          return 'new-token';
        },
        onSessionExpired: () {
          expired = true;
        });
    final options = RequestOptions(path: '/users/me');
    final error = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: 401, data: {
          'error_code': 'account_disabled',
          'message': 'Account disabled'
        }));
    final handler = RecordingErrorHandler();
    await interceptor.onError(error, handler);
    expect(handler.forwarded, same(error));
    expect(tokens.cleared, isTrue);
    expect(expired, isTrue);
    expect(refreshes, 0);
  });

  testWidgets(
      'volunteer disable requires confirmation and supports reactivation',
      (tester) async {
    var active = true;
    var writes = 0;
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (options.method == 'PATCH') {
        writes++;
        active = options.data['status'] == 'ACTIVE';
        handler.resolve(
            Response(requestOptions: options, data: {'is_active': active}));
      } else {
        handler.resolve(Response(requestOptions: options, data: [
          {
            'id': 'volunteer',
            'name': 'Tara',
            'is_active': active,
            'can_manage_status': true
          },
          {
            'id': 'manager',
            'name': 'Self',
            'is_active': true,
            'can_manage_status': false
          },
        ]));
      }
    }));
    await tester.pumpWidget(ProviderScope(overrides: [
      apiClientProvider.overrideWithValue(dio),
      discoveryRefreshProvider.overrideWith(IdleDiscovery.new),
    ], child: const MaterialApp(home: StaffAccountsScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Self'), findsNothing);
    await tester.tap(find.text('Disable'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(writes, 0);
    await tester.tap(find.text('Disable'));
    await tester.pumpAndSettle();
    // Two "Disable" texts are now on screen: the card's own action button
    // (behind the sheet) and the confirm sheet's confirm button on top of
    // it — the sheet's is the one added last.
    await tester.tap(find.text('Disable').last);
    await tester.pumpAndSettle();
    expect(writes, 1);
    expect(active, isFalse);
    await tester.tap(find.text('Reactivate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reactivate').last);
    await tester.pumpAndSettle();
    expect(writes, 2);
    expect(active, isTrue);
    dio.close();
  });
}
