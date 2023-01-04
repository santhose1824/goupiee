import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupiee/helper/helper.dart';
import 'package:groupiee/pages/auth/chat_page.dart';
import 'package:groupiee/services/database_service.dart';
import 'package:groupiee/widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController search = new TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool userSearched = false;
  String username = "";
  User? user;
  bool isJoined = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserNameFromSf().then((value) {
      setState(() {
        username = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Search "),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: search,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: "Search groups",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 16,
                        )),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : groupList(),
        ],
      ),
    );
  }

  initateSearchMethod() async {
    if (search.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService(FirebaseAuth.instance.currentUser!.uid)
          .searchByName(search.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          _isLoading = false;
          userSearched = true;
        });
      });
    }
  }

  groupList() {
    return userSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                username,
                searchSnapshot!.docs[index]['groupid'],
                searchSnapshot!.docs[index]['groupname'],
                searchSnapshot!.docs[index]['admin'],
              );
            },
          )
        : Container();
  }

  joinedOrnot(
      String username, String groupid, String groupname, String admin) async {
    await DatabaseService(user!.uid)
        .isUserJoined(groupname, groupid, username)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
      String usename, String groupid, String groupname, String admin) {
    joinedOrnot(username, groupid, groupname, admin);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupname.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        groupname,
        style: TextStyle(
            color: Colors.black, fontSize: 27, fontWeight: FontWeight.w600),
      ),
      subtitle: Text("Admin :${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(user!.uid)
              .groupJoin(groupid, username, groupname);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, Colors.red, "Left the group");

            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupname: groupname,
                      groupid: groupid,
                      usename: usename));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
              showSnackbar(context, Colors.green, "Successfully joined");
            });
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 1)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Joined",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Join",
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
