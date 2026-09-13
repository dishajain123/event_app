import 'package:event_app/features/event_categories/application/event_categories_providers.dart';
import 'package:event_app/features/event_categories/data/models/category_models.dart';
import 'package:event_app/features/events/application/events_providers.dart';
import 'package:event_app/features/events/data/models/app_event.dart';
import 'package:event_app/features/events/data/models/event_status.dart';
import 'package:event_app/features/sponsorships/application/sponsorship_providers.dart';
import 'package:event_app/features/sponsorships/presentation/screens/sponsorship_inquiry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AppEvent _event(String id, String name) => AppEvent(
      id: id,
      organizationId: null,
      organizerUserId: null,
      name: name,
      description: null,
      category: null,
      mainCategoryId: null,
      subCategoryId: null,
      mainCategory: null,
      subCategory: null,
      organizer: null,
      configuration: null,
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 2),
      status: EventStatus.registrationOpen,
    );

void main() {
  testWidgets(
      'events are not dumped as one long list — a category must be chosen first, then only that category\'s events render',
      (tester) async {
    final sportsEvents = [
      _event('e1', 'City Marathon'),
      _event('e2', 'Football Cup'),
    ];
    final musicEvents = [
      _event('e3', 'Battle of Bands'),
    ];

    // A tall surface so every section is laid out without needing to
    // scroll a lazily-built sliver list mid-test.
    await tester.binding.setSurfaceSize(const Size(400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        sponsorshipCategoriesProvider.overrideWith((ref) async => []),
        sponsorshipPackagesProvider.overrideWith((ref) async => []),
        mainCategoriesProvider.overrideWith((ref) async => [
              const MainCategory(
                id: 'sports',
                name: 'Sports',
                description: null,
                isActive: true,
                subCategories: [],
              ),
              const MainCategory(
                id: 'music',
                name: 'Music',
                description: null,
                isActive: true,
                subCategories: [],
              ),
            ]),
        eventsListProvider.overrideWith((ref, query) async {
          if (query.mainCategoryId == 'sports') return sportsEvents;
          if (query.mainCategoryId == 'music') return musicEvents;
          return [];
        }),
      ],
      child: const MaterialApp(home: SponsorshipInquiryScreen()),
    ));
    await tester.pumpAndSettle();

    // Before any category is chosen, no event names are rendered at all —
    // this is the fix for "a very long list of every event" previously
    // dumped unconditionally.
    expect(find.text('City Marathon'), findsNothing);
    expect(find.text('Football Cup'), findsNothing);
    expect(find.text('Battle of Bands'), findsNothing);

    await tester.tap(find.text('Sports'));
    await tester.pumpAndSettle();

    expect(find.text('City Marathon'), findsOneWidget);
    expect(find.text('Football Cup'), findsOneWidget);
    expect(find.text('Battle of Bands'), findsNothing);

    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();

    expect(find.text('City Marathon'), findsNothing);
    expect(find.text('Battle of Bands'), findsOneWidget);
  });
}
