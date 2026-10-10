import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/library/domain/models/book.dart';
import 'package:muslim_ultra/features/library/domain/models/book_progress.dart';

class LibraryRepository {
  static const String remoteCatalogUrl =
      'https://raw.githubusercontent.com/wadanmomand/muslimultra/main/assets/books/books.json';
  static const String bundledCatalogAsset = 'assets/books/books.json';
  static const String progressStorageKey = 'library_progress_v1';

  final http.Client _client;
  final AssetBundle? bundle;
  final SharedPreferences? prefs;
  final String? baseStoragePath;

  LibraryRepository({
    http.Client? client,
    this.bundle,
    this.prefs,
    this.baseStoragePath,
  }) : _client = client ?? http.Client();

  Future<SharedPreferences> _getPrefs() async {
    if (prefs != null) return prefs!;
    return await SharedPreferences.getInstance();
  }

  /// Fetches the book catalog from remote repository with 5s timeout; falls back to bundled asset
  Future<List<Book>> getBooksCatalog() async {
    // 1. Try remote fetch
    try {
      final response = await _client
          .get(Uri.parse(remoteCatalogUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['books'] is List) {
          final list = (decoded['books'] as List)
              .whereType<Map<String, dynamic>>()
              .map((j) => Book.fromJson(j))
              .toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {
      // Remote fetch failed or timed out, fall through to bundled asset
    }

    // 2. Fallback to bundled asset
    return await getBundledBooks();
  }

  /// Loads the bundled seed catalog
  Future<List<Book>> getBundledBooks() async {
    final b = bundle ?? rootBundle;
    final jsonStr = await b.loadString(bundledCatalogAsset);
    final dynamic decoded = jsonDecode(jsonStr);

    if (decoded is Map<String, dynamic> && decoded['books'] is List) {
      return (decoded['books'] as List)
          .whereType<Map<String, dynamic>>()
          .map((j) => Book.fromJson(j))
          .toList();
    }
    return const [];
  }

  /// Gets the local file path for a book PDF
  Future<String> getLocalBookPath(String bookId) async {
    final basePath = baseStoragePath ?? Directory.systemTemp.path;
    final booksDir = Directory('$basePath/muslim_ultra_books');
    if (!booksDir.existsSync()) {
      booksDir.createSync(recursive: true);
    }
    return '${booksDir.path}/$bookId.pdf';
  }

  /// Checks if a book has already been downloaded to local disk
  Future<bool> isBookDownloaded(String bookId) async {
    final path = await getLocalBookPath(bookId);
    final file = File(path);
    return file.existsSync() && file.lengthSync() > 0;
  }

  /// Downloads a book PDF with progress updates
  Future<File> downloadBook(
    Book book, {
    void Function(double progress)? onProgress,
  }) async {
    final filePath = await getLocalBookPath(book.id);
    final file = File(filePath);

    final request = http.Request('GET', Uri.parse(book.url));
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to download book: HTTP ${response.statusCode}');
    }

    final contentLength = response.contentLength ?? (book.sizeMb * 1024 * 1024).toInt();
    var receivedBytes = 0;
    final bytes = <int>[];

    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
      receivedBytes += chunk.length;
      if (onProgress != null && contentLength > 0) {
        onProgress(receivedBytes / contentLength);
      }
    }

    await file.writeAsBytes(bytes);
    if (onProgress != null) {
      onProgress(1.0);
    }
    return file;
  }

  /// Loads reading progress for all books
  Future<Map<String, BookProgress>> getAllProgress() async {
    try {
      final p = await _getPrefs();
      final raw = p.getString(progressStorageKey);
      if (raw == null || raw.isEmpty) return {};

      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};

      final result = <String, BookProgress>{};
      decoded.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          result[key] = BookProgress.fromJson(val);
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  /// Gets progress for a specific book
  Future<BookProgress?> getBookProgress(String bookId) async {
    final all = await getAllProgress();
    return all[bookId];
  }

  /// Saves last read page and progress
  Future<void> saveProgress(BookProgress progress) async {
    try {
      final p = await _getPrefs();
      final all = await getAllProgress();
      all[progress.bookId] = progress;

      final mapData = all.map((k, v) => MapEntry(k, v.toJson()));
      await p.setString(progressStorageKey, jsonEncode(mapData));
    } catch (_) {
      // Ignore storage errors
    }
  }

  /// Deletes a downloaded book from local storage
  Future<void> deleteDownloadedBook(String bookId) async {
    try {
      final path = await getLocalBookPath(bookId);
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }
}
