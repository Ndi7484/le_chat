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
  final _controller = TextEditingController();
  final _messages = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen((data) {
          setState(() {
            _messages.clear();
            _messages.addAll(data);
          });
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
      drawer: Drawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Username : ${widget.username}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
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

              // Navigate back to LoginPage
              if (mounted) {
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 24),
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
                    return (msg['receiver'] == widget.receiver)
                        ? Padding(
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
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    child: ListTile(
                                      leading:
                                          (msg['sender'] == widget.username)
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
                                          color:
                                              (msg['sender'] == widget.username)
                                              ? null
                                              : Colors.white,
                                        ),
                                      ),
                                      isThreeLine: true,
                                      trailing:
                                          (msg['sender'] == widget.username)
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
