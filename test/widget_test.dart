// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:linkup/linkup_app.dart';

void main() {
  testWidgets('LinkUp opens the Commons conversation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const LinkUpApp());

    expect(find.text('The Commons'), findsOneWidget);
    expect(find.text('Welcome to #general!'), findsOneWidget);
    expect(find.text('Maya Chen'), findsWidgets);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('sending a message adds it to the conversation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const LinkUpApp());

    await tester.enterText(
      find.byKey(const Key('messageComposer')),
      'Hello LinkUp',
    );
    await tester.tap(find.byKey(const Key('sendMessage')));
    await tester.pumpAndSettle();

    expect(find.text('Hello LinkUp'), findsOneWidget);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('small screens open a chat from the channel list', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const LinkUpApp());

    await tester.tap(find.byKey(const Key('room-design-studio')));
    await tester.pumpAndSettle();

    expect(find.text('design-studio'), findsOneWidget);
    expect(find.byTooltip('Back to channels'), findsOneWidget);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('selecting a member opens a direct conversation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const LinkUpApp());

    await tester.tap(find.byKey(const Key('member-Sam Rivera')));
    await tester.pumpAndSettle();

    expect(find.text('Your conversation with Sam Rivera'), findsOneWidget);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('emoji selection inserts into the composer', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const LinkUpApp());

    await tester.tap(find.byTooltip('Add emoji or GIF'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('✨'));
    await tester.pumpAndSettle();

    final composer = tester.widget<TextField>(
      find.byKey(const Key('messageComposer')),
    );
    expect(composer.controller!.text, '✨');
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('creating a server safely dismisses its dialog', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const LinkUpApp());

    await tester.tap(find.byTooltip('Add a server'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Test Space');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Test Space'), findsWidgets);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
