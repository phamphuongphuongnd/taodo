import 'dart:ui' show PathMetric;

import 'package:flutter/cupertino.dart';

import 'language_store.dart';
import 'strings.dart';
import 'thien_cung.dart';
import 'thien_cung_data.dart';
import 'theme.dart';
import 'widgets.dart';

/// Kết quả của một chuỗi tọa độ cố định, không nghe GPS.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.coordsText,
    this.table = thienCungTable,
  });

  /// Chuỗi tọa độ tại lúc bấm "Xem".
  final String coordsText;

  /// Chỉ test đổi: dựng bảng có dòng chưa có dữ liệu.
  final List<ThienCungGroup> table;

  @override
  Widget build(BuildContext context) {
    final strings = LanguageScope.of(context).strings;
    final metrics = AppMetrics.of(context);
    final matches = matchPairs(splitPairs(coordsText), table: table);
    final conclusion = buildConclusion(matches);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.screen,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackLink(label: strings.back),
            Expanded(
              child: matches.isEmpty
                  ? _NoMatches(coordsText: coordsText, strings: strings)
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        metrics.pageMargin,
                        8,
                        metrics.pageMargin,
                        32,
                      ),
                      children: [
                        AppCard(
                          color: AppColors.card,
                          border: AppColors.cardBorder,
                          child: CoordsDisplay(
                            coordsText: coordsText,
                            fontSize: metrics.resultCoordsSize,
                            labelSize: 11,
                            labelGap: 4,
                            dividerGap: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ConclusionCard(
                          conclusion: conclusion,
                          strings: strings,
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: SectionLabel(strings.detailsTitle),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                strings.rowCount(matches.length),
                                style: appText(
                                  size: 13,
                                  weight: 400,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final (index, match) in matches.indexed)
                          _MatchRow(
                            match: match,
                            strings: strings,
                            isLast: index == matches.length - 1,
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

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.coordsText, required this.strings});

  final String coordsText;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    return LayoutBuilder(
      builder: (context, viewport) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewport.maxHeight),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.homeMargin,
              0,
              metrics.homeMargin,
              80,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CoordsDisplay(
                  coordsText: coordsText,
                  fontSize: metrics.resultCoordsSize,
                  centered: true,
                ),
                const SizedBox(height: 28),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: const Icon(
                    CupertinoIcons.search,
                    size: 28,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 28),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    strings.noMatches,
                    textAlign: TextAlign.center,
                    style: appText(
                      size: 18,
                      weight: 600,
                      color: AppColors.pillText,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConclusionCard extends StatelessWidget {
  const _ConclusionCard({required this.conclusion, required this.strings});

  final Conclusion conclusion;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.conclusionSurface,
      border: AppColors.accentBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.sparkles,
                size: 16,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SectionLabel(
                  strings.conclusionTitle,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            conclusion.isEmpty
                ? strings.noConclusion
                : strings.conclusionSentence(conclusion),
            style: appText(
              size: AppMetrics.of(context).conclusionSize,
              weight: 700,
              letterSpacing: -0.2,
              height: 1.4,
            ),
          ),
          if (conclusion.warnings.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                border: Border.all(color: AppColors.warningBoxBorder),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 20,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.warningSentence(conclusion),
                      style: appText(
                        size: 15,
                        weight: 600,
                        color: AppColors.warning,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({
    required this.match,
    required this.strings,
    required this.isLast,
  });

  final PairMatch match;
  final AppStrings strings;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final row = match.group;
    final hasData = row.hasMeaning;
    final titleColor = row.isWarning
        ? AppColors.warning
        : hasData
        ? AppColors.text
        : AppColors.label;
    final group = strings.groupName(row);
    const line = BorderSide(color: AppColors.cardBorder);

    return MergeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: line, bottom: isLast ? line : BorderSide.none),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PairBox(
                pair: match.pair,
                isWarning: row.isWarning,
                hasData: hasData,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (row.isWarning) ...[
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_triangle_fill,
                            size: 13,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              strings.warningBadge,
                              style: appText(
                                size: 11,
                                weight: 800,
                                color: AppColors.warning,
                                letterSpacing: 1.54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text.rich(
                      TextSpan(
                        text: strings.palaceName(row),
                        style: appText(
                          size: 17,
                          weight: 700,
                          color: titleColor,
                          height: 1.3,
                        ),
                        children: [
                          if (group != null)
                            TextSpan(
                              text: ' ($group)',
                              style: appText(
                                size: 17,
                                weight: 500,
                                color: row.isWarning
                                    ? AppColors.warning
                                    : AppColors.label,
                                height: 1.3,
                              ),
                            ),
                          if (match.times > 1)
                            TextSpan(
                              text: '  ×${match.times}',
                              semanticsLabel:
                                  ', ${strings.timesSpoken(match.times)}',
                              style: appText(
                                size: 15,
                                weight: 800,
                                color: row.isWarning
                                    ? AppColors.warning
                                    : AppColors.accent,
                                height: 1.3,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.meaning(row),
                      style: hasData
                          ? appText(
                              size: 15,
                              weight: 400,
                              color: AppColors.meaning,
                              height: 1.5,
                            )
                          : appText(
                              size: 14,
                              weight: 400,
                              color: AppColors.muted,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PairBox extends StatelessWidget {
  const PairBox({
    super.key,
    required this.pair,
    required this.isWarning,
    required this.hasData,
  });

  final String pair;
  final bool isWarning;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    final metrics = AppMetrics.of(context);
    final style = appText(
      size: metrics.pairSize,
      weight: hasData ? 800 : 700,
      color: isWarning
          ? AppColors.warning
          : hasData
          ? AppColors.accent
          : AppColors.muted,
      tabular: true,
    );
    final label = Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(pair, maxLines: 1, style: style),
      ),
    );
    if (!hasData) {
      return SizedBox.square(
        dimension: metrics.pairBox,
        child: CustomPaint(painter: const _DashedBoxPainter(), child: label),
      );
    }
    return Container(
      width: metrics.pairBox,
      height: metrics.pairBox,
      decoration: BoxDecoration(
        color: isWarning ? AppColors.warningSurface : AppColors.pairSurface,
        border: isWarning
            ? Border.all(color: AppColors.warningBorder, width: 1.5)
            : Border.all(color: AppColors.accentBorder),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: label,
    );
  }
}

/// Viền nét đứt của ô cặp số chưa có dữ liệu.
class _DashedBoxPainter extends CustomPainter {
  const _DashedBoxPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.75),
          const Radius.circular(16),
        ),
      );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.dashedBorder;
    for (final PathMetric metric in outline.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += 8) {
        canvas.drawPath(metric.extractPath(start, start + 4.5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBoxPainter oldDelegate) => false;
}
