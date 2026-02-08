import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../constants/colors.dart';

class ChatbotScreen extends StatefulWidget {
  final String landmarkName;
  final String landmarkDescription;
  final String? initialQuestion;

  const ChatbotScreen({
    super.key,
    required this.landmarkName,
    required this.landmarkDescription,
    this.initialQuestion,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  List<String> _suggestedQuestions = [];
  bool _isLoading = false;

  // ===== Match Login typography/colors =====
  static const Color _titleColor = Color(0xFF363E44);
  static const Color _muted = Color(0xFF9CA3AF);

  static const TextStyle _appBarTitleTilt = TextStyle(
    fontFamily: 'Tilt Warp',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black,
    height: 1.2,
  );

  static const TextStyle _appBarSubtitleComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black54,
    height: 1.2,
  );

  static const TextStyle _emptyStateComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _muted,
    height: 1.33,
  );

  static const TextStyle _bubbleTextComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle _suggestLabelComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle _suggestChipComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle _inputTextComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: _titleColor,
  );

  static const TextStyle _hintTextComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: Colors.grey,
  );

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestion != null && widget.initialQuestion!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialQuestion!);
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: userMessage));
      _isLoading = true;
      _suggestedQuestions = [];
    });

    _scrollToBottom();

    try {
      final chatResponse = await _chatService.sendMessage(
        landmarkName: widget.landmarkName,
        landmarkInfo: widget.landmarkDescription,
        conversationHistory: _messages,
        userMessage: userMessage,
      );

      setState(() {
        _messages.add(
          ChatMessage(role: 'assistant', content: chatResponse.response),
        );
        _suggestedQuestions = chatResponse.suggestedQuestions;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            role: 'assistant',
            content: 'Sorry, I encountered an error. Please try again.',
          ),
        );
        _suggestedQuestions = [];
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.topBarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat', style: _appBarTitleTilt),
            Text(widget.landmarkName, style: _appBarSubtitleComfortaa),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ask me anything about\n${widget.landmarkName}',
                          textAlign: TextAlign.center,
                          style: _emptyStateComfortaa.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message.role == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFF1F8A70)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message.content,
                            style: _bubbleTextComfortaa.copyWith(
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF1F8A70),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (!_isLoading && _suggestedQuestions.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested questions:',
                    style: _suggestLabelComfortaa.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedQuestions.map((question) {
                      return InkWell(
                        onTap: () => _sendMessage(question),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F8A70).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  const Color(0xFF1F8A70).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            question,
                            style: _suggestChipComfortaa.copyWith(
                              color: const Color(0xFF1F8A70),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      hintStyle: _hintTextComfortaa,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    style: _inputTextComfortaa,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (text) => _sendMessage(text),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F8A70),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () =>
                        _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
