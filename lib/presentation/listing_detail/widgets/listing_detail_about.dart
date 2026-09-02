import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingDetailAbout extends StatelessWidget {
  const ListingDetailAbout({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final trimmed = description.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    final blocks = _parseHtmlBlocks(trimmed);
    if (blocks.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.currentTheme.bgSurfaceBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.currentTheme.strokeNeutralLight50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.localization.listing_detail_about,
            style: AppTextStyles.p2SemiBold.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < blocks.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _buildBlock(context, blocks[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildBlock(BuildContext context, _HtmlBlock block) {
    switch (block.type) {
      case _BlockType.heading3:
        return Text.rich(
          TextSpan(
            children: _parseInlineSpans(
              block.content,
              baseStyle: AppTextStyles.p3SemiBold.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
            ),
          ),
        );
      case _BlockType.paragraph:
        return Text.rich(
          TextSpan(
            children: _parseInlineSpans(
              block.content,
              baseStyle: AppTextStyles.p3Regular.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
            ),
          ),
        );
      case _BlockType.unorderedList:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < block.listItems.length; index++) ...[
              if (index > 0) const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: AppTextStyles.p3SemiBold.copyWith(
                      color: context.currentTheme.textBrandPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: _parseInlineSpans(
                          block.listItems[index],
                          baseStyle: AppTextStyles.p3Regular.copyWith(
                            color: context.currentTheme.textNeutralSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      case _BlockType.orderedList:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < block.listItems.length; index++) ...[
              if (index > 0) const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ',
                    style: AppTextStyles.p3SemiBold.copyWith(
                      color: context.currentTheme.textBrandPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: _parseInlineSpans(
                          block.listItems[index],
                          baseStyle: AppTextStyles.p3Regular.copyWith(
                            color: context.currentTheme.textNeutralSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
    }
  }

  static List<_HtmlBlock> _parseHtmlBlocks(String html) {
    final blocks = <_HtmlBlock>[];
    final blockRegex = RegExp(
      r'<(h3|p|ul|ol)>(.*?)</\1>',
      caseSensitive: false,
      dotAll: true,
    );
    final matches = blockRegex.allMatches(html);

    if (matches.isEmpty) {
      // Fallback: treat plain text or unstructured text as a paragraph
      final cleanText = html.replaceAll(RegExp(r'<[^>]+>'), '').trim();
      if (cleanText.isNotEmpty) {
        blocks.add(_HtmlBlock(_BlockType.paragraph, html));
      }
      return blocks;
    }

    for (final match in matches) {
      final tag = match.group(1)!.toLowerCase();
      final innerContent = match.group(2)!.trim();

      if (tag == 'h3') {
        if (innerContent.isNotEmpty) {
          blocks.add(_HtmlBlock(_BlockType.heading3, innerContent));
        }
      } else if (tag == 'p') {
        if (innerContent.isNotEmpty) {
          blocks.add(_HtmlBlock(_BlockType.paragraph, innerContent));
        }
      } else if (tag == 'ul' || tag == 'ol') {
        final itemRegex = RegExp(
          r'<li>(.*?)</li>',
          caseSensitive: false,
          dotAll: true,
        );
        final itemMatches = itemRegex.allMatches(innerContent);
        final items = <String>[];
        for (final itemMatch in itemMatches) {
          final itemText = itemMatch.group(1)!.trim();
          if (itemText.isNotEmpty) {
            items.add(itemText);
          }
        }
        if (items.isNotEmpty) {
          blocks.add(
            _HtmlBlock(
              tag == 'ul' ? _BlockType.unorderedList : _BlockType.orderedList,
              '',
              listItems: items,
            ),
          );
        }
      }
    }

    return blocks;
  }

  static List<InlineSpan> _parseInlineSpans(
    String content, {
    required TextStyle baseStyle,
  }) {
    final spans = <InlineSpan>[];
    final tagRegex = RegExp(
      r'<(/?)(strong|em|b|i|br)(/?)>',
      caseSensitive: false,
    );

    var currentIndex = 0;
    var isBold = false;
    var isItalic = false;

    for (final match in tagRegex.allMatches(content)) {
      if (match.start > currentIndex) {
        final textChunk = content.substring(currentIndex, match.start);
        final unescaped = _unescapeHtml(textChunk);
        if (unescaped.isNotEmpty) {
          spans.add(
            TextSpan(
              text: unescaped,
              style: _buildStyle(baseStyle, isBold: isBold, isItalic: isItalic),
            ),
          );
        }
      }

      final isClosing = match.group(1) == '/';
      final tag = match.group(2)!.toLowerCase();

      if (tag == 'br') {
        spans.add(const TextSpan(text: '\n'));
      } else if (tag == 'strong' || tag == 'b') {
        isBold = !isClosing;
      } else if (tag == 'em' || tag == 'i') {
        isItalic = !isClosing;
      }

      currentIndex = match.end;
    }

    if (currentIndex < content.length) {
      final trailingChunk = content.substring(currentIndex);
      final unescaped = _unescapeHtml(trailingChunk);
      if (unescaped.isNotEmpty) {
        spans.add(
          TextSpan(
            text: unescaped,
            style: _buildStyle(baseStyle, isBold: isBold, isItalic: isItalic),
          ),
        );
      }
    }

    return spans;
  }

  static TextStyle _buildStyle(
    TextStyle base, {
    required bool isBold,
    required bool isItalic,
  }) {
    var style = base;
    if (isBold) {
      style = style.copyWith(fontWeight: FontWeight.w600);
    }
    if (isItalic) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
    return style;
  }

  static String _unescapeHtml(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ');
  }
}

enum _BlockType { heading3, paragraph, unorderedList, orderedList }

class _HtmlBlock {
  const _HtmlBlock(this.type, this.content, {this.listItems = const []});

  final _BlockType type;
  final String content;
  final List<String> listItems;
}
