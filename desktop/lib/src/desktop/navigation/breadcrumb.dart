//import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../input/button.dart';
import '../theme/theme.dart';
import 'tab_scope.dart' show TabScope;

const double _kHeight = 32.0;
const EdgeInsets _khorizontalPadding = EdgeInsets.symmetric(horizontal: 16.0);

class _BreadcrumbItem {
  const _BreadcrumbItem(this.overlayEntry, this.itemBuilder);

  final OverlayEntry overlayEntry;
  final WidgetBuilder itemBuilder;
}

class BreadcrumbController extends ChangeNotifier {
  /// Creates a [BreadcrumbController] with a initial page.
  BreadcrumbController({
    required IndexedWidgetBuilder builder,
    required IndexedWidgetBuilder breadCrumbBuilder,
  }) {
    push(builder: builder, breadcrumbBuilder: breadCrumbBuilder);
  }

  bool _isDisposed = false;

  final List<_BreadcrumbItem> _items =
      List<_BreadcrumbItem>.empty(growable: true);

  int get index => _items.length - 1;

  /// Sets an index to navigate.
  set index(int value) {
    if (_items.length - 1 == value || value >= _items.length - 1) {
      return;
    }

    _items.removeRange(value + 1, _items.length);
    notifyListeners();
  }

  void push({
    required IndexedWidgetBuilder builder,
    required IndexedWidgetBuilder breadcrumbBuilder,
  }) {
    final int index = _items.length;

    _items.add(
      _BreadcrumbItem(
        OverlayEntry(builder: (context) => builder(context, index)),
        (context) => breadcrumbBuilder(context, index),
      ),
    );

    notifyListeners();
  }

  bool pop() {
    if (_items.length > 1) {
      _items.removeLast();
      notifyListeners();

      return true;
    }

    return false;
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
  }
}

/// Navigation using breadcrumbs.
class Breadcrumb extends StatefulWidget {
  /// Creates a [Breadcrumb].
  const Breadcrumb({
    Key? key,
    this.trailing,
    this.leading,
    required this.controller,
  }) : super(key: key);

  final BreadcrumbController controller;

  /// Widget placed at the end of the breadcrumb.
  final Widget? trailing;

  /// Widget placed at the beginning of the breadcrumb.
  final Widget? leading;

  @override
  _BreadcrumbState createState() => _BreadcrumbState();
}

class _BreadcrumbState extends State<Breadcrumb> {
  final ScrollController scrollController = ScrollController();

  BreadcrumbController get controller => widget.controller;

  late _BreadcrumbItem currentBreadcrumbItem;

  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

  Widget _createBarNavigation() {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final textTheme = themeData.textTheme;

    final items = List<Widget>.empty(growable: true);

    final foreground = textTheme.textLow;

    for (int i = 0; i < controller._items.length; i++) {
      final isLast = i == controller._items.length - 1;

      items.add(
        Align(
          alignment: Alignment.centerLeft,
          child: ButtonTheme.merge(
            data: ButtonThemeData(
              disabledColor: isLast ? textTheme.textPrimaryHigh : null,
            ),
            child: Builder(
              builder: (context) => Button(
                body: controller._items[i].itemBuilder(context),
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                bodyPadding: EdgeInsets.zero,
                active: controller.index == i,
                onPressed: isLast ? null : () => controller.index = i,
              ),
            ),
          ),
        ),
      );

      if (!isLast) {
        items.add(
          Icon(
            Icons.chevron_right,
            color: foreground,
            size: 20.0,
          ),
        );
      }
    }

    Widget result = Container(
      constraints: const BoxConstraints.tightFor(height: _kHeight),
      color: Theme.of(context).colorScheme.background[0],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (widget.leading != null) widget.leading!,
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              alignment: Alignment.centerLeft,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: items,
                  ),
                ),
              ),
            ),
          ),
          if (widget.trailing != null) widget.trailing!,
        ],
      ),
    );

    result = TabScope(
      child: result,
      axis: Axis.horizontal,
    );

    return result;
  }

  void _onCurrentIndexChanged() {
    if (currentBreadcrumbItem != controller._items[controller.index]) {
      currentBreadcrumbItem.overlayEntry.remove();
      currentBreadcrumbItem = controller._items[controller.index];
      overlayKey.currentState!.insert(currentBreadcrumbItem.overlayEntry);

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    currentBreadcrumbItem = controller._items[controller.index];

    widget.controller.addListener(_onCurrentIndexChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(Breadcrumb oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller._isDisposed == false) {
        oldWidget.controller.removeListener(_onCurrentIndexChanged);
      }
      widget.controller.addListener(_onCurrentIndexChanged);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget result = Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Builder(
          builder: (context) => _createBarNavigation(),
        ),
        Expanded(
          child: Overlay(
            key: overlayKey,
            initialEntries: [currentBreadcrumbItem.overlayEntry],
          ),
        ),
      ],
    );

    return result;
  }
}
