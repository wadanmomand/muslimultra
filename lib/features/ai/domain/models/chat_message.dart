enum ChatSender { user, assistant, system }

class ChatCitation {
  final String reference; // e.g. "Quran 2:152" or "Sahih al-Bukhari 54"
  final String? arabic;
  final String? translation;

  const ChatCitation({
    required this.reference,
    this.arabic,
    this.translation,
  });

  Map<String, dynamic> toJson() => {
        'reference': reference,
        if (arabic != null) 'arabic': arabic,
        if (translation != null) 'translation': translation,
      };

  factory ChatCitation.fromJson(Map<String, dynamic> json) => ChatCitation(
        reference: json['reference'] as String,
        arabic: json['arabic'] as String?,
        translation: json['translation'] as String?,
      );
}

class ChatMessage {
  final String id;
  final String text;
  final ChatSender sender;
  final DateTime timestamp;
  final List<String> sources;
  final bool isFromDeviceIntent;
  final bool isCached;
  final bool isShortAnswer;
  final String? scholarFooter;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.sources = const [],
    this.isFromDeviceIntent = false,
    this.isCached = false,
    this.isShortAnswer = true,
    this.scholarFooter,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    ChatSender? sender,
    DateTime? timestamp,
    List<String>? sources,
    bool? isFromDeviceIntent,
    bool? isCached,
    bool? isShortAnswer,
    String? scholarFooter,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      sources: sources ?? this.sources,
      isFromDeviceIntent: isFromDeviceIntent ?? this.isFromDeviceIntent,
      isCached: isCached ?? this.isCached,
      isShortAnswer: isShortAnswer ?? this.isShortAnswer,
      scholarFooter: scholarFooter ?? this.scholarFooter,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'sender': sender.name,
        'timestamp': timestamp.toIso8601String(),
        'sources': sources,
        'isFromDeviceIntent': isFromDeviceIntent,
        'isCached': isCached,
        'isShortAnswer': isShortAnswer,
        'scholarFooter': scholarFooter,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        sender: ChatSender.values.firstWhere(
          (e) => e.name == json['sender'],
          orElse: () => ChatSender.user,
        ),
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
        sources: (json['sources'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        isFromDeviceIntent: json['isFromDeviceIntent'] as bool? ?? false,
        isCached: json['isCached'] as bool? ?? false,
        isShortAnswer: json['isShortAnswer'] as bool? ?? true,
        scholarFooter: json['scholarFooter'] as String?,
      );
}
