import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.username});

  final String username;
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
      'receiver': null, // Everyone Group
      'content': text,
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            onPressed: () {},
            icon: Icon(Icons.logout_rounded, color: Colors.red, size: 24,),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.onSecondary,
              child: ListView(
                children: _messages.reversed.map((msg) {
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
                                  : Icon(Icons.person_pin_rounded),
                              title: Text("${msg['sender']}"),
                              subtitle: Text("${msg['content']}"),
                              isThreeLine: true,
                              trailing: (msg['sender'] == widget.username)
                                  ? Icon(Icons.person)
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
                }).toList(),
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
