import 'package:flutter/cupertino.dart';

import 'language_store.dart';
import 'strings.dart';
import 'thien_cung.dart';

const _secondaryText = Color(0xFFAEAEB2);
const _warningText = Color(0xFFFF9F0A);
const _divider = Color(0xFF2C2C2E);

/// Kết quả của một chuỗi tọa độ cố định, không nghe GPS.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.coordsText});

  /// Chuỗi tọa độ tại lúc bấm "Xem".
  final String coordsText;

  @override
  Widget build(BuildContext context) {
    final strings = LanguageScope.of(context).strings;
    final matches = matchPairs(splitPairs(coordsText));
    final conclusion = buildConclusion(matches);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoColors.white,
          previousPageTitle: strings.back,
        ),
        border: null,
        transitionBetweenRoutes: false,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Semantics(
              label: strings.spokenCoords(coordsText),
              excludeSemantics: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  coordsText,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (matches.isEmpty)
              Text(
                strings.noMatches,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _secondaryText, fontSize: 17),
              )
            else ...[
              for (final match in matches)
                _MatchRow(match: match, strings: strings),
              const SizedBox(height: 24),
              _ConclusionSection(conclusion: conclusion, strings: strings),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match, required this.strings});

  final PairMatch match;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final row = match.group;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _divider, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              match.pair,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 26,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.rowLabel(row),
                    style: TextStyle(
                      color: row.isWarning
                          ? _warningText
                          : CupertinoColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.meaning(row),
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConclusionSection extends StatelessWidget {
  const _ConclusionSection({required this.conclusion, required this.strings});

  final Conclusion conclusion;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.conclusionTitle,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          conclusion.isEmpty
              ? strings.noConclusion
              : strings.conclusionSentence(conclusion),
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 17,
            height: 1.35,
          ),
        ),
        if (conclusion.warnings.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            strings.warningSentence(conclusion),
            style: const TextStyle(
              color: _warningText,
              fontSize: 17,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
