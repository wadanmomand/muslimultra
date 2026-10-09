import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/academy/domain/models/academy_program.dart';
import 'package:muslim_ultra/features/academy/domain/models/academy_teacher.dart';
import 'package:muslim_ultra/features/academy/domain/models/trial_booking_request.dart';

class AcademyFetchResult<T> {
  final T data;
  final bool isFromOfflineCache;

  const AcademyFetchResult({
    required this.data,
    this.isFromOfflineCache = false,
  });
}

class AcademyRepository {
  static const String supabaseUrl = 'https://apsaxarhenlsmigaklko.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFwc2F4YXJoZW5sc21pZ2FrbGtvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEyMjYxMzUsImV4cCI6MjEwNjgwMjEzNX0.oTNI7DlDi8uZ_Ja-IMRI9lbK8ZUCwmstCc2ti1pvyE8';

  static const String prefProgramsKey = 'cached_academy_programs_v1';
  static const String prefTeachersKey = 'cached_academy_teachers_v1';

  final http.Client _client;

  AcademyRepository({http.Client? client}) : _client = client ?? http.Client();

  static List<AcademyProgram>? _inMemoryPrograms;
  static List<AcademyTeacher>? _inMemoryTeachers;

  Map<String, String> get _headers => {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
      };

  /// Fetch active programs from Supabase REST API with persistent offline cache fallback
  Future<AcademyFetchResult<List<AcademyProgram>>> fetchPrograms({bool forceRefresh = false}) async {
    if (!forceRefresh && _inMemoryPrograms != null && _inMemoryPrograms!.isNotEmpty) {
      return AcademyFetchResult(data: _inMemoryPrograms!, isFromOfflineCache: false);
    }

    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/programs?select=*&is_active=eq.true&order=display_order.asc');
      final response = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> list = json.decode(response.body) as List<dynamic>;
        final programs = list.map((item) => AcademyProgram.fromJson(item as Map<String, dynamic>)).toList();

        _inMemoryPrograms = List.unmodifiable(programs);
        await _persistProgramsToPrefs(programs);
        return AcademyFetchResult(data: _inMemoryPrograms!, isFromOfflineCache: false);
      }
    } catch (e) {
      debugPrint('AcademyRepository: Network fetch programs error: $e');
    }

    // Fallback to on-disk SharedPreferences cache
    final cached = await _loadProgramsFromPrefs();
    if (cached.isNotEmpty) {
      _inMemoryPrograms = cached;
      return AcademyFetchResult(data: cached, isFromOfflineCache: true);
    }

    return AcademyFetchResult(data: _inMemoryPrograms ?? [], isFromOfflineCache: true);
  }

  /// Fetch active teachers from Supabase REST API with persistent offline cache fallback
  Future<AcademyFetchResult<List<AcademyTeacher>>> fetchTeachers({bool forceRefresh = false}) async {
    if (!forceRefresh && _inMemoryTeachers != null && _inMemoryTeachers!.isNotEmpty) {
      return AcademyFetchResult(data: _inMemoryTeachers!, isFromOfflineCache: false);
    }

    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/teachers?select=*&is_active=eq.true&order=display_order.asc');
      final response = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> list = json.decode(response.body) as List<dynamic>;
        final teachers = list.map((item) => AcademyTeacher.fromJson(item as Map<String, dynamic>)).toList();

        _inMemoryTeachers = List.unmodifiable(teachers);
        await _persistTeachersToPrefs(teachers);
        return AcademyFetchResult(data: _inMemoryTeachers!, isFromOfflineCache: false);
      }
    } catch (e) {
      debugPrint('AcademyRepository: Network fetch teachers error: $e');
    }

    // Fallback to on-disk SharedPreferences cache
    final cached = await _loadTeachersFromPrefs();
    if (cached.isNotEmpty) {
      _inMemoryTeachers = cached;
      return AcademyFetchResult(data: cached, isFromOfflineCache: true);
    }

    return AcademyFetchResult(data: _inMemoryTeachers ?? [], isFromOfflineCache: true);
  }

  /// Submit a real trial booking request to Supabase REST API.
  /// (Do NOT append .select() / ?select=* to the insert to avoid 401 on RLS)
  Future<bool> bookTrial(TrialBookingRequest request) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/trial_bookings');
      final body = json.encode(request.toJson());

      final response = await _client.post(
        uri,
        headers: _headers,
        body: body,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 201 || response.statusCode == 204 || response.statusCode == 200) {
        debugPrint('AcademyRepository: Trial booking successfully created for ${request.studentName}');
        return true;
      } else {
        debugPrint('AcademyRepository: Trial booking submission failed (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('AcademyRepository: Network error submitting trial booking: $e');
      return false;
    }
  }

  // --- Local Persistence Helpers ---

  Future<void> _persistProgramsToPrefs(List<AcademyProgram> programs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = programs.map((p) => p.toJson()).toList();
      await prefs.setString(prefProgramsKey, json.encode(jsonList));
    } catch (_) {}
  }

  Future<List<AcademyProgram>> _loadProgramsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefProgramsKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
        return decoded.map((item) => AcademyProgram.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _persistTeachersToPrefs(List<AcademyTeacher> teachers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = teachers.map((t) => t.toJson()).toList();
      await prefs.setString(prefTeachersKey, json.encode(jsonList));
    } catch (_) {}
  }

  Future<List<AcademyTeacher>> _loadTeachersFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefTeachersKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
        return decoded.map((item) => AcademyTeacher.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Testing helper
  static void setMemoryCacheForTesting({
    List<AcademyProgram>? programs,
    List<AcademyTeacher>? teachers,
  }) {
    if (programs != null) _inMemoryPrograms = List.unmodifiable(programs);
    if (teachers != null) _inMemoryTeachers = List.unmodifiable(teachers);
  }

  /// Reset cache for test isolation
  static void clearCacheForTesting() {
    _inMemoryPrograms = null;
    _inMemoryTeachers = null;
  }
}
