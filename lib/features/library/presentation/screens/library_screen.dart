import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/library/domain/models/book.dart';
import 'package:muslim_ultra/features/library/domain/models/book_progress.dart';
import 'package:muslim_ultra/features/library/presentation/providers/library_providers.dart';
import 'package:muslim_ultra/features/library/presentation/screens/book_reader_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final booksAsync = ref.watch(booksCatalogProvider);
    final downloadedAsync = ref.watch(downloadedBooksProvider);
    final progressAsync = ref.watch(libraryProgressMapProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        title: Text(
          l10n.libraryTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.goldLight : AppColors.goldDark,
          ),
        ),
        backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandCard,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.goldLight : AppColors.goldDark,
        ),
      ),
      body: booksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (err, _) => Center(
          child: Text(
            l10n.libraryLoadError,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
            ),
          ),
        ),
        data: (books) {
          if (books.isEmpty) {
            return Center(
              child: Text(
                l10n.libraryEmptyCatalog,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
            );
          }

          final downloadedSet = downloadedAsync.value ?? <String>{};
          final progressMap = progressAsync.value ?? <String, BookProgress>{};

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeaderBanner(context, isDark, l10n);
              }
              final book = books[index - 1];
              final isDownloaded = downloadedSet.contains(book.id);
              final progress = progressMap[book.id];

              return _buildBookCard(
                context: context,
                ref: ref,
                isDark: isDark,
                locale: locale,
                l10n: l10n,
                book: book,
                isDownloaded: isDownloaded,
                progress: progress,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_stories_outlined, color: AppColors.gold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.libraryBannerTitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.goldLight : AppColors.goldDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.libraryBannerSubtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required String locale,
    required AppLocalizations l10n,
    required Book book,
    required bool isDownloaded,
    required BookProgress? progress,
  }) {
    final downloadProgress = ref.watch(bookDownloadProgressProvider(book.id));
    final isDownloading = downloadProgress != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Book Title + Language & Size Badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.localizedTitle(locale),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.lang.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.goldLight : AppColors.goldDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.midnightNavyDark
                                  : AppColors.sandBackground,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.midnightNavyBorder
                                    : AppColors.sandBorder,
                              ),
                            ),
                            child: Text(
                              '${book.sizeMb.toStringAsFixed(1)} MB',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.sandTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              book.localizedDescription(locale),
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),

            // Reading Progress Indicator (if read)
            if (progress != null && progress.lastPage > 1) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark_added_rounded, size: 14, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.libraryLastReadPage} ${progress.lastPage}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.goldLight : AppColors.goldDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Download Progress Bar (if downloading)
            if (isDownloading) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: downloadProgress > 0 ? downloadProgress : null,
                      backgroundColor: isDark
                          ? AppColors.midnightNavyDark
                          : AppColors.sandBackground,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.libraryDownloadingProgress} ${(downloadProgress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.goldLight : AppColors.goldDark,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (isDownloaded) {
                          _openBookReader(context, ref, book, progress?.lastPage ?? 1);
                        } else {
                          _handleDownloadClick(context, ref, l10n, book);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDownloaded ? AppColors.gold : AppColors.midnightNavy,
                        foregroundColor:
                            isDownloaded ? AppColors.midnightNavyDark : AppColors.goldLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.gold.withValues(alpha: 0.5),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: Icon(
                        isDownloaded ? Icons.menu_book_rounded : Icons.download_rounded,
                        size: 16,
                      ),
                      label: Text(
                        isDownloaded ? l10n.libraryOpenBook : l10n.libraryDownloadBook,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  if (isDownloaded) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: l10n.libraryDeleteBook,
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                      onPressed: () async {
                        await ref.read(libraryRepositoryProvider).deleteDownloadedBook(book.id);
                        ref.invalidate(downloadedBooksProvider);
                      },
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleDownloadClick(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Book book,
  ) {
    if (book.isLargeFile) {
      // Show Wi-Fi warning dialog
      showDialog(
        context: context,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.wifi_rounded, color: AppColors.gold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.libraryLargeFileTitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              l10n.libraryLargeFileWarning(book.sizeMb.toStringAsFixed(1)),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _startDownload(context, ref, l10n, book);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.midnightNavyDark,
                ),
                child: Text(l10n.libraryDownloadAnyway),
              ),
            ],
          );
        },
      );
    } else {
      _startDownload(context, ref, l10n, book);
    }
  }

  Future<void> _startDownload(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Book book,
  ) async {
    final progressNotifier = ref.read(bookDownloadProgressProvider(book.id).notifier);
    progressNotifier.state = 0.01;

    try {
      final repo = ref.read(libraryRepositoryProvider);
      await repo.downloadBook(
        book,
        onProgress: (p) {
          progressNotifier.state = p;
        },
      );
      ref.invalidate(downloadedBooksProvider);
      progressNotifier.state = null;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.libraryDownloadComplete(book.localizedTitle(Localizations.localeOf(context).languageCode))),
            backgroundColor: AppColors.midnightNavy,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      progressNotifier.state = null;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.libraryDownloadError),
            backgroundColor: AppColors.midnightNavy,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openBookReader(
    BuildContext context,
    WidgetRef ref,
    Book book,
    int initialPage,
  ) async {
    final repo = ref.read(libraryRepositoryProvider);
    final filePath = await repo.getLocalBookPath(book.id);

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookReaderScreen(
            book: book,
            filePath: filePath,
            initialPage: initialPage,
          ),
        ),
      );
    }
  }
}
