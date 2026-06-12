import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_record_app/utils/youtube_search_utils.dart';

void main() {
  group('buildYouTubeSearchQuery', () {
    test('クラブタグとミスの原因から検索クエリを組み立てる', () {
      expect(
        buildYouTubeSearchQuery(
          missCause: 'スライス',
          tags: ['7番アイアン', 'メンタル'],
        ),
        'ゴルフ 7番アイアン スライス 直し方',
      );
    });

    test('メンタルのみの場合はクラブなしでクエリを組み立てる', () {
      expect(
        buildYouTubeSearchQuery(
          missCause: '焦って打った',
          tags: ['メンタル'],
        ),
        'ゴルフ 焦って打った 直し方',
      );
    });
  });

  group('buildYouTubeSearchUrl', () {
    test('YouTube検索URLを生成する', () {
      final url = buildYouTubeSearchUrl('ゴルフ 7番アイアン スライス 直し方');
      expect(url.scheme, 'https');
      expect(url.host, 'www.youtube.com');
      expect(url.path, '/results');
      expect(url.queryParameters['search_query'], 'ゴルフ 7番アイアン スライス 直し方');
    });
  });

  group('youtubeLaunchError', () {
    test('MissingPluginException のメッセージを返す', () {
      expect(
        youtubeLaunchError(MissingPluginException('launch')),
        'アプリを一度終了して、再起動してください',
      );
    });
  });
}
