import 'package:flutter/material.dart';

class RangeSelector extends StatelessWidget {
  final int selectedRange;
  final Function(int) onRangeSelected;

  const RangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Pilih rentang grafik',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            _buildRangeButton(context, '1H', 1),
            _buildRangeButton(context, '1M', 7),
            _buildRangeButton(context, '1B', 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeButton(BuildContext context, String label, int range) {
    final isSelected = selectedRange == range;
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Rentang $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onRangeSelected(range),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 38),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
