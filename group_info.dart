import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupiee/pages/auth/home.dart';
import 'package:groupiee/services/database_service.dart';
import 'package:groupiee/widgets/widgets.dart';

import 'login.dart';

class GroupInfo extends StatefulWidget {
  final String groupname;
  final String groupid;
  final String adminname;
  GroupInfo(
      {Key? key,
      required this.groupname,
      required this.groupid,
      required this.adminname})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  @override
  void initState() {
    getMembers();
    // TODO: implement initState
    super.initState();
  }

  getMembers() async {
    DatabaseService(FirebaseAuth.instance.currentUser!.uid)
        .getGroupMrembers(widget.groupid)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Group Info"),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Exit"),
                        content: Text("Are you sure want to Exit the group"),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              DatabaseService(
                                      FirebaseAuth.instance.currentUser!.uid)
                                  .groupJoin(
                                      widget.groupid,
                                      getName(widget.adminname),
                                      widget.groupname)
                                  .whenComplete(() {
                                nextScreen(context, HomePage());
                              });
                            },
                            icon: Icon(
                              Icons.done,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                      );
                    });
              },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).primaryColor.withOpacity(0.2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.groupname.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Group Name :${widget.groupname}",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Admin Name :${getName(widget.adminname)}",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            memberList(),
          ],
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
        stream: members,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['members'] != null) {
              if (snapshot.data['members'] != 0) {
                return ListView.builder(
                    itemCount: snapshot.data['members'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              getName(snapshot.data['members'][index])
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          title: Text(getName(snapshot.data['members'][index])),
                        ),
                      );
                    });
              } else {
                return Center(
                  child: Text("NO MEMBERS"),
                );
              }
            } else {
              return Center(
                child: Text("NO MEMBERS"),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        });
  }
}
