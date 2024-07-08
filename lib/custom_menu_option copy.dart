import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double _kHandleSize = 22.0;

class CustomMenuOption {
  final String label;
  final VoidCallback onPressed;
  final String imagePath;

  CustomMenuOption({
    required this.label,
    required this.onPressed,
    required this.imagePath,
  });
}

class MyTextSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  MyTextSelectionControls({
    this.joinZeroWidthSpace = false,
    this.customMenuOptions = const [],
  });

  final bool joinZeroWidthSpace;
  final List<CustomMenuOption> customMenuOptions;

  @override
  Size getHandleSize(double textLineHeight) =>
      const Size(_kHandleSize, _kHandleSize);

  @override
  Widget buildHandle(
      BuildContext context, TextSelectionHandleType type, double textLineHeight,
      [VoidCallback? onTap, double? startGlyphHeight, double? endGlyphHeight]) {
    final Widget handle = SizedBox(
      width: _kHandleSize,
      height: _kHandleSize,
      child: Image.asset(
        'assets/40.png',
      ),
    );

    switch (type) {
      case TextSelectionHandleType.left:
        return Transform.rotate(
          angle: math.pi / 4.0,
          child: handle,
        );
      case TextSelectionHandleType.right:
        return Transform.rotate(
          angle: -math.pi / 4.0,
          child: handle,
        );
      case TextSelectionHandleType.collapsed:
        return handle;
    }
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight,
      [double? startGlyphHeight, double? endGlyphHeight]) {
    switch (type) {
      case TextSelectionHandleType.left:
        return const Offset(_kHandleSize, 0);
      case TextSelectionHandleType.right:
        return Offset.zero;
      default:
        return const Offset(_kHandleSize / 2, -4);
    }
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset position,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return TextSelectionToolbar(
      anchorAbove: position,
      anchorBelow: position + const Offset(0, _kHandleSize),
      children: [
        TextSelectionToolbarTextButton(
          padding: const EdgeInsets.all(8.0),
          onPressed: () => delegate.cutSelection(SelectionChangedCause.toolbar),
          child: const Text('Cut'),
        ),
        TextSelectionToolbarTextButton(
          padding: const EdgeInsets.all(8.0),
          onPressed: () =>
              delegate.copySelection(SelectionChangedCause.toolbar),
          child: const Text('Copy'),
        ),
        TextSelectionToolbarTextButton(
          padding: const EdgeInsets.all(8.0),
          onPressed: () => delegate.pasteText(SelectionChangedCause.toolbar),
          child: const Text('Paste'),
        ),
        ...customMenuOptions.map((option) => CustomToolbarButton(
              onPressed: option.onPressed,
              label: option.label,
              imagePath: option.imagePath,
            )),
      ],
    );
  }
}

class CustomToolbarButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final String imagePath;

  const CustomToolbarButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return TextSelectionToolbarTextButton(
      padding: const EdgeInsets.all(8.0),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
