import 'package:flutter/material.dart';
import 'package:groupiee/pages/auth/chat_page.dart';
import 'package:groupiee/widgets/widgets.dart';

class GroupTile extends StatefulWidget {
  final String username;
  final String groupid;
  final String groupname;
  GroupTile(
      {Key? key,
      required this.username,
      required this.groupid,
      required this.groupname})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupid: widget.groupid,
              groupname: widget.groupname,
              usename: widget.username,
            ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.groupname.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            widget.groupname,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Join the conversatation as${widget.username}",
            style: TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
