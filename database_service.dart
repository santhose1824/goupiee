import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService(this.uid);
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  getUserGroup() async {
    return userCollection.doc(uid).snapshots();
  }

  Future createGroup(String username, String id, String groupname) async {
    DocumentReference groupdocumentReference = await groupCollection.add({
      "groupname": groupname,
      "groupicon": "",
      "admin": "${id}_$username",
      "members": [],
      "groupid": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    await groupdocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$username"]),
      "groupid": groupdocumentReference.id,
    });

    DocumentReference userDocumentReference = await userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupdocumentReference.id}_$groupname"])
    });
  }

  getChats(String groupid) async {
    return groupCollection
        .doc(groupid)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupid) async {
    DocumentReference d = groupCollection.doc(groupid);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  getGroupMrembers(groupid) async {
    return groupCollection.doc(groupid).snapshots();
  }

  searchByName(String groupname) {
    return groupCollection.where("groupname", isEqualTo: groupname).get();
  }

  Future<bool> isUserJoined(
      String groupname, String groupid, String username) async {
    DocumentReference userDocument = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocument.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    if (groups.contains("${groupid}_groupname")) {
      return true;
    } else {
      return false;
    }
  }

  Future groupJoin(String groupid, String username, String groupname) async {
    DocumentReference userDocument = userCollection.doc(uid);
    DocumentReference groupDocument = groupCollection.doc(groupid);

    DocumentSnapshot documentSnapshot = await userDocument.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    if (groups.contains("${groupid}_$groupname")) {
      await userDocument.update({
        "groups": FieldValue.arrayRemove(["${groupid}_$groupname"])
      });
      await groupDocument.update({
        "members": FieldValue.arrayRemove(["${uid}_$username"])
      });
    } else {
      await userDocument.update({
        "groups": FieldValue.arrayUnion(["${groupid}_$groupname"])
      });
      await groupDocument.update({
        "members    ": FieldValue.arrayUnion(["${uid}_$username"])
      });
    }
  }

  sendMessage(String groupid, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupid).collection("messages").add(chatMessageData);
    groupCollection.doc(groupid).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTimer": chatMessageData['time'].toString()
    });
  }
}
