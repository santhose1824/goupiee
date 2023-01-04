import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupiee/pages/auth/group_info.dart';
import 'package:groupiee/services/database_service.dart';
import 'package:groupiee/widgets/message.dart';
import 'package:groupiee/widgets/widgets.dart';

class ChatPage extends StatefulWidget {
  final String groupname;
  final String groupid;
  final String usename;
  ChatPage(
      {Key? key,
      required this.groupname,
      required this.groupid,
      required this.usename})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController message = TextEditingController();
  Stream<QuerySnapshot>? chats;
  String admin = "";

  @override
  void initState() {
    getChatandAdmin();
    // TODO: implement initState
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService(FirebaseAuth.instance.currentUser!.uid)
        .getChats(widget.groupid)
        .then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService(FirebaseAuth.instance.currentUser!.uid)
        .getGroupAdmin(widget.groupid)
        .then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupname),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupname: widget.groupname,
                      groupid: widget.groupid,
                      adminname: admin,
                    ));
              },
              icon: Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: [
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: message,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      decoration: InputDecoration(
                          hintText: "Send a message",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.usename ==
                          snapshot.data.docs[index]['sender']);
                })
            : Container();
      },
    );
  }

  sendMessage() {
    if (message.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": message.text,
        "sender": widget.usename,
        "time": DateTime.now().microsecondsSinceEpoch,
      };
      DatabaseService(FirebaseAuth.instance.currentUser!.uid)
          .sendMessage(widget.groupid, chatMessageMap);
      setState(() {
        message.clear();
      });
    }
  }
}
