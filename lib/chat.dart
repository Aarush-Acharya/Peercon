import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class Chat extends StatefulWidget {
  Device connected_device;
  NearbyService nearbyService;
  var chat_state;

  Chat({required this.connected_device, required this.nearbyService});

  @override
  State<StatefulWidget> createState() => _Chat();
}

class _Chat extends State<Chat> {
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  List<ChatMessage> messages = [];
  final myController = TextEditingController();
  void addMessgeToList(ChatMessage obj) {
    setState(() {
      messages.insert(0, obj);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    receivedDataSubscription.cancel();
  }

  void init() {
    receivedDataSubscription =
        this.widget.nearbyService.dataReceivedSubscription(callback: (data) {
      var obj =
          ChatMessage(messageContent: data["message"], messageType: "receiver");
      addMessgeToList(obj);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        this.widget.connected_device.deviceName,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        "connected",
                        style: TextStyle(color: Colors.green, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: ListView.builder(
              itemCount: messages.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                  child: Align(
                    alignment: (messages[index].messageType == "receiver"
                        ? Alignment.topLeft
                        : Alignment.topRight),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (messages[index].messageType == "receiver"
                            ? Color.fromARGB(255, 226, 226, 226)
                            : Color.fromARGB(255, 255, 188, 88)),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Text(
                        messages[index].messageContent,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding:
                  EdgeInsets.only(left: 10, bottom: 10, top: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
              ),
              height: 60,
              width: double.infinity,
              child: Row(
                // textDirection: TextDirection.rtl,
                children: <Widget>[
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      // textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        // hintTextDirection: TextDirection.rtl,
                        hintText: "Type your message here ...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none,
                      ),
                      controller: myController,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      if (this.widget.connected_device.state ==
                          SessionState.notConnected) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("disconnected"),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      }

                      this.widget.nearbyService.sendMessage(
                          this.widget.connected_device.deviceId,
                          myController.text);
                      var obj = ChatMessage(
                          messageContent: myController.text,
                          messageType: "sender");

                      addMessgeToList(obj);
                      myController.text = "";
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.orange,
                    elevation: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  String messageContent;
  String messageType;
  ChatMessage({required this.messageContent, required this.messageType});
}
