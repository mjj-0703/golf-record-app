import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

String buildYouTubeSearchQuery({
  required String missCause,
  required List<String> tags,
}) {
  final parts = <String>['ゴルフ'];
  for (final tag in tags) {
    if (tag != 'メンタル') {
      parts.add(tag);
    }
  }
  final trimmedMissCause = missCause.trim();
  if (trimmedMissCause.isNotEmpty) {
    parts.add(trimmedMissCause);
  }
  parts.add('直し方');
  return parts.join(' ');
}

/// YouTube 検索結果ページ（ブラウザ / Custom Tabs で開く）。
Uri buildYouTubeSearchUrl(String query) {
  return Uri.https(
    'www.youtube.com',
    '/results',
    {'search_query': query},
  );
}

/// Custom Tabs / ブラウザで開く（WebView は使わない）。
Future<bool> launchVideoSearchInBrowser(Uri url) async {
  const modes = [
    LaunchMode.inAppBrowserView,
    LaunchMode.platformDefault,
    LaunchMode.externalApplication,
  ];

  for (final mode in modes) {
    try {
      if (await launchUrl(url, mode: mode)) {
        return true;
      }
    } on PlatformException {
      continue;
    }
  }
  return false;
}

String? youtubeLaunchError(Object error) {
  if (error is MissingPluginException) {
    return 'アプリを一度終了して、再起動してください';
  }
  return null;
}

Future<void> copySearchQuery(String query) {
  return Clipboard.setData(ClipboardData(text: query));
}
