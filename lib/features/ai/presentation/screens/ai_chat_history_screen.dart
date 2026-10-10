import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/ai/domain/models/ai_chat_session.dart';
import 'package:muslim_ultra/features/ai/presentation/providers/ai_providers.dart';

class AiChatHistoryScreen extends ConsumerStatefulWidget {
  const AiChatHistoryScreen({super.key});

  @override
  ConsumerState<AiChatHistoryScreen> createState() => _AiChatHistoryScreenState();
}

class _AiChatHistoryScreenState extends ConsumerState<AiChatHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessions = ref.watch(aiChatSessionsProvider);
    final activeId = ref.watch(activeSessionIdProvider);

    final filteredSessions = sessions.where((s) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      if (s.title.toLowerCase().contains(q)) return true;
      for (final msg in s.messages) {
        if (msg.text.toLowerCase().contains(q)) return true;
      }
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        title: Text(
          l10n.aiHistoryTitle,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandCard,
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('new_chat_appbar_button'),
            icon: const Icon(Icons.add_comment_outlined, color: AppColors.gold),
            tooltip: l10n.aiHistoryNewChat,
            onPressed: () async {
              await ref.read(aiChatSessionsProvider.notifier).startNewChat();
              ref.read(aiChatMessagesProvider.notifier).reloadFromSession();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search box
          Container(
            padding: const EdgeInsets.all(12),
            color: isDark ? AppColors.midnightNavy : AppColors.sandCard,
            child: TextField(
              key: const Key('history_search_field'),
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: l10n.aiHistorySearchHint,
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
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
          ),
          // Session List
          Expanded(
            child: filteredSessions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.aiHistoryEmpty,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: filteredSessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) {
                      final session = filteredSessions[index];
                      final isActive = session.id == activeId;
                      return _buildSessionCard(
                        context,
                        session: session,
                        isActive: isActive,
                        isDark: isDark,
                        l10n: l10n,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context, {
    required AiChatSession session,
    required bool isActive,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    return Material(
      key: Key('session_card_${session.id}'),
      color: isActive
          ? (isDark ? AppColors.midnightNavyCardElevated : AppColors.sandCardElevated)
          : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive
              ? AppColors.gold
              : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: () {
          ref.read(aiChatSessionsProvider.notifier).selectSession(session.id);
          ref.read(aiChatMessagesProvider.notifier).reloadFromSession();
          Navigator.of(context).pop();
        },
        leading: CircleAvatar(
          backgroundColor: session.isPrivate
              ? AppColors.gold.withValues(alpha: 0.2)
              : (isDark ? AppColors.midnightNavyDark : AppColors.sandBackground),
          child: Icon(
            session.isPrivate ? Icons.lock_outline : Icons.chat_outlined,
            color: AppColors.gold,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                session.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
            ),
            if (session.isPrivate)
              Container(
                margin: const EdgeInsets.only(left: 6, right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l10n.aiHistoryPrivateMode,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${session.messages.length} ${session.messages.length == 1 ? "msg" : "msgs"} • ${_formatDate(session.updatedAt)}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Private mode quick toggle
            IconButton(
              key: Key('toggle_private_${session.id}'),
              icon: Icon(
                session.isPrivate ? Icons.lock : Icons.lock_open_outlined,
                size: 18,
                color: session.isPrivate ? AppColors.gold : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
              ),
              tooltip: l10n.aiHistoryPrivateMode,
              onPressed: () {
                ref.read(aiChatSessionsProvider.notifier).togglePrivateMode(session.id);
              },
            ),
            PopupMenuButton<String>(
              key: Key('session_menu_${session.id}'),
              icon: Icon(
                Icons.more_vert,
                size: 20,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
              onSelected: (val) {
                if (val == 'rename') {
                  _showRenameDialog(context, session);
                } else if (val == 'export') {
                  ref.read(aiChatSessionsProvider.notifier).exportSession(session.id);
                } else if (val == 'delete') {
                  _confirmDeleteSession(context, session);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 18, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Text(l10n.aiHistoryRename),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      const Icon(Icons.share_outlined, size: 18, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Text(l10n.aiHistoryExport),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(l10n.aiHistoryDelete),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, AiChatSession session) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: session.title);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.aiHistoryRename),
        content: TextField(
          key: const Key('rename_session_input'),
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n.aiReportCancel),
          ),
          ElevatedButton(
            key: const Key('rename_session_submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.midnightNavy,
            ),
            onPressed: () {
              ref
                  .read(aiChatSessionsProvider.notifier)
                  .renameSession(session.id, controller.text);
              Navigator.of(dialogCtx).pop();
            },
            child: Text(l10n.aiHistoryRename),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSession(BuildContext context, AiChatSession session) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.aiHistoryDelete),
        content: Text(l10n.aiHistoryDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n.aiReportCancel),
          ),
          ElevatedButton(
            key: const Key('delete_session_confirm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(aiChatSessionsProvider.notifier).deleteSession(session.id);
              ref.read(aiChatMessagesProvider.notifier).reloadFromSession();
              Navigator.of(dialogCtx).pop();
            },
            child: Text(l10n.aiHistoryDelete),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
