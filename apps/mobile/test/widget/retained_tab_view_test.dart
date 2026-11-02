/// Tab switching must neither mount unseen screens nor discard visited state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/retained_tab_view.dart';

class _Tab extends StatefulWidget {
  const _Tab(this.onMount);
  final VoidCallback onMount;
  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  int count = 0;
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => count++),
    child: Text('Count $count'),
  );
}

void main() {
  testWidgets('tabs mount once, lazily, and preserve their state', (
    tester,
  ) async {
    final mounts = [0, 0];
    final tabs = [_Tab(() => mounts[0]++), _Tab(() => mounts[1]++)];
    Future<void> show(int index) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RetainedTabView(index: index, children: tabs),
        ),
      ),
    );
    await show(0);
    expect(mounts, [1, 0]);
    await tester.tap(find.text('Count 0'));
    await tester.pump();
    await show(1);
    expect(mounts, [1, 1]);
    expect(find.text('Count 0'), findsOneWidget);
    await show(0);
    expect(mounts, [1, 1]);
    expect(find.text('Count 1'), findsOneWidget);
  });
}
