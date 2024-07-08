import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
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
    return CommonSelectionArea(
      joinZeroWidthSpace: joinZeroWidthSpace,
      customMenuItems: customMenuItems,
      allowSelectAll: allowSelectAll,
      child: ExtendedText(
        text,
        style: style,
        overflow: overflow,
        maxLines: maxLines,
        joinZeroWidthSpace: joinZeroWidthSpace,
        overflowWidget: overflowWidget,
        specialTextSpanBuilder: MySpecialTextSpanBuilder(),
        onSpecialTextTap: _handleSpecialTextTap,
      ),
    );
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
    return SelectionArea(
      selectionControls: MyTextSelectionControls(
        joinZeroWidthSpace: joinZeroWidthSpace,
        customMenuOptions: customMenuItems ?? [],
        allowSelectAll: allowSelectAll,
      ),
      contextMenuBuilder:
          (BuildContext context, SelectableRegionState selectableRegionState) {
        return _CustomContextMenu(
          selectableRegionState: selectableRegionState,
          joinZeroWidthSpace: joinZeroWidthSpace,
          customMenuItems: customMenuItems,
          allowSelectAll: allowSelectAll,
        );
      },
      child: child,
    );
  }
}

class _CustomContextMenu extends StatelessWidget {
  const _CustomContextMenu({
    super.key,
    required this.selectableRegionState,
    required this.joinZeroWidthSpace,
    this.customMenuItems,
    required this.allowSelectAll,
  });

  final SelectableRegionState selectableRegionState;
  final bool joinZeroWidthSpace;
  final List<CustomMenuOption>? customMenuItems;
  final bool allowSelectAll;

  @override
  Widget build(BuildContext context) {
    final RenderBox renderBox =
        selectableRegionState.context.findRenderObject() as RenderBox;
    final Offset topLeft = renderBox.localToGlobal(Offset.zero);
    final Offset bottomRight =
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero));

    return Positioned(
      top: topLeft.dy,
      left: topLeft.dx,
      child: SizedBox(
        width: bottomRight.dx - topLeft.dx,
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Copy'),
                onTap: () {
                  selectableRegionState
                      .copySelection(SelectionChangedCause.toolbar);
                  if (joinZeroWidthSpace) {
                    _removeZeroWidthSpace();
                  }
                  Navigator.of(context).pop();
                },
              ),
              if (allowSelectAll)
                ListTile(
                  title: const Text('Select All'),
                  onTap: () {
                    selectableRegionState
                        .selectAll(SelectionChangedCause.toolbar);
                    Navigator.of(context).pop();
                  },
                ),
              ...?customMenuItems?.map((item) => ListTile(
                    title: Text(item.label),
                    leading: Image.asset(item.imagePath, width: 24, height: 24),
                    onTap: () {
                      item.onPressed();
                      Navigator.of(context).pop();
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _removeZeroWidthSpace() {
    Clipboard.getData('text/plain').then((ClipboardData? value) {
      if (value != null) {
        final String? plainText = value.text?.replaceAll(
          ExtendedTextLibraryUtils.zeroWidthSpace,
          '',
        );
        if (plainText != null) {
          Clipboard.setData(ClipboardData(text: plainText));
        }
      }
    });
  }
}

const double _kHandleSize = 22.0;

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
          onPressed: () {
            delegate.cutSelection(SelectionChangedCause.toolbar);
          },
          child: const Text('Cut'),
        ),
        TextSelectionToolbarTextButton(
          padding: const EdgeInsets.all(8.0),
          onPressed: () {
            delegate.copySelection(SelectionChangedCause.toolbar);
            if (joinZeroWidthSpace) {
              _removeZeroWidthSpace();
            }
          },
          child: const Text('Copy'),
        ),
        TextSelectionToolbarTextButton(
          padding: const EdgeInsets.all(8.0),
          onPressed: () {
            delegate.pasteText(SelectionChangedCause.toolbar);
          },
          child: const Text('Paste'),
        ),
        if (allowSelectAll && canSelectAll(delegate))
          TextSelectionToolbarTextButton(
            padding: const EdgeInsets.all(8.0),
            onPressed: () {
              delegate.selectAll(SelectionChangedCause.toolbar);
            },
            child: const Text('Select All'),
          ),
        ...customMenuOptions.map((option) => TextSelectionToolbarTextButton(
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
            )),
      ],
    );
  }

  void _removeZeroWidthSpace() {
    Clipboard.getData('text/plain').then((ClipboardData? value) {
      if (value != null) {
        final String? plainText = value.text?.replaceAll(
          ExtendedTextLibraryUtils.zeroWidthSpace,
          '',
        );
        if (plainText != null) {
          Clipboard.setData(ClipboardData(text: plainText));
        }
      }
    });
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
