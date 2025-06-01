import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Private Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF181818),
        cardColor: const Color(0xFF232323),
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: const Color(0xFF232323),
          onSurface: Colors.grey[200]!,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: _themeMode,
      home: UsernameSignInScreen(onToggleTheme: _toggleTheme),
    );
  }
}

class UsernameSignInScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const UsernameSignInScreen({super.key, required this.onToggleTheme});
  @override
  State<UsernameSignInScreen> createState() => _UsernameSignInScreenState();
}

class _UsernameSignInScreenState extends State<UsernameSignInScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> _signIn() async {
    final username = _controller.text.trim();
    if (username.isEmpty) return;
    setState(() => _loading = true);

    final userCred = await FirebaseAuth.instance.signInAnonymously();
    final uid = userCred.user!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'username': username,
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserListScreen(
            currentUid: uid,
            currentUsername: username,
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter a username",
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _signIn(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _signIn,
                child: _loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserListScreen extends StatelessWidget {
  final String currentUid;
  final String currentUsername;
  final VoidCallback onToggleTheme;
  const UserListScreen({
    super.key,
    required this.currentUid,
    required this.currentUsername,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!.docs.where((doc) => doc['uid'] != currentUid).toList();
          if (users.isEmpty) {
            return const Center(child: Text("No other users yet."));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: avatarColorFromName(user['username']),
                  child: Text(user['username'][0].toUpperCase()),
                ),
                title: Text(user['username'], style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrivateChatScreen(
                        currentUid: currentUid,
                        currentUsername: currentUsername,
                        peerUid: user['uid'],
                        peerName: user['username'],
                        onToggleTheme: onToggleTheme,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

Color avatarColorFromName(String name) {
  final hash = name.codeUnits.fold(0, (p, c) => p + c);
  final colors = [Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple, Colors.teal];
  return colors[hash % colors.length];
}

String getChatRoomId(String uid1, String uid2) {
  final ids = [uid1, uid2]..sort();
  return ids.join('_');
}

class PrivateChatScreen extends StatefulWidget {
  final String currentUid;
  final String currentUsername;
  final String peerUid;
  final String peerName;
  final VoidCallback onToggleTheme;
  const PrivateChatScreen({
    super.key,
    required this.currentUid,
    required this.currentUsername,
    required this.peerUid,
    required this.peerName,
    required this.onToggleTheme,
  });

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  static const int pageSize = 20;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> _olderMessages = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  bool _initialLoadDone = false;
  bool _isAtBottom = true;

  Timer? _typingTimer;
  bool _isTyping = false;

  late final String chatRoomId;

  @override
  void initState() {
    super.initState();
    chatRoomId = getChatRoomId(widget.currentUid, widget.peerUid);
    FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId).set({
      'users': [widget.currentUid, widget.peerUid],
    }, SetOptions(merge: true));
    _loadOlderMessages();
    _scrollController.addListener(_onScroll);
    _updateTypingStatus(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _updateTypingStatus(false);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        _hasMore) {
      _loadOlderMessages();
    }
    setState(() {
      _isAtBottom = _scrollController.position.pixels <= 50;
    });
  }

  Future<void> _loadOlderMessages() async {
    if (!_hasMore) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limit(pageSize);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot snapshot = await query.get();

    setState(() {
      if (snapshot.docs.isNotEmpty) {
        _olderMessages.insertAll(0, snapshot.docs);
        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length == pageSize;
      } else {
        _hasMore = false;
      }
      _isLoading = false;
      _initialLoadDone = true;
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': widget.currentUid,
      'senderName': widget.currentUsername,
      'receiverId': widget.peerUid,
      'receiverName': widget.peerName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'seenBy': [widget.currentUid],
      'reactions': {},
      'edited': false,
    });
    _controller.clear();
    _updateTypingStatus(false);
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _clearInput() {
    _controller.clear();
    setState(() {});
    _updateTypingStatus(false);
  }

  void _updateTypingStatus(bool isTyping) async {
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('typing')
        .doc(widget.currentUid)
        .set({
      'userName': widget.currentUsername,
      'isTyping': isTyping,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<String>> _otherUserTypingStream() {
    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('typing')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .where((doc) =>
    doc.id != widget.currentUid &&
        doc.data()['isTyping'] == true)
        .map((doc) => doc.data()['userName'] as String? ?? "Someone")
        .toList());
  }

  Future<void> _markMessagesAsSeen(List<DocumentSnapshot> messages) async {
    for (var doc in messages) {
      final data = doc.data() as Map<String, dynamic>;
      final seenBy = List<String>.from(data['seenBy'] ?? []);
      if (data['senderId'] != widget.currentUid && !seenBy.contains(widget.currentUid)) {
        await doc.reference.update({
          'seenBy': FieldValue.arrayUnion([widget.currentUid])
        });
      }
    }
  }

  void _addReaction(String messageId, String emoji, Map<String, dynamic> reactions) async {
    final List<dynamic> users = reactions[emoji] ?? [];
    if (users.contains(widget.currentUid)) {
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reactions.$emoji': FieldValue.arrayRemove([widget.currentUid])
      });
    } else {
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reactions.$emoji': FieldValue.arrayUnion([widget.currentUid])
      });
    }
  }

  void _deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  void _editMessage(String messageId, String oldText) async {
    final controller = TextEditingController(text: oldText);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Message'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != oldText) {
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'text': result, 'edited': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: avatarColorFromName(widget.peerName),
              child: Text(widget.peerName[0].toUpperCase()),
            ),
            const SizedBox(width: 8),
            Text(widget.peerName, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<List<String>>(
            stream: _otherUserTypingStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final names = snapshot.data!;
                return TypingIndicatorWidget(names: names);
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: !_initialLoadDone
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(pageSize)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _olderMessages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final latestMessages =
                    snapshot.data?.docs.reversed.toList() ?? [];

                final allMessages = [
                  ..._olderMessages,
                  ...latestMessages
                ];

                _markMessagesAsSeen(allMessages);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_isAtBottom &&
                      _scrollController.hasClients &&
                      allMessages.isNotEmpty) {
                    _scrollController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                int lastSentByMeIndex = -1;
                for (int i = allMessages.length - 1; i >= 0; i--) {
                  final data = allMessages[i].data() as Map<String, dynamic>;
                  if (data['senderId'] == widget.currentUid) {
                    lastSentByMeIndex = i;
                    break;
                  }
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: allMessages.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_hasMore && index == allMessages.length) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final doc = allMessages[allMessages.length - 1 - index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == widget.currentUid;
                    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                    final isLastSentByMe =
                        (allMessages.length - 1 - index) == lastSentByMeIndex && isMe;
                    final seenBy = List<String>.from(data['seenBy'] ?? []);
                    final isSeen = isMe && seenBy.length > 1;
                    final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
                    final messageId = doc.id;
                    final edited = data['edited'] == true;

                    // Grouping: show avatar and name only for first in group
                    final showAvatarAndName = index == allMessages.length - 1 ||
                        (allMessages[allMessages.length - index - 2].data() as Map<String, dynamic>)['senderId'] != data['senderId'];

                    return GestureDetector(
                      onLongPress: () async {
                        if (isMe) {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.edit),
                                    title: const Text('Edit'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _editMessage(messageId, data['text'] ?? '');
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: const Text('Delete'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _deleteMessage(messageId);
                                    },
                                  ),
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: ['👍', '❤️', '😂', '😮', '😢'].map((emoji) {
                                        return IconButton(
                                          icon: Text(emoji, style: const TextStyle(fontSize: 24)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _addReaction(messageId, emoji, reactions);
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: ['👍', '❤️', '😂', '😮', '😢'].map((emoji) {
                                    return IconButton(
                                      icon: Text(emoji, style: const TextStyle(fontSize: 24)),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _addReaction(messageId, emoji, reactions);
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: ChatBubble(
                        text: data['text'] ?? '',
                        isSentByMe: isMe,
                        senderName: isMe ? widget.currentUsername : widget.peerName,
                        timestamp: timestamp,
                        isLastSentByMe: isLastSentByMe,
                        isSeen: isSeen,
                        reactions: reactions,
                        edited: edited,
                        showAvatarAndName: showAvatarAndName,
                        avatarColor: avatarColorFromName(data['senderName'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.all(8),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearInput,
                      )
                          : null,
                    ),
                    onChanged: (text) {
                      setState(() {});
                      if (!_isTyping) {
                        _updateTypingStatus(true);
                      }
                      _typingTimer?.cancel();
                      _typingTimer = Timer(const Duration(seconds: 2), () {
                        _updateTypingStatus(false);
                      });
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                Material(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Colors.white),
                    onPressed: _controller.text.trim().isEmpty ? null : _sendMessage,
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

class TypingIndicatorWidget extends StatelessWidget {
  final List<String> names;
  const TypingIndicatorWidget({super.key, required this.names});

  @override
  Widget build(BuildContext context) {
    String text = names.length == 1
        ? "${names.first} is typing..."
        : "${names.join(', ')} are typing...";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const SpinKitThreeBounce(
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSentByMe;
  final String senderName;
  final DateTime? timestamp;
  final bool isLastSentByMe;
  final bool isSeen;
  final Map<String, dynamic>? reactions;
  final bool edited;
  final bool showAvatarAndName;
  final Color avatarColor;
  const ChatBubble({
    required this.text,
    required this.isSentByMe,
    required this.senderName,
    this.timestamp,
    this.isLastSentByMe = false,
    this.isSeen = false,
    this.reactions,
    this.edited = false,
    this.showAvatarAndName = true,
    this.avatarColor = Colors.blue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final bubbleColor = isSentByMe
        ? Colors.blue
        : (isDark ? const Color(0xFF232323) : Colors.grey[200]!);
    final textColor = isSentByMe
        ? Colors.white
        : (isDark ? Colors.grey[200]! : Colors.black87);

    final initials = senderName.isNotEmpty
        ? senderName.trim()[0].toUpperCase()
        : "?";

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Row(
          mainAxisAlignment:
          isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSentByMe && showAvatarAndName)
              CircleAvatar(
                backgroundColor: avatarColor,
                radius: 16,
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            if (!isSentByMe && showAvatarAndName)
              const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                minWidth: 48,
              ),
              child: Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (showAvatarAndName)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 2),
                      child: Text(
                        senderName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSentByMe ? Colors.blue[100] : Colors.grey[700],
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isSentByMe ? 18 : 4),
                        bottomRight: Radius.circular(isSentByMe ? 4 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.09),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isSentByMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                text,
                                style: GoogleFonts.inter(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (edited)
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  '(edited)',
                                  style: TextStyle(fontSize: 10, color: Colors.grey[300]),
                                ),
                              ),
                          ],
                        ),
                        if (reactions != null && reactions!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Wrap(
                              spacing: 8,
                              children: reactions!.entries
                                  .where((e) => (e.value as List).isNotEmpty)
                                  .map((e) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${e.key} ${(e.value as List).length}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (timestamp != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, top: 2),
                      child: Text(
                        DateFormat('hh:mm a').format(timestamp!),
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  if (isSentByMe && isLastSentByMe)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSeen ? Icons.done_all : Icons.done,
                            size: 16,
                            color: isSeen ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSeen ? "Seen" : "Delivered",
                            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (isSentByMe && showAvatarAndName)
              const SizedBox(width: 8),
            if (isSentByMe && showAvatarAndName)
              CircleAvatar(
                backgroundColor: avatarColor,
                radius: 16,
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
