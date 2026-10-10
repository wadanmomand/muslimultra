import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/library/domain/models/book.dart';
import 'package:muslim_ultra/features/library/domain/models/book_progress.dart';
import 'package:muslim_ultra/features/library/presentation/providers/library_providers.dart';

class BookReaderScreen extends ConsumerStatefulWidget {
  final Book book;
  final String filePath;
  final int initialPage;

  const BookReaderScreen({
    super.key,
    required this.book,
    required this.filePath,
    this.initialPage = 1,
  });

  @override
  ConsumerState<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends ConsumerState<BookReaderScreen> {
  late PdfController _pdfController;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage > 0 ? widget.initialPage : 1;
    try {
      _pdfController = PdfController(
        document: PdfDocument.openFile(widget.filePath),
        initialPage: _currentPage,
      );
    } catch (_) {
      _hasError = true;
    }
  }

  @override
  void dispose() {
    if (!_hasError) {
      _pdfController.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    if (!mounted) return;
    setState(() => _currentPage = page);
    ref.read(libraryRepositoryProvider).saveProgress(
          BookProgress(
            bookId: widget.book.id,
            lastPage: page,
            totalPages: _totalPages,
            lastReadAt: DateTime.now(),
          ),
        );
    ref.invalidate(libraryProgressMapProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final bookTitle = widget.book.localizedTitle(locale);

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        title: Text(
          bookTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.goldLight : AppColors.goldDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandCard,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.goldLight : AppColors.goldDark,
        ),
        actions: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_currentPage / $_totalPages',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.goldLight : AppColors.goldDark,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _hasError
          ? Center(
              child: Text(
                l10n.libraryReaderError,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
            )
          : PdfView(
              controller: _pdfController,
              onPageChanged: _onPageChanged,
              onDocumentLoaded: (document) {
                if (mounted) {
                  setState(() {
                    _totalPages = document.pagesCount;
                  });
                }
              },
              onDocumentError: (error) {
                if (mounted) {
                  setState(() {
                    _hasError = true;
                  });
                }
              },
              builders: PdfViewBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                documentLoaderBuilder: (_) => const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
                pageLoaderBuilder: (_) => const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
                errorBuilder: (_, err) => Center(
                  child: Text(
                    l10n.libraryReaderError,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.sandTextPrimary,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
