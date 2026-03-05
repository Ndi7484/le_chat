import 'package:flutter/material.dart';
import 'package:le_chat/chat_page.dart';

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
            child: Column(
              children: [
                Text(
                  'Chat Users',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your username : $username',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
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
            return (user['username'] == username)
                ? Container()
                : ListTile(
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
