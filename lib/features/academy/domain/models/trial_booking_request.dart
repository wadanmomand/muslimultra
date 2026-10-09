class TrialBookingRequest {
  final String studentName;
  final String contactInfo;
  final String? programId;
  final String programTitle;
  final String preferredTime;
  final String notes;

  const TrialBookingRequest({
    required this.studentName,
    required this.contactInfo,
    this.programId,
    required this.programTitle,
    this.preferredTime = 'Flexible',
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'student_name': studentName.trim(),
      'contact_info': contactInfo.trim(),
      'program_id': programId?.isNotEmpty == true ? programId : null,
      'program_title': programTitle.trim().isNotEmpty ? programTitle.trim() : 'General Trial',
      'preferred_time': preferredTime.trim().isNotEmpty ? preferredTime.trim() : 'Flexible',
      'notes': notes.trim(),
      'status': 'new',
    };
  }
}
