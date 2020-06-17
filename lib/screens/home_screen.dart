import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mytaskapp/config/config.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _taskNameController = TextEditingController();
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;

  @override
  void initState() {
    getUID();
    super.initState();
  }

  void getUID() async {
    FirebaseUser currentUser = await _auth.currentUser();
    setState(() {
      user = currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: Text("Logout"))
        ],
      ),
      body: user==null ? Center(child:CircularProgressIndicator()):StreamBuilder(
        stream: _db
            .collection("users")
            .document(user.uid)
            .collection("tasks").orderBy("date",descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context,index) {
                  return ListTile(
                    title: Text(snapshot.data.documents[index]['task']),
                   trailing: IconButton(icon: Icon(Icons.delete), onPressed: (){
                     _db.collection("users").document(user.uid).collection("tasks").document(snapshot.data.documents[index].documentID).delete();
                    
                   }),
                  );
                });
          } else {
            return Center(
              child: Text("No Task Added Yet"),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog();
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        elevation: 4,
        backgroundColor: primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(icon: Icon(Icons.menu), onPressed: () {}),
              IconButton(icon: Icon(Icons.person), onPressed: () {}),
            ],
          )),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Add Task"),
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  controller: _taskNameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Write your task here...",
                      labelText: "Task Name"),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        String task = _taskNameController.text.trim();

                        await _db
                            .collection("users")
                            .document(user.uid)
                            .collection("tasks")
                            .add({
                          "task": task,
                          "date": DateTime.now(),
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text("Submit"),
                      color: primaryColor,
                    ),
                  ],
                ),
              )
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          );
        });
  }
}
