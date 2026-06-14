const kDriverTag = 'ドライバー';
const kWoodTag = 'ウッド';
const kUtilityTag = 'ユーティリティ';
const kIronTag = 'アイアン';
const kApproachTag = 'アプローチ';
const kPutterTag = 'パター';
const kMentalTag = 'メンタル';

const kPrimaryClubOptions = [
  kDriverTag,
  kWoodTag,
  kUtilityTag,
  kIronTag,
  kApproachTag,
  kPutterTag,
];

const kWoodNumbers = [3, 5, 7];
const kUtilityNumbers = [3, 4, 5];
const kIronNumbers = [3, 4, 5, 6, 7, 8, 9];
const kApproachNamedTypes = ['PW', 'SW'];
const kApproachLofts = [48, 50, 52, 54, 56, 58, 60];
const kLegacyApproachTypes = ['GW', 'LW'];

String formatWoodTag(int number) => '$number番$kWoodTag';

String formatUtilityTag(int number) => '$number番$kUtilityTag';

String formatIronTag(int number) => '$number番$kIronTag';

String formatApproachNamedTag(String type) => '$type$kApproachTag';

String formatApproachLoftTag(int loft) => '$loft°$kApproachTag';

String formatApproachFromSelection(String selection) {
  if (kApproachNamedTypes.contains(selection) ||
      kLegacyApproachTypes.contains(selection)) {
    return formatApproachNamedTag(selection);
  }
  return formatApproachLoftTag(int.parse(selection));
}

int? parseWoodNumber(String tag) {
  final match = RegExp(r'^(\d+)番ウッド$').firstMatch(tag);
  if (match == null) {
    return null;
  }
  return int.parse(match.group(1)!);
}

int? parseUtilityNumber(String tag) {
  final match = RegExp(r'^(\d+)番ユーティリティ$').firstMatch(tag);
  if (match == null) {
    return null;
  }
  return int.parse(match.group(1)!);
}

int? parseIronNumber(String tag) {
  final match = RegExp(r'^(\d+)番アイアン$').firstMatch(tag);
  if (match == null) {
    return null;
  }
  return int.parse(match.group(1)!);
}

String? parseApproachSelection(String tag) {
  for (final type in kApproachNamedTypes) {
    if (tag == formatApproachNamedTag(type)) {
      return type;
    }
  }
  for (final type in kLegacyApproachTypes) {
    if (tag == formatApproachNamedTag(type)) {
      return type;
    }
  }
  final loftMatch = RegExp(r'^(\d+)°アプローチ$').firstMatch(tag);
  if (loftMatch != null) {
    return loftMatch.group(1);
  }
  return null;
}

bool isWoodRelatedTag(String tag) {
  return tag == kWoodTag || parseWoodNumber(tag) != null;
}

bool isUtilityRelatedTag(String tag) {
  return tag == kUtilityTag || parseUtilityNumber(tag) != null;
}

bool isIronRelatedTag(String tag) {
  return tag == kIronTag || parseIronNumber(tag) != null;
}

bool isApproachRelatedTag(String tag) {
  return tag == kApproachTag || parseApproachSelection(tag) != null;
}

List<String> get kApproachSubFilterOptions => [
      ...kApproachNamedTypes,
      ...kApproachLofts.map((loft) => loft.toString()),
    ];

bool recordMatchesTagFilter(
  List<String> recordTags,
  String? tagFilter,
  String? subFilter,
) {
  if (tagFilter == null) {
    return true;
  }
  if (tagFilter == kWoodTag) {
    if (subFilter != null) {
      return recordTags.contains(formatWoodTag(int.parse(subFilter)));
    }
    return recordTags.any(isWoodRelatedTag);
  }
  if (tagFilter == kUtilityTag) {
    if (subFilter != null) {
      return recordTags.contains(formatUtilityTag(int.parse(subFilter)));
    }
    return recordTags.any(isUtilityRelatedTag);
  }
  if (tagFilter == kIronTag) {
    if (subFilter != null) {
      return recordTags.contains(formatIronTag(int.parse(subFilter)));
    }
    return recordTags.any(isIronRelatedTag);
  }
  if (tagFilter == kApproachTag) {
    if (subFilter != null) {
      return recordTags.contains(formatApproachFromSelection(subFilter));
    }
    return recordTags.any(isApproachRelatedTag);
  }
  return recordTags.contains(tagFilter);
}

