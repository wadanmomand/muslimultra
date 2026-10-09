import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/academy/domain/models/academy_program.dart';
import 'package:muslim_ultra/features/academy/domain/models/trial_booking_request.dart';
import 'package:muslim_ultra/features/academy/presentation/providers/academy_providers.dart';

class TrialBookingScreen extends ConsumerStatefulWidget {
  final AcademyProgram? initialProgram;

  const TrialBookingScreen({
    super.key,
    this.initialProgram,
  });

  @override
  ConsumerState<TrialBookingScreen> createState() => _TrialBookingScreenState();
}

class _TrialBookingScreenState extends ConsumerState<TrialBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();

  AcademyProgram? _selectedProgram;
  String _preferredTime = 'Flexible';
  bool _submittedSuccessfully = false;

  @override
  void initState() {
    super.initState();
    _selectedProgram = widget.initialProgram;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final request = TrialBookingRequest(
      studentName: _nameController.text,
      contactInfo: _contactController.text,
      programId: _selectedProgram?.id,
      programTitle: _selectedProgram?.title ?? 'General Trial',
      preferredTime: _preferredTime,
      notes: _notesController.text,
    );

    final success = await ref.read(trialBookingNotifierProvider.notifier).submitBooking(request);

    if (mounted) {
      if (success) {
        setState(() {
          _submittedSuccessfully = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bookingFailedError),
            backgroundColor: Colors.redAccent.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingState = ref.watch(trialBookingNotifierProvider);
    final programsAsync = ref.watch(academyProgramsProvider);

    if (_submittedSuccessfully) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.gold,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.bookingSuccessTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.bookingSuccessDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.backToAcademy,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.midnightNavy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final timeOptions = [
      {'value': 'Flexible', 'label': l10n.bookingTimeFlexible},
      {'value': 'Morning', 'label': l10n.bookingTimeMorning},
      {'value': 'Afternoon', 'label': l10n.bookingTimeAfternoon},
      {'value': 'Evening', 'label': l10n.bookingTimeEvening},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
        elevation: 0,
        title: Text(
          l10n.bookingFormTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description pill
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppColors.gold, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.academyHeroSubtitle,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Student Name Field
              Text(
                l10n.bookingStudentName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.bookingNameRequired;
                  }
                  return null;
                },
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: l10n.bookingStudentNameHint,
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                    ),
                  ),
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
              ),
              const SizedBox(height: 16),

              // Phone / WhatsApp Field
              Text(
                l10n.bookingContact,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.bookingContactRequired;
                  }
                  return null;
                },
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: l10n.bookingContactHint,
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                    ),
                  ),
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
              ),
              const SizedBox(height: 16),

              // Program Selector Dropdown
              Text(
                l10n.bookingProgram,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              programsAsync.when(
                data: (result) {
                  final programs = result.data;
                  if (_selectedProgram == null && programs.isNotEmpty) {
                    _selectedProgram = programs.first;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AcademyProgram>(
                        value: _selectedProgram != null && programs.any((p) => p.id == _selectedProgram!.id)
                            ? programs.firstWhere((p) => p.id == _selectedProgram!.id)
                            : (programs.isNotEmpty ? programs.first : null),
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gold),
                        onChanged: (AcademyProgram? newVal) {
                          setState(() {
                            _selectedProgram = newVal;
                          });
                        },
                        items: programs.map((p) {
                          return DropdownMenuItem<AcademyProgram>(
                            value: p,
                            child: Text(
                              p.title,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2)),
                ),
                error: (_, __) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedProgram?.title ?? 'General Quran Trial',
                    style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preferred Time Chips
              Text(
                l10n.bookingPreferredTime,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: timeOptions.map((opt) {
                  final isSelected = _preferredTime == opt['value'];
                  return ChoiceChip(
                    label: Text(
                      opt['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.midnightNavy : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.gold,
                    backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                    side: BorderSide(
                      color: isSelected ? AppColors.gold : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _preferredTime = opt['value'] as String;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Notes Field
              Text(
                l10n.bookingNotes,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: l10n.bookingNotesHint,
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                    ),
                  ),
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
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: bookingState.isLoading ? null : () => _submitBooking(l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: bookingState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.midnightNavy,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.bookingSubmitBtn,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.midnightNavy,
                          ),
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
