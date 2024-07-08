import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

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

class DynamicHyperText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextOverflow overflow;
  final int? maxLines;
  final bool selectionEnabled;
  final bool joinZeroWidthSpace;
  final TextOverflowWidget? overflowWidget;
  final List<CustomMenuOption>? customMenuItems;
  final bool allowSelectAll;

  const DynamicHyperText({
    super.key,
    required this.text,
    this.style,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.selectionEnabled = true,
    this.joinZeroWidthSpace = false,
    this.overflowWidget,
    this.customMenuItems,
    this.allowSelectAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return ExtendedText(
      text,
      style: style,
      overflow: overflow,
      maxLines: maxLines,
      joinZeroWidthSpace: joinZeroWidthSpace,
      overflowWidget: overflowWidget,
      specialTextSpanBuilder: MySpecialTextSpanBuilder(),
      onSpecialTextTap: _handleSpecialTextTap,
    );
    // return CommonSelectionArea(
    //   joinZeroWidthSpace: joinZeroWidthSpace,
    //   customMenuItems: customMenuItems,
    //   allowSelectAll: allowSelectAll,
    //   child: ExtendedText(
    //     text,
    //     style: style,
    //     overflow: overflow,
    //     maxLines: maxLines,
    //     joinZeroWidthSpace: joinZeroWidthSpace,
    //     overflowWidget: overflowWidget,
    //     specialTextSpanBuilder: MySpecialTextSpanBuilder(),
    //     onSpecialTextTap: _handleSpecialTextTap,
    //   ),
    // );
  }

  void _handleSpecialTextTap(dynamic parameter) {
    if (parameter.toString().startsWith('\$')) {
      launchUrl(Uri.parse('https://github.com/fluttercandies'));
    } else if (parameter.toString().startsWith('@')) {
      launchUrl(Uri.parse('mailto:${parameter.toString().substring(1)}'));
    } else if (parameter.toString().startsWith('http')) {
      launchUrl(Uri.parse(parameter.toString()));
    }
  }
}

class CommonSelectionArea extends StatelessWidget {
  const CommonSelectionArea({
    super.key,
    required this.child,
    this.joinZeroWidthSpace = false,
    this.customMenuItems,
    this.allowSelectAll = true,
  });

  final Widget child;
  final bool joinZeroWidthSpace;
  final List<CustomMenuOption>? customMenuItems;
  final bool allowSelectAll;

  @override
  Widget build(BuildContext context) {
    SelectedContent? selectedContent;
    return SelectionArea(
      selectionControls: MyTextSelectionControls(
        joinZeroWidthSpace: joinZeroWidthSpace,
        customMenuOptions: customMenuItems ?? [],
        allowSelectAll: allowSelectAll,
      ),
      child: child,
      contextMenuBuilder:
          (BuildContext context, SelectableRegionState selectableRegionState) {
        return AdaptiveTextSelectionToolbar.buttonItems(
          buttonItems: <ContextMenuButtonItem>[
            ContextMenuButtonItem(
              onPressed: () {
                launchUrl(Uri.parse(
                    'mailto:xxx@live.com?subject=extended_text_share&body=${selectedContent?.plainText}'));
                selectableRegionState.hideToolbar();
              },
              type: ContextMenuButtonType.custom,
              label: 'like',
            ),
            ...customMenuItems!.map((option) => ContextMenuButtonItem(
                  onPressed: () {
                    option.onPressed();
                    selectableRegionState.hideToolbar();
                  },
                  type: ContextMenuButtonType.custom,
                  label: option.label,
                )),
          ],
          anchors: selectableRegionState.contextMenuAnchors,
        );
        // return AdaptiveTextSelectionToolbar.selectableRegion(
        //   selectableRegionState: selectableRegionState,
        // );
      },
      onSelectionChanged: (SelectedContent? value) {
        print(value?.plainText);
        selectedContent = value;
      },
    );
  }
}

const double _kHandleSize = 22.0;
const double _kToolbarContentDistance = 8.0;
const double _kToolbarContentHeight = 48.0;

class MyTextSelectionControls extends TextSelectionControls {
  MyTextSelectionControls({
    this.joinZeroWidthSpace = false,
    this.customMenuOptions = const [],
    this.allowSelectAll = true,
  });

