import 'package:event_app/features/event_categories/data/models/category_models.dart';
import 'package:event_app/shared/widgets/cards/piller_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MainCategory category(List<SubCategory> children, {String? description}) =>
    MainCategory(
        id: 'main',
        name: 'A very long main category title',
        description: description,
        isActive: true,
        subCategories: children);
SubCategory child(String name, {bool active = true}) => SubCategory(
    id: name,
    mainCategoryId: 'main',
    name: name,
    description: null,
    isActive: active);

void main() {
  test('preview sorts active names, limits to three and counts the rest', () {
    final item = category([
      child('Youth'),
      child('Sports'),
      child('Business'),
      child('Family'),
      child('Culture'),
      child('Hidden', active: false),
    ], description: 'Fallback');
    expect(item.homeSubtitle, 'Business · Culture · Family');
    expect(item.homeMoreCount, 2);
    expect(item.subCategories.first.name, 'Youth');
  });

  test('empty active taxonomy uses trimmed description or default', () {
    expect(
        category([child('Hidden', active: false)], description: '  Welcome  ')
            .homeSubtitle,
        'Welcome');
    expect(
        category([], description: '  ').homeSubtitle, 'Explore this category');
    expect(category([]).homeMoreCount, 0);
  });

  for (final scale in [1.0, 2.0, 3.0]) {
    testWidgets('long preview fits narrow card at text scale $scale',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Center(
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: SizedBox(
            width: 138,
            height: 88 + 21 * scale + 34 * scale,
            child: PillarCard(
              title: 'A very long main category title',
              subtitle: 'Business networking · Community celebrations · Sports',
              moreCount: 2,
              icon: Icons.groups,
              shadowTint: Colors.blue,
              gradient:
                  const LinearGradient(colors: [Colors.blue, Colors.purple]),
              onTap: () => tapped = true,
            ),
          ),
        ),
      ))));
      expect(tester.takeException(), isNull);
      expect(
          find.text('Business networking · Community celebrations · Sports +2 more'),
          findsOneWidget);
      await tester.tap(find.byType(PillarCard));
      expect(tapped, isTrue);
    });
  }
}
