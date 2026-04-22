import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  Map<String, String> _usernames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    _fetchMessages();
    _setupRealtime();
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      final msgData = await supabase
   .from('messages')
   .select()
   .order('created_at', ascending: false)
   .limit(50);

      final messages = List<Map<String, dynamic>>.from(msgData).reversed.toList();

      final userIds = messages.map((m) => m['user_id'] as String).toSet().toList();
      if (userIds.isNotEmpty) {
        final profileData = await supabase
     .from('profiles')
     .select('id, username')
     .inFilter('id', userIds);

        for (var profile in profileData) {
          _usernames[profile['id']] = profile['username']?? 'مجهول';
        }
      }

      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _setupRealtime() {
    supabase
 .channel('public:messages')
 .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) async {
            final newMsg = payload.newRecord;
            if (!_usernames.containsKey(newMsg['user_id'])) {
              final profile = await supabase
           .from('profiles')
           .select('username')
           .eq('id', newMsg['user_id'])
           .single();
              _usernames[newMsg['user_id']] = profile['username']?? 'مجهول';
            }
            setState(() => _messages.add(newMsg));
            _scrollToBottom();
          },
        )
 .subscribe();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    try {
      await supabase.from('messages').insert({
        'content': text,
        'user_id': supabase.auth.currentUser!.id,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل الارسال'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    supabase.removeAllChannels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = supabase.auth.currentUser!.id;
    return Scaffold(
      appBar: AppBar(title: const Text('الدردشة العامة')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
         ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMine = msg['user_id'] == currentUserId;
                      final username = _usernames[msg['user_id']]?? 'مجهول';
                      final time = timeago.format(DateTime.parse(msg['created_at']), locale: 'ar');

                      return Align(
                        alignment: isMine? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMine? const Color(0xFF6A1B9A) : Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMine)
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.amber,
                                  ),
                                ),
                              Text(msg['content']),
                              const SizedBox(height: 4),
                              Text(
                                time,
                                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: const Color(0xFF6A1B9A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
