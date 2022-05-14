import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../component.dart';
import '../dialogs/context_menu.dart';
import '../dialogs/tooltip.dart';
import '../icons.dart';
import '../theme/theme.dart';

/// Button that shows a list of [ContextMenuItem] when pressed.
/// The current value defines the selected item.
class DropDownButton<T> extends StatefulWidget {
  ///
  const DropDownButton({
    Key? key,
    required this.itemBuilder,
    this.value,
    this.onSelected,
    this.onCanceled,
    this.tooltip,
    this.enabled = true,
  }) : super(key: key);

  /// The list of [ContextMenuItem] used for the context menu.
  final ContextMenuItemBuilder<T> itemBuilder;

  /// The current value in the context menu.
  final T? value;

  /// Called when the context menu selection changes.
  final ContextMenuItemSelected<T>? onSelected;

  /// Called when the user cancels the context menu selection.
  final ContextMenuCanceled? onCanceled;

  /// The button tooltip;
  final String? tooltip;

  /// If this button is enabled.
  final bool enabled;

  @override
  _DropDownButtonState<T> createState() => _DropDownButtonState<T>();
}

class _DropDownButtonState<T> extends State<DropDownButton<T>>
    with ComponentStateMixin, SingleTickerProviderStateMixin {
  Future<void> showButtonMenu() async {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Overlay.of(context, rootOverlay: true)!
        .context
        .findRenderObject()! as RenderBox;

    final Rect position = Rect.fromPoints(
      button.localToGlobal(
        Offset.zero,
        ancestor: overlay,
      ),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    );

    final List<ContextMenuEntry<T>> items = widget.itemBuilder(context);

    assert(items.isNotEmpty);

    setState(() => waiting = true);

    await showMenu<T>(
      context: context,
      items: items,
      initialValue: widget.value,
      position: position,
      width: button.size.width,
      settings: const RouteSettings(),
    ).then<void>((T? newValue) {
      if (!mounted) {
        return null;
      }

      if (newValue == null) {
        if (widget.onCanceled != null) {
          widget.onCanceled!();
        }
        return null;
      }

      if (widget.onSelected != null) {
        widget.onSelected!(newValue);
      }
    });

    setState(() => waiting = false);
  }

  void _handleHoverEntered() {
    if (!hovered && (pressed || !_globalPointerDown)) {
      _controller.reset();
      _controller.forward();
      setState(() => hovered = true);
    }
  }

  void _handleHoverExited() {
    if (hovered) {
      _controller.reset();
      _controller.forward();
      setState(() => hovered = false);
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (pressed) {
      _controller.forward(from: 0.5);
      setState(() => pressed = false);
    }
  }

  void _handleTapDown(TapDownDetails event) {
    if (!pressed) {
      _controller.forward(from: 0.5);
      setState(() => pressed = true);
    }
  }

  void _handleTapCancel() {
    if (pressed) {
      _controller.forward(from: 0.5);
      setState(() => pressed = false);
    }
  }

  bool _globalPointerDown = false;

  void _mouseRoute(PointerEvent event) => _globalPointerDown = event.down;

  late AnimationController _controller;

  ColorTween? _color;
  ColorTween? _backgroundColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _controller.forward();

    WidgetsBinding.instance.pointerRouter.addGlobalRoute(_mouseRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.pointerRouter.removeGlobalRoute(_mouseRoute);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _color = null;
    _backgroundColor = null;
  }

  @override
  Widget build(BuildContext context) {
    final DropDownButtonThemeData buttonThemeData =
        DropDownButtonTheme.of(context);
    final ContextMenuThemeData contextMenuThemeData =
        ContextMenuTheme.of(context);

    final enabled = widget.enabled;

    Widget bodyChild;
    Color? inactiveBackground;

    if (widget.value != null) {
      bodyChild = widget
          .itemBuilder(context)
          .firstWhere((value) => value.represents(widget.value!));
      inactiveBackground = buttonThemeData.inactiveColor;
    } else {
      bodyChild = Container();
    }

    final borderColor = enabled
        ? waiting
            ? buttonThemeData.waitingColor!
            : hovered
                ? buttonThemeData.hoverColor!
                : buttonThemeData.color!
        : buttonThemeData.disabledColor!;

    final foreground = enabled
        ? buttonThemeData.iconThemeData!.color!
        : buttonThemeData.disabledColor!;

    _color = ColorTween(begin: _color?.end ?? borderColor, end: borderColor);

    final Color? background = waiting
        ? Theme.of(context).colorScheme.background[0]
        : inactiveBackground;
    _backgroundColor =
        ColorTween(begin: _backgroundColor?.end ?? background, end: background);

    Widget result = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final borderColor =
            _color!.evaluate(AlwaysStoppedAnimation(_controller.value))!;
        final border = Border.all(
          color: borderColor,
          width: 1.0,
        );
        final background = _backgroundColor!
            .evaluate(AlwaysStoppedAnimation(_controller.value));

        return DefaultTextStyle(
          style: buttonThemeData.textStyle!.copyWith(
              color: !enabled ? buttonThemeData.disabledColor! : null),
          child: Container(
            constraints: BoxConstraints(
              minHeight: contextMenuThemeData.itemHeight!,
              minWidth: contextMenuThemeData.minMenuWidth!,
              maxHeight: contextMenuThemeData.itemHeight!,
              maxWidth: contextMenuThemeData.maxMenuWidth!,
            ),
            decoration: BoxDecoration(
              color: background,
              border: border,
            ),
            //constraints: constraints,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IgnorePointer(
                  ignoring: true,
                  child: bodyChild,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    waiting ? Icons.expand_less : Icons.expand_more,
                    size: 18.0,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (enabled) {
      result = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _handleHoverEntered(),
        onExit: (_) => _handleHoverExited(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: showButtonMenu,
          child: result,
        ),
      );
    }

    result = Semantics(
      button: true,
      child: result,
    );

    if (widget.tooltip != null) {
      result = Tooltip(
        message: widget.tooltip!, // TODO(as): ???
        child: result,
      );
    }

    return result;
  }
}
