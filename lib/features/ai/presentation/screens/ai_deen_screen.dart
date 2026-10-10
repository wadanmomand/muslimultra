import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/ai/domain/models/chat_message.dart';
import 'package:muslim_ultra/features/ai/presentation/providers/ai_providers.dart';
import 'package:muslim_ultra/features/ai/presentation/screens/ai_chat_history_screen.dart';
import 'package:muslim_ultra/features/quran/presentation/providers/quran_providers.dart';

class AiDeenScreen extends ConsumerStatefulWidget {
  const AiDeenScreen({super.key});

  @override
  ConsumerState<AiDeenScreen> createState() => _AiDeenScreenState();
}

class _AiDeenScreenState extends ConsumerState<AiDeenScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingContext = ref.read(pendingAiQuestionContextProvider);
      if (pendingContext != null && pendingContext.isNotEmpty) {
        _textController.text = pendingContext;
        _submitMessage();
        ref.read(pendingAiQuestionContextProvider.notifier).state = null;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _submitMessage([String? overrideText]) {
    final text = overrideText ?? _textController.text;
    if (text.trim().isEmpty) return;

    final langCode = Localizations.localeOf(context).languageCode;
    ref.read(aiChatMessagesProvider.notifier).sendMessage(text, language: langCode);
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messages = ref.watch(aiChatMessagesProvider);
    final isLoading = ref.watch(aiIsLoadingProvider);
    final remainingTurns = ref.watch(remainingDailyTurnsProvider);
    final explainMore = ref.watch(aiExplainMoreProvider);
    final sessions = ref.watch(aiChatSessionsProvider);
    final activeId = ref.watch(activeSessionIdProvider);
    final activeSession = sessions.isNotEmpty
        ? sessions.firstWhere((s) => s.id == activeId, orElse: () => sessions.first)
        : null;
    final isPrivate = activeSession?.isPrivate ?? false;

    // Listen to pending context updates if navigating from Quran/Dua
    ref.listen<String?>(pendingAiQuestionContextProvider, (prev, next) {
      if (next != null && next.isNotEmpty) {
        _textController.text = next;
        _submitMessage();
        ref.read(pendingAiQuestionContextProvider.notifier).state = null;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.navAi,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Remaining daily turns pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flash_on, color: AppColors.gold, size: 13),
                const SizedBox(width: 3),
                Text(
                  '$remainingTurns/20',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          // Private mode toggle
          IconButton(
            key: const Key('chat_private_mode_button'),
            icon: Icon(
              isPrivate ? Icons.lock : Icons.lock_open_outlined,
              size: 20,
              color: isPrivate
                  ? AppColors.gold
                  : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
            ),
            tooltip: l10n.aiHistoryPrivateMode,
            onPressed: activeSession != null
                ? () {
                    ref
                        .read(aiChatSessionsProvider.notifier)
                        .togglePrivateMode(activeSession.id);
                  }
                : null,
          ),
          // Chat History button
          IconButton(
            key: const Key('chat_history_button'),
            icon: const Icon(Icons.history, size: 20),
            tooltip: l10n.aiHistoryTitle,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiChatHistoryScreen()),
              );
            },
          ),
          // New Chat button
          IconButton(
            key: const Key('chat_new_button'),
            icon: const Icon(Icons.add_comment_outlined, size: 20),
            tooltip: l10n.aiHistoryNewChat,
            onPressed: () async {
              await ref.read(aiChatSessionsProvider.notifier).startNewChat();
              ref.read(aiChatMessagesProvider.notifier).reloadFromSession();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode switch bar (Short Answer vs Explain More)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightNavyCard : AppColors.sandCardElevated,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.tune_rounded, size: 16, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          explainMore ? 'Deep Context Mode' : 'Concise Mode',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: explainMore,
                    activeThumbColor: AppColors.gold,
                    onChanged: (val) {
                      ref.read(aiExplainMoreProvider.notifier).state = val;
                    },
                  ),
                ),
              ],
            ),
          ),

          // Message List or Empty Starter View
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyStarterView(context, isDark, l10n)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && isLoading) {
                        return _buildLoadingBubble(isDark);
                      }
                      final msg = messages[index];
                      return _buildMessageBubble(context, msg, isDark);
                    },
                  ),
          ),

          // Chat input bar
          _buildInputBar(context, isDark, l10n, isLoading),
        ],
      ),
    );
  }

  Widget _buildEmptyStarterView(BuildContext context, bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.cardGradientDark : null,
              color: isDark ? null : AppColors.sandCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.gold,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Muslim AI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.goldLight : AppColors.midnightNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ask questions about Quran verses, authentic Hadith, classical Fiqh, and Duas with grounded citations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Suggested Inquiries',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildStarterChip(
            context,
            icon: Icons.access_time_filled,
            label: 'When is Asr prayer today?',
            onTap: () => _submitMessage('When is Asr prayer today?'),
            isDark: isDark,
          ),
          _buildStarterChip(
            context,
            icon: Icons.menu_book_rounded,
            label: 'Explain Ayat al-Kursi (2:255)',
            onTap: () => _submitMessage('Explain Ayat al-Kursi (2:255)'),
            isDark: isDark,
          ),
          _buildStarterChip(
            context,
            icon: Icons.favorite_rounded,
            label: 'Authentic morning adhkar & protection duas',
            onTap: () => _submitMessage('What are the authentic morning adhkar?'),
            isDark: isDark,
          ),
          _buildStarterChip(
            context,
            icon: Icons.explore_rounded,
            label: 'Which direction is Qibla from here?',
            onTap: () => _submitMessage('Which direction is the Qibla from my location?'),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStarterChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final isUser = msg.sender == ChatSender.user;

    final bubble = Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.gold.withValues(alpha: 0.2)
              : isDark
                  ? AppColors.midnightNavyCard
                  : AppColors.sandCardElevated,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser
                ? AppColors.gold.withValues(alpha: 0.5)
                : isDark
                    ? AppColors.midnightNavyBorder
                    : AppColors.sandBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header tag for system/device or cached response
            if (!isUser) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (msg.isFromDeviceIntent) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt, size: 12, color: AppColors.gold),
                          SizedBox(width: 2),
                          Text(
                            'On-Device M1/M2 Intent',
                            style: TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (msg.isCached) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Verified Grounded Corpus',
                        style: TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              if (msg.isFromDeviceIntent || msg.isCached) const SizedBox(height: 8),
            ],

            // Content text
            if (isUser)
              Text(
                msg.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              )
            else
              MarkdownBody(
                data: msg.text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                  em: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                  blockquote: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? AppColors.goldLight : AppColors.midnightNavy,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: const Border(
                      left: BorderSide(color: AppColors.gold, width: 3),
                    ),
                  ),
                  code: TextStyle(
                    fontSize: 12,
                    color: AppColors.goldLight,
                    backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBorder,
                  ),
                ),
              ),

            // Citations and sources
            if (msg.sources.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, size: 12, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          'Verified Sources (${msg.sources.length}):',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...msg.sources.map(
                      (src) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '• $src',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Scholar disclaimer footer if query required
            if (msg.scholarFooter != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 13, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        msg.scholarFooter!,
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.3,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Part A Trust Upgrades: Source Indicator & Feedback Chips for Assistant Answers
            if (!isUser) ...[
              const SizedBox(height: 10),
              // Source-Support Indicator Pill
              Container(
                key: const Key('source_support_indicator'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: msg.sources.isNotEmpty
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: msg.sources.isNotEmpty
                        ? AppColors.gold.withValues(alpha: 0.5)
                        : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      msg.sources.isNotEmpty ? Icons.verified_user_outlined : Icons.help_outline_rounded,
                      size: 12,
                      color: msg.sources.isNotEmpty
                          ? AppColors.gold
                          : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        msg.sources.isNotEmpty
                            ? l10n.aiSupportedSources(msg.sources.length)
                            : l10n.aiNoVerifiedSources,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: msg.sources.isNotEmpty
                              ? AppColors.gold
                              : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Feedback row chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildFeedbackChip(
                    context,
                    key: Key('feedback_helpful_${msg.id}'),
                    icon: Icons.thumb_up_alt_outlined,
                    label: l10n.aiFeedbackHelpful,
                    onTap: () => _handleFeedback(msg, 'helpful'),
                    isDark: isDark,
                  ),
                  _buildFeedbackChip(
                    context,
                    key: Key('feedback_wrong_citation_${msg.id}'),
                    icon: Icons.bookmark_border,
                    label: l10n.aiFeedbackWrongCitation,
                    onTap: () => _handleFeedback(msg, 'wrong_citation'),
                    isDark: isDark,
                  ),
                  _buildFeedbackChip(
                    context,
                    key: Key('feedback_report_error_${msg.id}'),
                    icon: Icons.flag_outlined,
                    label: l10n.aiFeedbackReportError,
                    onTap: () => _showReportReligiousErrorDialog(msg),
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    if (!isUser && (msg.matchedScholarReferral || msg.referralQuestionText != null)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildScholarReferralCard(context, msg, isDark),
          bubble,
        ],
      );
    }

    return bubble;
  }

  Widget _buildScholarReferralCard(
    BuildContext context,
    ChatMessage msg,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        key: Key('scholar_referral_card_${msg.id}'),
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.midnightNavyCardElevated : AppColors.sandCardElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school_outlined, color: AppColors.gold, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.scholarReferralTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.scholarReferralBody,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.35,
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                key: Key('copy_question_button_${msg.id}'),
                onTap: () {
                  final textToCopy = msg.referralQuestionText ?? '';
                  if (textToCopy.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.scholarQuestionCopied),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy_outlined, size: 12, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        l10n.scholarCopyQuestion,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackChip(
    BuildContext context, {
    Key? key,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.gold),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFeedback(ChatMessage msg, String type) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await ref.read(aiFeedbackServiceProvider).sendFeedback(
      queryHash: msg.id,
      feedbackType: type,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l10n.aiFeedbackSentToast : l10n.aiFeedbackErrorToast),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showReportReligiousErrorDialog(ChatMessage msg) {
    final l10n = AppLocalizations.of(context)!;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.flag_outlined, color: AppColors.gold, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.aiReportDialogTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('report_comment_field'),
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.aiReportCommentHint,
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n.aiReportCancel),
          ),
          ElevatedButton(
            key: const Key('submit_report_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.midnightNavy,
            ),
            onPressed: () async {
              final comment = commentController.text;
              Navigator.of(dialogCtx).pop();

              final success = await ref.read(aiFeedbackServiceProvider).sendFeedback(
                queryHash: msg.id,
                feedbackType: 'religious_error',
                comment: comment,
              );

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? l10n.aiFeedbackSentToast : l10n.aiFeedbackErrorToast),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Text(l10n.aiReportSubmit),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.midnightNavyCard : AppColors.sandCardElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
            ),
            const SizedBox(width: 8),
            Text(
              'Grounded retrieval in progress...',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    bool isLoading,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyDark : AppColors.sandCard,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyCard : AppColors.sandBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitMessage(),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask about Quran, Hadith, Fiqh...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.midnightNavyDark),
                      )
                    : const Icon(Icons.arrow_upward, color: AppColors.midnightNavyDark),
                onPressed: isLoading ? null : () => _submitMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
