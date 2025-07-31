import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/message.dart';
import '../../services/openrouter_service.dart';
import '../../providers/theme_provider.dart';

class ChatScreen extends StatefulWidget {
  final String? courseContext;
  final String? courseTitle;
  final String? initialPrompt;

  const ChatScreen({
    super.key,
    this.courseContext,
    this.courseTitle,
    this.initialPrompt,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late OpenRouterService _openRouterService;
  bool _isLoading = false;
  late AnimationController _typingAnimationController;
  String _error = '';
  bool _isTypingResponse = false;

  @override
  void initState() {
    super.initState();
    try {
      _openRouterService = OpenRouterService();
    } catch (e) {
      setState(() {
        _error =
            'API configuration error. Please check your .env file and ensure OPENROUTER_API_KEY is set.';
      });
    }

    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _addWelcomeMessage();

    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _textController.text = widget.initialPrompt!;
        _sendMessage();
      });
    }
  }

  void _addWelcomeMessage() {
    String welcomeMessage;

    if (widget.courseContext != null && widget.courseTitle != null) {
      welcomeMessage =
          '''Hi there! I'm ShieldAi, here to help you with "${widget.courseTitle}".

I can assist you with:
• Course questions and explanations
• Security concepts and examples  
• Best practices and recommendations
• Real-world scenarios and applications

What would you like to know about this course?''';
    } else {
      welcomeMessage = '''Hello! I'm ShieldAi, your cybersecurity companion! 👋

I'm here to help you learn cybersecurity. Ask me about:
• Security threats and protection
• Safe online practices
• Incident response
• Network security basics
• Malware prevention

What would you like to learn about today?''';
    }

    _messages.add(
      Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: welcomeMessage,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  // Simplified message content builder - clean text formatting
  Widget _buildMessageContent(String content, bool isDark) {
    return _buildCleanText(content, isDark);
  }

  Widget _buildCleanText(String text, bool isDark) {
    final List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }

      // Handle bullet points (•)
      if (line.startsWith('• ')) {
        spans.add(
          TextSpan(
            text: '$line\n',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        );
      }
      // Handle numbered lists
      else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        spans.add(
          TextSpan(
            text: '$line\n',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }
      // Handle links
      else if (line.contains('http')) {
        _parseLinks(line, spans, isDark);
        if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
      }
      // Check if line looks like a heading (all caps or ends with :)
      else if (line.toUpperCase() == line &&
          line.length > 3 &&
          line.length < 50) {
        spans.add(
          TextSpan(
            text: '$line\n',
            style: TextStyle(
              color: Colors.teal.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        );
      }
      // Check if line ends with : (like a section header)
      else if (line.endsWith(':') && line.length < 50) {
        spans.add(
          TextSpan(
            text: '$line\n',
            style: TextStyle(
              color: Colors.teal.shade600,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        );
      }
      // Regular text
      else {
        spans.add(
          TextSpan(
            text: line + (i < lines.length - 1 ? '\n' : ''),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  void _parseLinks(String line, List<TextSpan> spans, bool isDark) {
    final linkRegex = RegExp(r'https?://[^\s]+');
    int lastEnd = 0;

    for (final match in linkRegex.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: line.substring(lastEnd, match.start),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        );
      }

      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: TextStyle(
            color: Colors.teal.shade600,
            fontSize: 15,
            height: 1.5,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w500,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(url),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      spans.add(
        TextSpan(
          text: line.substring(lastEnd),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      );
    }
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal.shade600,
            radius: 18,
            child: const Icon(Icons.security, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isTypingResponse
                      ? 'ShieldAi is responding'
                      : 'ShieldAi is thinking',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: AnimatedBuilder(
                    animation: _typingAnimationController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: TypingIndicatorPainter(
                          _typingAnimationController.value,
                          Colors.teal.shade600,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Determine response length for appropriate timing
  bool _isShortResponse(String response) {
    final words = response.split(' ').length;
    final lines = response.split('\n').length;

    // Short responses: greetings, thanks, simple answers
    return words < 20 || (lines < 3 && words < 30);
  }

  Future<void> _simulateTyping(String fullResponse) async {
    setState(() {
      _isTypingResponse = false;
    });

    // Adjust thinking time based on response length
    int thinkingTime;
    if (_isShortResponse(fullResponse)) {
      thinkingTime = 800; // Short thinking for simple responses
    } else {
      thinkingTime =
          1500 + (fullResponse.length ~/ 15); // Longer for complex responses
    }

    await Future.delayed(Duration(milliseconds: thinkingTime));

    setState(() {
      _isTypingResponse = true;
    });

    // Brief response phase
    await Future.delayed(const Duration(milliseconds: 500));

    final assistantMessage = Message(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      role: 'assistant',
      content: fullResponse,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(assistantMessage);
      _isLoading = false;
      _isTypingResponse = false;
    });

    _typingAnimationController.stop();
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty || _error.isNotEmpty) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: _textController.text.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _isTypingResponse = false;
    });

    _textController.clear();
    _scrollToBottom();
    _typingAnimationController.repeat();

    try {
      final response = await _openRouterService.sendMessage(_messages);
      await _simulateTyping(response);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isTypingResponse = false;
      });

      _typingAnimationController.stop();

      String errorMessage;
      Color errorColor = Colors.red;

      if (e.toString().contains('timeout') || e.toString().contains('408')) {
        errorMessage =
            '⏱️ Request timed out. The AI is taking longer than usual to respond.';
        errorColor = Colors.orange;
      } else if (e.toString().contains('Rate limit')) {
        errorMessage =
            '🚦 Too many requests. Please wait a moment before trying again.';
        errorColor = Colors.amber;
      } else if (e.toString().contains('internet') ||
          e.toString().contains('connection')) {
        errorMessage =
            '🌐 Connection issue. Please check your internet and try again.';
        errorColor = Colors.blue;
      } else {
        errorMessage = '❌ ${e.toString().replaceAll('Exception: ', '')}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: errorColor,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              if (_messages.isNotEmpty && _messages.last.role == 'user') {
                _textController.text = _messages.last.content;
                setState(() {
                  _messages.removeLast();
                });
              }
            },
          ),
        ),
      );
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _addWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeData.brightness == Brightness.dark;

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ShieldAi'),
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Configuration Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.security, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.courseTitle != null
                    ? 'ShieldAi - ${widget.courseTitle}'
                    : 'ShieldAi',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _clearChat,
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator(isDark);
                }

                final message = _messages[index];
                final isUser = message.role == 'user';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment:
                        isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          backgroundColor: Colors.teal.shade600,
                          radius: 18,
                          child: const Icon(
                            Icons.security,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isUser
                                    ? Colors.teal.shade600
                                    : (isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[100]),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isUser
                                  ? Text(
                                    message.content,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  )
                                  : _buildMessageContent(
                                    message.content,
                                    isDark,
                                  ),
                              const SizedBox(height: 8),
                              Text(
                                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color:
                                      isUser
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.grey[500],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundColor: Colors.teal.shade600,
                          radius: 18,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText:
                            widget.courseContext != null
                                ? 'Ask about ${widget.courseTitle}...'
                                : 'Ask ShieldAi about cybersecurity...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        prefixIcon: Icon(
                          Icons.security_rounded,
                          color: Colors.teal.shade600,
                          size: 18,
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal.shade600,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicatorPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  TypingIndicatorPainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final dotRadius = size.width / 8;
    final spacing = size.width / 4;

    for (int i = 0; i < 3; i++) {
      final x = spacing + (i * spacing);
      final y = size.height / 2;

      final phase = (animationValue * 3 - i) % 3;
      final opacity = phase < 1 ? phase : (phase < 2 ? 1 : 3 - phase);

      paint.color = color.withOpacity(opacity.clamp(0.3, 1.0).toDouble());
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
