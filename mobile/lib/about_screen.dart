import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show LicensePage, SelectionArea, Theme, ThemeData;

import 'language_store.dart';

/// Phải khớp `version` trong pubspec.yaml.
const appVersion = '1.0.0';
const privacyPolicyUrl =
    'https://github.com/phamphuongphuongnd/taodo/blob/master/docs/compliance/chinh-sach-quyen-rieng-tu.md';
const issuesUrl = 'https://github.com/phamphuongphuongnd/taodo/issues';

const _secondaryText = Color(0xFFAEAEB2);

/// Quyền riêng tư, lưu ý sử dụng, liên hệ và giấy phép. Toàn bộ nằm trong app
/// nên đọc được cả khi không có mạng.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _openLicenses(BuildContext context) {
    unawaited(
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => Theme(
            data: ThemeData.dark(),
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
        // Chọn được chữ để sao chép link, app không có quyền mở mạng.
        child: SelectionArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _Section(
                title: strings.about,
                body: '${strings.version} $appVersion',
              ),
              _Section(
                title: strings.privacyTitle,
                body: '${strings.privacyBody}\n\n$privacyPolicyUrl',
              ),
              _Section(title: strings.noticeTitle, body: strings.noticeBody),
              _Section(
                title: strings.contactTitle,
                body: '${strings.contactBody}\n\n$issuesUrl',
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                onPressed: () => _openLicenses(context),
                child: Text(
                  strings.licenses,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
