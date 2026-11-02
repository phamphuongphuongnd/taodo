import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show LicensePage, SelectionArea, Theme, ThemeData;

import 'language_store.dart';
import 'theme.dart';
import 'widgets.dart';

/// Phải khớp `version` trong pubspec.yaml.
const appVersion = '1.0.0';
const privacyPolicyUrl =
    'https://github.com/phamphuongphuongnd/taodo/blob/master/docs/compliance/chinh-sach-quyen-rieng-tu.md';
const issuesUrl = 'https://github.com/phamphuongphuongnd/taodo/issues';

/// Quyền riêng tư, lưu ý sử dụng, liên hệ và giấy phép. Toàn bộ nằm trong app
/// nên đọc được cả khi không có mạng.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _openLicenses(BuildContext context) {
    unawaited(
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => Theme(
            data: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: AppColors.screen,
            ),
            child: const LicensePage(
              applicationName: 'Tọa Độ',
              applicationVersion: appVersion,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = LanguageScope.of(context).strings;
    final metrics = AppMetrics.of(context);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.screen,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackLink(label: strings.back),
            Expanded(
              // Chọn được chữ để sao chép link, app không có quyền mở mạng.
              child: SelectionArea(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    metrics.pageMargin,
                    8,
                    metrics.pageMargin,
                    32,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Semantics(
                        header: true,
                        child: Text(
                          strings.about,
                          style: appText(
                            size: 32,
                            weight: 800,
                            letterSpacing: -0.64,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${strings.version} $appVersion',
                        style: appText(
                          size: 15,
                          weight: 400,
                          color: AppColors.label,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: strings.tableTitle,
                      body: strings.tableBody,
                    ),
                    _Section(
                      title: strings.privacyTitle,
                      body: '${strings.privacyBody}\n\n$privacyPolicyUrl',
                    ),
                    _Section(
                      title: strings.noticeTitle,
                      body: strings.noticeBody,
                    ),
                    _Section(
                      title: strings.contactTitle,
                      body: '${strings.contactBody}\n\n$issuesUrl',
                    ),
                    SecondaryButton(
                      label: strings.licenses,
                      icon: CupertinoIcons.doc_text,
                      onPressed: () => _openLicenses(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        color: AppColors.card,
        border: AppColors.cardBorder,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: appText(size: 17, weight: 700)),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: appText(
                size: 15,
                weight: 400,
                color: AppColors.meaning,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
