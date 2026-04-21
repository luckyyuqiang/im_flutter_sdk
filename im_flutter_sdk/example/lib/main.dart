import 'dart:io';

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

//var appKey = "easemob-demo#wang";
var appKey = "easemob-demo#ngisdkdemo";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(appKey.isNotEmpty, "appKey is empty");

  EMOptions options = EMOptions.withAppKey(
    appKey,
    autoLogin: false,
    debugMode: true,
    //enableDNSConfig: false,
    //restServer: "https://a1-qa-hsb.easemob.com",
    //webSocketServer: "im-api-ws1-qa-hsb.easemob.com",
    //webSocketPort: 443,
    //enableTLS: true,
  );

  await EMClient.getInstance.init(options);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  String _userId = "";
  String _password = "";
  String _messageContent = "";
  String _chatId = "";
  final List<String> _logText = [];

  @override
  void initState() {
    super.initState();
    _addChatListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: "Enter userId"),
              onChanged: (username) => _userId = username,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Enter password"),
              onChanged: (password) => _password = password,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: _signIn,
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.all(
                        Colors.lightBlue,
                      ),
                    ),
                    child: const Text("SIGN IN"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: _signOut,
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.all(
                        Colors.lightBlue,
                      ),
                    ),
                    child: const Text("SIGN OUT"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: _signUp,
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.all(
                        Colors.lightBlue,
                      ),
                    ),
                    child: const Text("SIGN UP"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: "Enter the username you want to send",
              ),
              onChanged: (chatId) => _chatId = chatId,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Enter content"),
              onChanged: (msg) => _messageContent = msg,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _sendMessage,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.white),
                backgroundColor: WidgetStateProperty.all(Colors.lightBlue),
              ),
              child: const Text("SEND TEXT"),
            ),
            TextButton(
              onPressed: _sendCustomBigMessage,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.white),
                backgroundColor: WidgetStateProperty.all(Colors.lightBlue),
              ),
              child: const Text("SEND CUSTOM BIG MESSAGE"),
            ),
            TextButton(
              onPressed: _sendCustomLittleMessage,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.white),
                backgroundColor: WidgetStateProperty.all(Colors.lightBlue),
              ),
              child: const Text("SEND CUSTOM LITTLE MESSAGE"),
            ),
            TextButton(
              onPressed: _joinChatRoom,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.white),
                backgroundColor: WidgetStateProperty.all(Colors.lightBlue),
              ),
              child: const Text("JOIN CHAT ROOM"),
            ),
            Flexible(
              child: ListView.builder(
                controller: scrollController,
                itemBuilder: (_, index) {
                  return Text(_logText[index]);
                },
                itemCount: _logText.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Platform.isAndroid
        ? EMClient.getInstance.chatManager.removeMessageEvent(
            "UNIQUE_HANDLER_ID",
          )
        : EMClient.getInstance.chatManager.removeMessageEvent(
            "UNIQUE_HANDLER_ID",
          );
    EMClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
    super.dispose();
  }

  void _addChatListener() {
    EMClient.getInstance.addConnectionEventHandler(
      'identifier',
      EMConnectionEventHandler(
        onUserDidLoginFromOtherDevice: (info) {
          _addLogToConsole(
              "onUserDidLoginFromOtherDevice,info: ${info.deviceName}");
        },
        onConnected: () {
          _addLogToConsole("onConnected");
        },
        onDisconnected: () {
          _addLogToConsole("onDisconnected");
        },
        onUserDidRemoveFromServer: () {
          _addLogToConsole("onUserDidRemoveFromServer");
        },
        onUserDidForbidByServer: () {
          _addLogToConsole("onUserDidForbidByServer");
        },
      ),
    );

    EMClient.getInstance.chatManager.addMessageEvent(
      "UNIQUE_HANDLER_ID",
      ChatMessageEvent(
        onSuccess: (msgId, msg) {
          //_addLogToConsole("on message succeed");
        },
        onProgress: (msgId, progress) {
          _addLogToConsole("on message progress");
        },
        onError: (msgId, msg, error) {
          _addLogToConsole(
            "on message failed, code: ${error.code}, desc: ${error.description}",
          );
        },
      ),
    );

    EMClient.getInstance.chatManager.addEventHandler(
      "UNIQUE_HANDLER_ID",
      EMChatEventHandler(
        onMessagesReceived: (messages) {
          for (var msg in messages) {
            switch (msg.body.type) {
              case MessageType.TXT:
                {
                  EMTextMessageBody body = msg.body as EMTextMessageBody;
                  _addLogToConsole(
                    "receive text message: ${body.content}, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.IMAGE:
                {
                  _addLogToConsole("receive image message, from: ${msg.from}");
                }
                break;
              case MessageType.VIDEO:
                {
                  _addLogToConsole("receive video message, from: ${msg.from}");
                }
                break;
              case MessageType.LOCATION:
                {
                  _addLogToConsole(
                    "receive location message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.VOICE:
                {
                  _addLogToConsole("receive voice message, from: ${msg.from}");
                }
                break;
              case MessageType.FILE:
                {
                  EMClient.getInstance.chatManager.downloadAttachment(msg);
                  _addLogToConsole("receive file message, from: ${msg.from}");
                }
                break;
              case MessageType.CUSTOM:
                {
                  _addLogToConsole("receive custom message, from: ${msg.from}");
                }
                break;
              case MessageType.CMD:
                {
                  // 当前回调中不会有 CMD 类型消息，CMD 类型消息通过 [EMChatManagerEventHandle.onCmdMessagesReceived] 回调接收
                }
                break;
              case MessageType.COMBINE:
                {
                  _addLogToConsole(
                    "receive combine message, from: ${msg.from}",
                  );
                }
            }
          }
        },
      ),
    );
    EMClient.getInstance.groupManager.removeEventHandler('identifier');
  }

  void _signIn() async {
    if (_userId.isEmpty || _password.isEmpty) {
      _addLogToConsole("userId or password is null");
      return;
    }

    try {
      _addLogToConsole("sign in...");
      await EMClient.getInstance.loginWithPassword(_userId, _password);
      await EMClient.getInstance.startCallback();
      _addLogToConsole("sign in succeed, username: $_userId");
    } on EMError catch (e) {
      _addLogToConsole("sign in failed, e: ${e.code} , ${e.description}");
    }
  }

  void _signOut() async {
    try {
      _addLogToConsole("sign out...");
      await EMClient.getInstance.logout(true);
      _addLogToConsole("sign out succeed");
    } on EMError catch (e) {
      _addLogToConsole(
        "sign out failed, code: ${e.code}, desc: ${e.description}",
      );
    }
  }

  void _signUp() async {
    try {
      _addLogToConsole("sign up...");
      await EMClient.getInstance.createAccount(_userId, _password);
      _addLogToConsole("sign up succeed, username: $_userId");
    } on EMError catch (e) {
      _addLogToConsole("sign up failed, e: ${e.code} , ${e.description}");
    }
  }

  EMMessage _createCustomBigMessage(String userId, String inEvent) {
      const String _messageContent = '''
      {
        "{"type":"GIFT","badgeUrls":["https://miggo.oss-ap-southeast-1.aliyuncs.com/other/manager-15f1274c-672c-4981-92ad-ea7da88d1086.png"],"vipInfo":{"type":"MARQUIS","badgeUrl":"https://miggo.oss-ap-southeast-1.aliyuncs.com/svga_cover/manager-a48640ae-9dcf-45a3-88b0-12b850ccd8c7.png"},"userProfile":{"id":"2001635932659589121","account":"10048","userAvatar":"https://dev-yuyin.oss-ap-southeast-1.aliyuncs.com/avatar/c311e981-2080-4ff9-bdf5-110329924ba1.jpg","userNickname":"box1","userSex":1,"age":29,"freezingTime":1766004570000,"countryId":"1231833304232112130","countryName":"India","countryCode":"IN","regionCode":"OTHER","originSys":"MIGGO","sysOriginChild":"MIGGO","del":false,"createTime":1766090970000,"bornYear":1996,"bornMonth":1,"bornDay":1,"useProps":[{"userId":"2001635932659589121","propsResources":{"id":"2005473358830690306","type":"NOBLE_VIP","code":"VIP3","name":"MARQUIS","cover":"https://miggo.oss-ap-southeast-1.aliyuncs.com/svga_cover/manager-a48640ae-9dcf-45a3-88b0-12b850ccd8c7.png","sourceUrl":"https://miggo.oss-ap-southeast-1.aliyuncs.com/svgasource/manager-c1e11c97-074d-4e28-8b76-4914d4aa9efa.svga","expand":"","amount":30000.0},"expireTime":1769582552000,"allowGive":null}],"wearBadge":[{"id":"1565533277562978305","badgeLevel":5,"milestone":"","badgeName":"SVIP5","type":"ACTIVITY","badgeKey":"svip5_badge","selectUrl":"https://miggo.oss-ap-southeast-1.aliyuncs.com/other/manager-15f1274c-672c-4981-92ad-ea7da88d1086.png","notSelectUrl":"","animationUrl":"https://miggo.oss-ap-southeast-1.aliyuncs.com/other/manager-7f5f13b8-0830-4c19-b4f9-3ffcf05eb69b.svga"}],"ownSpecialId":null,"userLevel":null,"inRoomId":null,"roomIcon":null,"accountStatus":"NORMAL","sameRegion":true,"isUpdateCountry":"1"},"chatBubble":"","giftMsg":{"sender":{"id":"2001635932659589121","userName":"box1","userPic":"https://dev-yuyin.oss-ap-southeast-1.aliyuncs.com/avatar/c311e981-2080-4ff9-bdf5-110329924ba1.jpg"},"sendGiftAllType":"ON_MIC","giftList":[{"giftId":"2006262610737274881","giftPic":"https://miggo.oss-ap-southeast-1.aliyuncs.com/gifts/manager-83303ab8-9d49-498b-80b7-9a73c91d7994.png","giftSourceUrl":"","special":"","currencyType":"","giftTab":"LUCKY_GIFT","giftCount":1,"giftPrice":10,"rewardMultiple":1}],"receiverList":[{"receiverId":"2001635932659589121","receiverName":"box1","receiverAvatar":"https://dev-yuyin.oss-ap-southeast-1.aliyuncs.com/avatar/c311e981-2080-4ff9-bdf5-110329924ba1.jpg","jumpCombo":8,"giftIds":["2006262610737274881"]}],"sendGiftTime":1767773894989,"target":1},"svipLevel":"SVIP_5"}"
      }
      ''';

    EMMessage msg = EMMessage.createCustomSendMessage(
      targetId: userId,
      event: inEvent,
      params: {
        "data": _messageContent,
      },
    );
    msg.chatType = ChatType.ChatRoom;
    return msg;
  }

    EMMessage _createCustomLittleMessage(String userId, String inEvent) {
      const String _messageContent = '''
      {
        "{"type":"GIFT","badgeUrls":["https://miggo.oss-ap-southeast-1.aliyuncs.com/other/ea7da88d1086.png"]}"
      }
      ''';

    EMMessage msg = EMMessage.createCustomSendMessage(
      targetId: userId,
      event: inEvent,
      params: {
        "data": _messageContent,
      },
    );
    msg.chatType = ChatType.ChatRoom;
    return msg;
  }

  void _sendCustomBigMessage() async {
    if (_chatId.isEmpty) {
      _addLogToConsole("chat id is null");
      return;
    }
    for (var i = 0; i < 10; i++) {
      var msg = _createCustomBigMessage(_chatId, "ROOM_CHAT_$i");
      await EMClient.getInstance.chatManager.sendMessage(msg);
      _addLogToConsole("send big message done");
    }
  }

  void _sendCustomLittleMessage() async {
    if (_chatId.isEmpty) {
      _addLogToConsole("chat id is null");
      return;
    }
    for (var i = 0; i < 10; i++) {
      var msg = _createCustomLittleMessage(_chatId, "ROOM_CHAT_$i");
      await EMClient.getInstance.chatManager.sendMessage(msg);
      _addLogToConsole("send little message done");
    }
  }

  void _sendMessage() async {
    if (_chatId.isEmpty || _messageContent.isEmpty) {
      _addLogToConsole("single chat id or message content is null");
      return;
    }

    var msg = EMMessage.createTxtSendMessage(
      targetId: _chatId,
      content: _messageContent,
    );

    await EMClient.getInstance.chatManager.sendMessage(msg);
  }

  void _joinChatRoom() async {
    if (_chatId.isEmpty) {
      _addLogToConsole("chat id is null");
      return;
    }
    try {
      _addLogToConsole("join chat room...");
      await EMClient.getInstance.chatRoomManager.joinChatRoom(_chatId);
      _addLogToConsole("join chat room succeed");
    } on EMError catch (e) {
      _addLogToConsole("join chat room failed, e: ${e.code} , ${e.description}");
    }
  }

  void _addLogToConsole(String log) {
    _logText.add("$_timeString: $log");
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  String get _timeString {
    return DateTime.now().toString().split(".").first;
  }
}