  final bool joinZeroWidthSpace;
  final List<CustomMenuOption> customMenuOptions;
  final bool allowSelectAll;

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
  bool canSelectAll(TextSelectionDelegate delegate) {
    return allowSelectAll && delegate.selectAllEnabled;
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    // Calculate the positioning of the toolbar
    final Offset midpoint = selectionMidpoint;

    final Offset anchorAbove = Offset(midpoint.dx, midpoint.dy);
    final Offset anchorBelow =
        Offset(midpoint.dx, midpoint.dy + _kToolbarContentDistance);

    //     final Offset anchorAbove = Offset(
    //   midpoint.dx,
    //   midpoint.dy - _kToolbarContentDistance - _kToolbarContentHeight,
    // );
    // final Offset anchorBelow = Offset(
    //   midpoint.dx,
    //   midpoint.dy + _kToolbarContentDistance,
    // );

    return TextSelectionToolbar(
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      // anchorAbove: selectionMidpoint,
      // anchorBelow: selectionMidpoint + const Offset(0, _kHandleSize),
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
        ...customMenuOptions.map(
          (option) => TextSelectionToolbarTextButton(
            padding: const EdgeInsets.all(8.0),
            onPressed: option.onPressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(option.imagePath, width: 18, height: 18),
                const SizedBox(width: 8),
                Text(option.label),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      int? index}) {
    if (flag == '') {
      return null;
    }

    if (isStart(flag, AtText.flag)) {
      return AtText(textStyle, onTap, start: index! - (AtText.flag.length - 1));
    } else if (isStart(flag, EmojiText.flag)) {
      return EmojiText(textStyle, start: index! - (EmojiText.flag.length - 1));
    } else if (isStart(flag, DollarText.flag)) {
      return DollarText(textStyle, onTap,
          start: index! - (DollarText.flag.length - 1));
    } else if (isStart(flag, HttpText.flag)) {
      return HttpText(textStyle, onTap,
          start: index! - (HttpText.flag.length - 1));
    } else if (isStart(flag, BackgroundText.flag)) {
      return BackgroundText(textStyle, onTap,
          start: index! - (BackgroundText.flag.length - 1));
    }

    return null;
  }
}

class AtText extends SpecialText {
  static const String flag = '@';
  final int start;

  AtText(TextStyle? textStyle, SpecialTextGestureTapCallback? onTap,
      {required this.start})
      : super(flag, ' ', textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    final text = getContent();
    return SpecialTextSpan(
      text: text,
      actualText: '$flag$text',
      start: start,
      style: textStyle?.copyWith(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () => onTap?.call('$flag$text'),
    );
  }
}

class EmojiText extends SpecialText {
  static const String flag = '[';
  final int start;

  EmojiText(TextStyle? textStyle, {required this.start})
      : super(flag, ']', textStyle);

  @override
  InlineSpan finishText() {
    final key = toString();
    if (EmojiUitl.instance.emojiMap.containsKey(key)) {
      return ImageSpan(
        AssetImage(EmojiUitl.instance.emojiMap[key]!),
        actualText: key,
        imageWidth: 20,
        imageHeight: 20,
        start: start,
        fit: BoxFit.fill,
        margin: const EdgeInsets.only(left: 2.0, right: 2.0),
      );
    }
    return TextSpan(text: toString(), style: textStyle);
  }
}

class DollarText extends SpecialText {
  static const String flag = '\$';
  final int start;

  DollarText(TextStyle? textStyle, SpecialTextGestureTapCallback? onTap,
      {required this.start})
      : super(flag, flag, textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    final text = getContent();
    return SpecialTextSpan(
      text: text,
      actualText: '$flag$text$flag',
      start: start,
      style: textStyle?.copyWith(color: Colors.orange),
      recognizer: TapGestureRecognizer()
        ..onTap = () => onTap?.call('$flag$text$flag'),
    );
  }
}

class HttpText extends SpecialText {
  static const String flag = 'http';
  final int start;

  HttpText(TextStyle? textStyle, SpecialTextGestureTapCallback? onTap,
      {required this.start})
      : super(flag, ' ', textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    final text = getContent();
    return SpecialTextSpan(
      text: text,
      actualText: text,
      start: start,
      style: textStyle?.copyWith(
          color: Colors.blue, decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()..onTap = () => onTap?.call(text),
    );
  }
}

class BackgroundText extends SpecialText {
  static const String flag = '{bg:';
  final int start;

  BackgroundText(TextStyle? textStyle, SpecialTextGestureTapCallback? onTap,
      {required this.start})
      : super(flag, '}', textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    final text = getContent();
    final parts = text.split(':');
    if (parts.length != 2) return TextSpan(text: toString(), style: textStyle);

    final color = _parseColor(parts[0]);
    final content = parts[1];

    return SpecialTextSpan(
      text: content,
      actualText: '$flag$text}',
      start: start,
      style: textStyle?.copyWith(backgroundColor: color),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString, radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.yellow; // Default color if parsing fails
    }
  }
}

class EmojiUitl {
  EmojiUitl._();
  static final EmojiUitl instance = EmojiUitl._();
  final Map<String, String> emojiMap = {
    '[love]': 'assets/love.png',
    '[sun_glasses]': 'assets/sun_glasses.png',
  };
}