typedef FormTagState = ({
  String? primaryClub,
  int? woodNumber,
  int? utilityNumber,
  int? ironNumber,
  String? approachSelection,
  bool mentalSelected,
});

FormTagState parseTagsForForm(List<String> tags) {
  String? primaryClub;
  int? woodNumber;
  int? utilityNumber;
  int? ironNumber;
  String? approachSelection;
  var mentalSelected = false;

  for (final tag in tags) {
    if (tag == kMentalTag) {
      mentalSelected = true;
      continue;
    }
    if (primaryClub != null) {
      continue;
    }

    final wood = parseWoodNumber(tag);
    if (wood != null) {
      primaryClub = kWoodTag;
      woodNumber = wood;
      continue;
    }
    final utility = parseUtilityNumber(tag);
    if (utility != null) {
      primaryClub = kUtilityTag;
      utilityNumber = utility;
      continue;
    }
    final iron = parseIronNumber(tag);
    if (iron != null) {
      primaryClub = kIronTag;
      ironNumber = iron;
      continue;
    }
    final approach = parseApproachSelection(tag);
    if (approach != null) {
      primaryClub = kApproachTag;
      approachSelection = approach;
      continue;
    }
    if (tag == kDriverTag) {
      primaryClub = kDriverTag;
    } else if (tag == kWoodTag) {
      primaryClub = kWoodTag;
    } else if (tag == kUtilityTag) {
      primaryClub = kUtilityTag;
    } else if (tag == kIronTag) {
      primaryClub = kIronTag;
    } else if (tag == kApproachTag) {
      primaryClub = kApproachTag;
    } else if (tag == kPutterTag) {
      primaryClub = kPutterTag;
    }
  }

  return (
    primaryClub: primaryClub,
    woodNumber: woodNumber,
    utilityNumber: utilityNumber,
    ironNumber: ironNumber,
    approachSelection: approachSelection,
    mentalSelected: mentalSelected,
  );
}

List<String> buildTagsForSave({
  required String? primaryClub,
  required int? woodNumber,
  required int? utilityNumber,
  required int? ironNumber,
  required String? approachSelection,
  required bool mentalSelected,
}) {
  final tags = <String>[];
  switch (primaryClub) {
    case kDriverTag:
    case kPutterTag:
      tags.add(primaryClub!);
    case kWoodTag:
      if (woodNumber != null) {
        tags.add(formatWoodTag(woodNumber));
      }
    case kUtilityTag:
      if (utilityNumber != null) {
        tags.add(formatUtilityTag(utilityNumber));
      }
    case kIronTag:
      if (ironNumber != null) {
        tags.add(formatIronTag(ironNumber));
      }
    case kApproachTag:
      if (approachSelection != null) {
        tags.add(formatApproachFromSelection(approachSelection));
      }
  }
  if (mentalSelected) {
    tags.add(kMentalTag);
  }
  return tags;
}

bool tagHasSubFilter(String tag) {
  return tag == kWoodTag ||
      tag == kUtilityTag ||
      tag == kIronTag ||
      tag == kApproachTag;
}

bool primaryClubNeedsSubSelection(String? primaryClub) {
  return primaryClub == kWoodTag ||
      primaryClub == kUtilityTag ||
      primaryClub == kIronTag ||
      primaryClub == kApproachTag;
}

/// 一覧フィルタ用の短い表示名（保存タグとは別）
String tagFilterChipLabel(String tag) {
  return switch (tag) {
    kDriverTag => 'DR',
    kUtilityTag => 'UT',
    kApproachTag => 'AW',
    kPutterTag => 'PT',
    _ => tag,
  };
}
