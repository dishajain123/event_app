import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:event_app/core/providers/core_providers.dart';
import 'package:event_app/core/providers/discovery_refresh_provider.dart';
import 'package:event_app/features/event_categories/application/event_categories_providers.dart';
import 'package:event_app/features/events/application/events_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('backend additions, edits and removals replace cached discovery',
      (tester) async {
    var revision = 0;
    final changes = StreamController<Uint8List>.broadcast();
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (options.path == '/discovery/changes') {
        handler.resolve(Response(
            requestOptions: options, data: ResponseBody(changes.stream, 200)));
        return;
      }
      final data = options.path == '/event-categories/main'
          ? [
              if (revision < 2)
                {
                  'id': 'category',
                  'name': 'Category $revision',
                  'is_active': true,
                  'sub_categories': [
                    if (revision == 1)
                      {
                        'id': 'new-subcategory',
                        'main_category_id': 'category',
                        'name': 'Added in console',
                        'is_active': true,
                      },
                  ],
                },
            ]
          : [
              if (revision < 2)
                {
                  'id': 'event',
                  'name': 'Event $revision',
                  'start_date': '2026-10-01T10:00:00Z',
                  'end_date': '2026-10-01T12:00:00Z',
                  'status': 'published',
                },
            ];
      handler.resolve(Response(requestOptions: options, data: data));
    }));
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(dio),
      discoveryConnectionProvider.overrideWithValue(dio),
    ]);
    container.listen(mainCategoriesProvider, (_, __) {});
    container.listen(eventsListProvider(noEventsFilter), (_, __) {});
    addTearDown(dio.close);

    await tester.pumpAndSettle();
    expect(container.read(mainCategoriesProvider).requireValue.single.name,
        'Category 0');
    expect(
        container
            .read(eventsListProvider(noEventsFilter))
            .requireValue
            .single
            .name,
        'Event 0');

    revision = 1;
    changes
        .add(Uint8List.fromList(utf8.encode('event: changed\ndata: {}\n\n')));
    await tester.pumpAndSettle();
    final category = container.read(mainCategoriesProvider).requireValue.single;
    expect(category.name, 'Category 1');
    expect(category.subCategories.single.name, 'Added in console');
    expect(
        container
            .read(eventsListProvider(noEventsFilter))
            .requireValue
            .single
            .name,
        'Event 1');

    revision = 2;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 30));
    expect(container.read(mainCategoriesProvider).requireValue, isNotEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(container.read(mainCategoriesProvider).requireValue, isEmpty);
    expect(container.read(eventsListProvider(noEventsFilter)).requireValue,
        isEmpty);
    container.dispose();
    await changes.close();
  });

  testWidgets('live connection is disposed when discovery has no listeners',
      (tester) async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.resolve(Response(
          requestOptions: options, data: ResponseBody.fromString('', 200)));
    }));
    final container = ProviderContainer(overrides: [
      discoveryConnectionProvider.overrideWithValue(dio),
    ]);
    final subscription = container.listen(discoveryRefreshProvider, (_, __) {});
    subscription.close();
    await tester.pump();
    await tester.pump(const Duration(seconds: 60));
    expect(container.exists(discoveryRefreshProvider), isFalse);
    container.dispose();
  });
}
