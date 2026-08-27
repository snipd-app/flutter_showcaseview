import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaseview/showcaseview.dart';

Widget _app({
  required GlobalKey showcaseKey,
  required VoidCallback onBackgroundButtonTap,
  bool allowBackgroundInteraction = false,
  double? maxTooltipWidth,
  String description = 'A description long enough to stretch the whole screen',
}) => MaterialApp(
      home: ShowCaseWidget(
        disableAnimation: true,
        builder: Builder(
          builder: (context) => Scaffold(
            body: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ElevatedButton(
                    onPressed: onBackgroundButtonTap,
                    child: const Text('behind'),
                  ),
                ),
                Center(
                  child: Showcase(
                    key: showcaseKey,
                    description: description,
                    autoScrollIntoView: false,
                    allowBackgroundInteraction: allowBackgroundInteraction,
                    maxTooltipWidth: maxTooltipWidth,
                    child: const SizedBox.square(dimension: 32),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

Future<void> _start(WidgetTester tester, GlobalKey key) async {
  ShowCaseWidget.of(tester.element(find.byType(Scaffold)))
      .startShowCase([key]);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the overlay swallows background taps by default', (
    tester,
  ) async {
    final key = GlobalKey();
    var tapped = 0;
    await tester.pumpWidget(
      _app(showcaseKey: key, onBackgroundButtonTap: () => tapped++),
    );
    await _start(tester, key);

    await tester.tap(find.text('behind'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(tapped, 0);
  });

  testWidgets('allowBackgroundInteraction lets taps through', (tester) async {
    final key = GlobalKey();
    var tapped = 0;
    await tester.pumpWidget(
      _app(
        showcaseKey: key,
        onBackgroundButtonTap: () => tapped++,
        allowBackgroundInteraction: true,
      ),
    );
    await _start(tester, key);

    await tester.tap(find.text('behind'));
    await tester.pumpAndSettle();

    expect(tapped, 1);
  });

  testWidgets('the showcase stays up after a background tap', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      _app(
        showcaseKey: key,
        onBackgroundButtonTap: () {},
        allowBackgroundInteraction: true,
      ),
    );
    await _start(tester, key);
    final description = find.text(
      'A description long enough to stretch the whole screen',
    );
    expect(description, findsOneWidget);

    await tester.tap(find.text('behind'));
    await tester.pumpAndSettle();

    expect(description, findsOneWidget);
  });

  testWidgets('maxTooltipWidth caps the tooltip', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      _app(
        showcaseKey: key,
        onBackgroundButtonTap: () {},
        maxTooltipWidth: 180,
      ),
    );
    await _start(tester, key);

    final tooltip = find.ancestor(
      of: find.text('A description long enough to stretch the whole screen'),
      matching: find.byType(Container),
    );
    expect(tester.getSize(tooltip.first).width, lessThanOrEqualTo(180));
  });

  testWidgets('without maxTooltipWidth the tooltip fills the width', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      _app(showcaseKey: key, onBackgroundButtonTap: () {}),
    );
    await _start(tester, key);

    final tooltip = find.ancestor(
      of: find.text('A description long enough to stretch the whole screen'),
      matching: find.byType(Container),
    );
    expect(tester.getSize(tooltip.first).width, greaterThan(180));
  });
}
