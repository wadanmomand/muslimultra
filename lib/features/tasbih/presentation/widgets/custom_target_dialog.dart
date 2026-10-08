import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';

class CustomTargetDialog extends StatefulWidget {
  final int currentTarget;
  final Function(int) onTargetSet;

  const CustomTargetDialog({
    super.key,
    required this.currentTarget,
    required this.onTargetSet,
  });

  static Future<void> show(
    BuildContext context, {
    required int currentTarget,
    required Function(int) onTargetSet,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CustomTargetDialog(
        currentTarget: currentTarget,
        onTargetSet: onTargetSet,
      ),
    );
  }

  @override
  State<CustomTargetDialog> createState() => _CustomTargetDialogState();
}

class _CustomTargetDialogState extends State<CustomTargetDialog> {
  late TextEditingController _controller;
  final List<int> _quickPresets = [33, 34, 99, 100, 500, 1000];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTarget.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    if (value != null && value > 0) {
      widget.onTargetSet(value);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      title: Text(
        l10n.customTarget,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
            ),
            decoration: InputDecoration(
              labelText: l10n.target,
              labelStyle: const TextStyle(color: AppColors.gold),
              filled: true,
              fillColor: isDark ? AppColors.midnightNavyDark : AppColors.sandCardElevated,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickPresets.map((preset) {
              return ActionChip(
                label: Text('$preset'),
                backgroundColor: isDark
                    ? AppColors.midnightNavyDark
                    : AppColors.sandCardElevated,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.goldLight : AppColors.goldDark,
                ),
                side: BorderSide(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
                onPressed: () {
                  setState(() {
                    _controller.text = preset.toString();
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.midnightNavyDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(l10n.setTarget),
        ),
      ],
    );
  }
}
