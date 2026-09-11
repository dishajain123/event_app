import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/core/network/app_exception.dart';
import 'package:event_app/core/providers/core_providers.dart';
import 'package:event_app/core/storage/secure_token_storage.dart';
import 'package:event_app/features/auth/application/auth_state_provider.dart';
import 'package:event_app/features/auth/data/auth_api.dart';
import 'package:event_app/features/auth/data/auth_repository.dart';
import 'package:event_app/features/auth/presentation/screens/mobile_number_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class RecoveryRepository extends AuthRepository {
  RecoveryRepository() : super(AuthApi(Dio()), SecureTokenStorage());
  Completer<int>? pending;
  String? requestedEmail;
  List<String>? resetArguments;
  bool rejectCode = false;

  @override
  Future<int> requestPasswordReset(String email) async {
    requestedEmail = email;
    return pending == null ? 30 : await pending!.future;
  }

  @override
  Future<void> resetPassword(
      {required String email,
      required String code,
      required String password}) async {
    resetArguments = [email, code, password];
    if (rejectCode) throw const ValidationException('Invalid reset code');
  }
}

Future<void> openRecovery(
    WidgetTester tester, RecoveryRepository repository) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(ProviderScope(overrides: [
    authRepositoryProvider.overrideWithValue(repository),
    apiClientProvider.overrideWithValue(Dio()),
  ], child: const MaterialApp(home: MobileNumberScreen())));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Email'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Forgot password?'));
  await tester.tap(find.text('Forgot password?'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'reset validates input, retains invalid code for retry, and succeeds',
      (tester) async {
    final repository = RecoveryRepository();
    await openRecovery(tester, repository);
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(repository.requestedEmail, isNull);
    await tester.enterText(
        find.byKey(const ValueKey('reset-email')), 'person@example.com');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(repository.requestedEmail, 'person@example.com');
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('reset-code')), '123456');
    await tester.enterText(
        find.byKey(const ValueKey('reset-password')), 'new-password');
    repository.rejectCode = true;
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid reset code'), findsOneWidget);
    repository.rejectCode = false;
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(repository.resetArguments,
        ['person@example.com', '123456', 'new-password']);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dismiss during request safely ignores late completion',
      (tester) async {
    final repository = RecoveryRepository()..pending = Completer<int>();
    await openRecovery(tester, repository);
    await tester.enterText(
        find.byKey(const ValueKey('reset-email')), 'person@example.com');
    await tester.tap(find.text('Send code'));
    await tester.pump();
    expect(find.text('Please wait…'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    repository.pending!.complete(30);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel focused password reset safely, then reopen',
      (tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: MobileNumberScreen())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Forgot password?'));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find
            .descendant(
                of: find.byType(AlertDialog), matching: find.byType(TextField))
            .first,
        'person@example.com');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Forgot password?'));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Reset password'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
