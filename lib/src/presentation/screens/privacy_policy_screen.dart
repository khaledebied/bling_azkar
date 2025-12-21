import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../utils/direction_icons.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.privacyPolicy),
          leading: IconButton(
            icon: Icon(DirectionIcons.backArrow(context)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: context.textPrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _MarkdownRenderer(content: l10n.privacyPolicyContent),
        ),
      ),
    );
  }
}

class _MarkdownRenderer extends StatelessWidget {
  final String content;

  const _MarkdownRenderer({required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 16));
        continue;
      }

      if (line.startsWith('# ')) {
        widgets.add(
          Text(
            line.substring(2),
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (line.startsWith('**') && line.contains('**')) {
        // Simple bold parser just for the start
        // Handling "**Title:** Description" format specifically
        final parts = line.split('**');
        if (parts.length >= 3) {
          widgets.add(
            RichText(
              text: TextSpan(
                style: AppTheme.bodyMedium.copyWith(
                  color: context.textPrimary,
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: parts[1],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: parts.sublist(2).join('**')),
                ],
              ),
            ),
          );
        } else {
           widgets.add(
            Text(
              line.replaceAll('**', ''),
              style: AppTheme.bodyMedium.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
            ),
          );
        }
      } else if (line.startsWith('* ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _parseRefinedText(context, line.substring(2)),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          _parseRefinedText(context, line),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
  
  Widget _parseRefinedText(BuildContext context, String text) {
    // Handle inline bold: "Some **bold** text"
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    
    int start = 0;
    for (final Match match in exp.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      start = match.end;
    }
    
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    
    if (spans.isEmpty) {
      return Text(
        text,
        style: AppTheme.bodyMedium.copyWith(
          color: context.textPrimary,
          height: 1.6,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: AppTheme.bodyMedium.copyWith(
          color: context.textPrimary,
          height: 1.6,
        ),
        children: spans,
      ),
    );
  }
}
