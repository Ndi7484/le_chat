import 'dart:async';
import 'package:flutter/material.dart';
import 'package:le_chat/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.username, this.receiver});

  final String username;
  final String? receiver;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _users = [];
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;

  @override
  void initState() {
    super.initState();

    _messageSubscription = Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .listen((data) {
          if (mounted) {
            setState(() {
              _messages
                ..clear()
                ..addAll(
                  data.where((msg) {
                    if (widget.receiver == null) {
                      return msg['receiver'] == widget.receiver; // group chat
                    }
                    return (msg['sender'] == widget.username &&
                            msg['receiver'] == widget.receiver) ||
                        (msg['sender'] == widget.receiver &&
                            msg['receiver'] == widget.username); // private chat
                  }),
                );
            });
          }
        });

    // Scroll to bottom after messages update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    _loadUsers();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel(); // stop listening
    _controller.dispose(); // clean up text controller
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final client = Supabase.instance.client;
    final data = await client.from('users').select();
    setState(() {
      _users.clear();
      _users.addAll(List<Map<String, dynamic>>.from(data));
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await Supabase.instance.client.from('messages').insert({
      'sender': widget.username,
      'receiver': widget.receiver,
      'content': text,
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerChat(users: _users, username: widget.username),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chat: ${widget.receiver ?? 'Everyone\'s Group'}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              "Your username : ${widget.username}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final client = Supabase.instance.client;
              // Delete the user from the users table
              await client
                  .from('users')
                  .delete()
                  .eq('username', widget.username);
              // Delete all messages from this user
              await client
                  .from('messages')
                  .delete()
                  .eq('sender', widget.username);
              // Navigate back to LoginPage
              if (mounted) {
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 30),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.onSecondary,
              child: ListView(
                controller: _scrollController,
                children: [
                  SizedBox(height: 4),
                  ..._messages.map((msg) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          (msg['sender'] == widget.username)
                              ? Expanded(flex: 1, child: Container())
                              : Container(),
                          Expanded(
                            flex: 4,
                            child: Container(
                              color: (msg['sender'] == widget.username)
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.secondary,
                              child: ListTile(
                                leading: (msg['sender'] == widget.username)
                                    ? null
                                    : CircleAvatar(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        child: Icon(
                                          Icons.person_pin_rounded,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          size: 28,
                                        ),
                                      ),
                                title: (msg['sender'] == widget.username)
                                    ? Text(
                                        "You",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        "${msg['sender']}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                subtitle: Text(
                                  "${msg['content']}",
                                  style: TextStyle(
                                    color: (msg['sender'] == widget.username)
                                        ? null
                                        : Colors.white,
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: (msg['sender'] == widget.username)
                                    ? CircleAvatar(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                        child: Icon(
                                          Icons.person,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          size: 28,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          !(msg['sender'] == widget.username)
                              ? Expanded(flex: 1, child: Container())
                              : Container(),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 4),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller)),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerChat extends StatelessWidget {
  const DrawerChat({super.key, required this.users, required this.username});

  final List<Map<String, dynamic>> users;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Chat Users',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          // Everyone's Group
          ListTile(
            leading: Icon(Icons.group),
            title: Text("Everyone's Group"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    username: username,
                    receiver: null, // null means group chat
                  ),
                ),
              );
            },
          ),
          Divider(),
          // Dynamic list of users
          ...users.map((user) {
            return ListTile(
              leading: Icon(Icons.person),
              title: Text(user['username']),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      username: username,
                      receiver: user['username'],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
