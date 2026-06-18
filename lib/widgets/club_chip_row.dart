import 'package:flutter/material.dart';
import 'package:golf_record_app/utils/club_tag_utils.dart';

class ClubCompactChip extends StatelessWidget {
  const ClubCompactChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

class ClubHorizontalChipRow extends StatelessWidget {
  const ClubHorizontalChipRow({required this.chips, super.key});

  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, index) => chips[index],
      ),
    );
  }
}

class ClubLabeledChipRow extends StatelessWidget {
  const ClubLabeledChipRow({
    required this.title,
    required this.chips,
    super.key,
  });

  final String title;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 36,
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(width: 8),
            Expanded(child: ClubHorizontalChipRow(chips: chips)),
          ],
        ),
      ),
    );
  }
}

String approachChipLabel(String option) {
  return kApproachNamedTypes.contains(option) ? option : '$option°';
}
