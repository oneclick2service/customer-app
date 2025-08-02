import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_text_field.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isFromUser;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isFromUser,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String _providerName = 'Service Provider';

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    // TODO: Load chat history from Supabase Realtime
    // For now, use mock data
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _messages = [
        ChatMessage(
          id: '1',
          senderId: 'provider',
          senderName: 'Rajesh Kumar',
          message: 'Hello! I\'m on my way to your location. I should arrive in about 15 minutes.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isFromUser: false,
        ),
        ChatMessage(
          id: '2',
          senderId: 'user',
          senderName: 'You',
          message: 'Great! I\'ll be waiting. Please call when you arrive.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          isFromUser: true,
        ),
        ChatMessage(
          id: '3',
          senderId: 'provider',
          senderName: 'Rajesh Kumar',
          message: 'Sure, I\'ll call you when I reach. Is there anything specific I should know about the service?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
          isFromUser: false,
        ),
        ChatMessage(
          id: '4',
          senderId: 'user',
          senderName: 'You',
          message: 'Yes, the tap in the kitchen is leaking. I\'ve already turned off the main water supply.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          isFromUser: true,
        ),
        ChatMessage(
          id: '5',
          senderId: 'provider',
          senderName: 'Rajesh Kumar',
          message: 'Perfect! I have the necessary tools and parts. I\'ll fix it right away when I arrive.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          isFromUser: false,
        ),
      ];
      _isLoading = false;
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'user',
      senderName: 'You',
      message: message,
      timestamp: DateTime.now(),
      isFromUser: true,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    // TODO: Send message to Supabase Realtime
    _simulateProviderResponse();
  }

  void _simulateProviderResponse() {
    // Simulate provider response after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final response = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'provider',
          senderName: _providerName,
          message: 'Message received. I\'ll respond shortly.',
          timestamp: DateTime.now(),
          isFromUser: false,
        );

        setState(() {
          _messages.add(response);
        });
        _scrollToBottom();
      }
    });
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppConstants.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _providerName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Call provider
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Calling provider...'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.call,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Messages
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Messages List
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _messages.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No messages yet',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(20),
                                    itemCount: _messages.length,
                                    itemBuilder: (context, index) {
                                      final message = _messages[index];
                                      return _buildMessageBubble(message);
                                    },
                                  ),
                      ),

                      // Message Input
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _messageController,
                                hintText: 'Type your message...',
                                maxLines: 1,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: IconButton(
                                onPressed: _sendMessage,
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isFromUser = message.isFromUser;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromUser) ...[
            // Provider avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: AppConstants.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromUser
                    ? AppConstants.primaryColor
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isFromUser ? const Radius.circular(20) : const Radius.circular(5),
                  bottomRight: isFromUser ? const Radius.circular(5) : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isFromUser) ...[
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isFromUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Time
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 