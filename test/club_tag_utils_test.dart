import 'package:flutter_test/flutter_test.dart';
import 'package:golf_record_app/utils/club_tag_utils.dart';

void main() {
  group('wood tags', () {
    test('formats and parses wood tag', () {
      expect(formatWoodTag(5), '5番ウッド');
      expect(parseWoodNumber('5番ウッド'), 5);
    });
  });

  group('iron tags', () {
    test('formats and parses iron tag', () {
      expect(formatIronTag(7), '7番アイアン');
      expect(parseIronNumber('7番アイアン'), 7);
    });
  });

  group('approach tags', () {
    test('formats and parses PW/SW', () {
      expect(formatApproachFromSelection('SW'), 'SWアプローチ');
      expect(parseApproachSelection('SWアプローチ'), 'SW');
    });

    test('formats and parses loft', () {
      expect(formatApproachFromSelection('52'), '52°アプローチ');
      expect(parseApproachSelection('52°アプローチ'), '52');
    });

    test('parses legacy GW/LW', () {
      expect(parseApproachSelection('GWアプローチ'), 'GW');
    });
  });

  group('recordMatchesTagFilter', () {
    test('matches approach loft', () {
      expect(
        recordMatchesTagFilter(['52°アプローチ'], kApproachTag, '52'),
        isTrue,
      );
      expect(
        recordMatchesTagFilter(['56°アプローチ'], kApproachTag, '52'),
        isFalse,
      );
    });
  });

  group('parseTagsForForm / buildTagsForSave', () {
    test('single primary club with mental', () {
      final parsed = parseTagsForForm(['7番アイアン', 'メンタル']);
      expect(parsed.primaryClub, kIronTag);
      expect(parsed.ironNumber, 7);
      expect(parsed.mentalSelected, isTrue);

      final saved = buildTagsForSave(
        primaryClub: parsed.primaryClub,
        woodNumber: parsed.woodNumber,
        ironNumber: parsed.ironNumber,
        approachSelection: parsed.approachSelection,
        mentalSelected: parsed.mentalSelected,
      );
      expect(saved, ['7番アイアン', 'メンタル']);
    });

    test('approach loft save', () {
      final saved = buildTagsForSave(
        primaryClub: kApproachTag,
        woodNumber: null,
        ironNumber: null,
        approachSelection: '52',
        mentalSelected: false,
      );
      expect(saved, ['52°アプローチ']);
    });
  });
}
