import 'dart:async';
import 'package:flutter/material.dart';
import 'package:le_chat/chat_page.dart';
import 'package:le_chat/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

class ChatPrivatePage extends StatefulWidget {
  const ChatPrivatePage({
    super.key,
    required this.currentUser,
    required this.receiver,
  });

  final String currentUser;
  final String receiver;
  @override
  State<ChatPrivatePage> createState() => _ChatPrivatePageState();
}

class _ChatPrivatePageState extends State<ChatPrivatePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _users = [];

  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;

  @override
  void initState() {
    super.initState();

    _messageSubscription = Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen((data) {
          if (mounted) {
            setState(() {
              _messages
                ..clear()
                ..addAll(
                  data.where((msg) {
                    // Private chat: only messages between username and receiver
                    return (msg['sender'] == widget.currentUser &&
                            msg['receiver'] == widget.receiver) ||
                        (msg['sender'] == widget.receiver &&
                            msg['receiver'] == widget.currentUser);
                  }),
                );
            });
          }
        });

    _loadUsers();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel(); // stop listening
    _controller.dispose(); // clean up text controller
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
      'sender': widget.currentUser,
      'receiver': widget.receiver,
      'content': text,
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerChat(users: _users, username: widget.currentUser),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chat: ${widget.receiver}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              "Your username : ${widget.currentUser}",
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
                  .eq('username', widget.currentUser);
              // Delete all messages from this user
              await client
                  .from('messages')
                  .delete()
                  .eq('sender', widget.currentUser);
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
                children: [
                  SizedBox(height: 4),
                  ..._messages.reversed.map((msg) {
                    return (msg['receiver'] == widget.currentUser)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                (msg['sender'] == widget.currentUser)
                                    ? Expanded(flex: 1, child: Container())
                                    : Container(),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    color: (msg['sender'] == widget.currentUser)
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    child: ListTile(
                                      leading:
                                          (msg['sender'] == widget.currentUser)
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
                                      title: (msg['sender'] == widget.currentUser)
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
                                          color:
                                              (msg['sender'] == widget.currentUser)
                                              ? null
                                              : Colors.white,
                                        ),
                                      ),
                                      isThreeLine: true,
                                      trailing:
                                          (msg['sender'] == widget.currentUser)
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
                                !(msg['sender'] == widget.currentUser)
                                    ? Expanded(flex: 1, child: Container())
                                    : Container(),
                              ],
                            ),
                          )
                        : Container();
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
