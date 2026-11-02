/// Lazily mounts tabs and retains their scroll, search and layout state.
library;

import 'package:flutter/material.dart';

class RetainedTabView extends StatefulWidget {
  const RetainedTabView({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<RetainedTabView> createState() => _RetainedTabViewState();
}

class _RetainedTabViewState extends State<RetainedTabView> {
  final _visited = <int>{};

  @override
  Widget build(BuildContext context) {
    _visited.add(widget.index);
    return IndexedStack(
      index: widget.index,
      children: List.generate(
        widget.children.length,
        (index) => _visited.contains(index)
            ? TickerMode(
                enabled: index == widget.index,
                child: widget.children[index],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
