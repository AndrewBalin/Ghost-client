import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: LoginPage(),
    );
  }
}

class ChatPage extends StatefulWidget {

  late String userNickname;
  ChatPage({super.key, required this.userNickname});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {


  late IO.Socket socket;
  TextEditingController messageController = TextEditingController();
  List<Widget> messages = [];
  String tempMessage = '';

  void addMessage(message, nickname) {
    setState(() {
      if (nickname == widget.userNickname) {
        messages.add(MyMessage(text: message));
      }
      else {
        messages.add(OtherMessage(text: message));
      }
    });
  }

  void sendMessage() {
    if (tempMessage != '') {
      socket.emit('send_message', {'message': tempMessage, 'nickname': widget.userNickname});
      messageController.clear();
      tempMessage = '';
    } else {
      print('>>>FOO');
    }
  }

  void initSocket() {
    socket = IO.io('https://877d-188-186-24-67.ngrok-free.app', <String, dynamic>{'transports': ['websocket'],});
    socket.on('get_message', (messageData) => addMessage(messageData['message'], messageData['nickname']));
    socket.connect();
    print("Connected");
  }

  @override
  void initState() {
    super.initState();

    initSocket();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
          title: Text("Тестовый чат!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Calibri')),
          backgroundColor: Colors.lightBlueAccent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Colors.black,
              height: 2,
            ),
          )
      ),
      body: Center(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            Expanded(
                child: Container(
                  width: size.width,
                  height: size.height * 0.8,
                  child: SingleChildScrollView(
                    child: Column(
                      verticalDirection: VerticalDirection.down,
                      children: messages,
                    ),
                  ),
                ),
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () {

                    },
                    icon: Icon(Icons.insert_emoticon)
                ),
                Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                      tempMessage = value;
                    },
                )
                ),
                IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(Icons.send)
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {

  LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  late String nickname;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[
            Text("Введите никнейм!",
              style: TextStyle(
                fontFamily: 'Calibri',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextField(
              onChanged: (value) {
                nickname = value;
              },
            ),
            ElevatedButton(
                onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatPage(userNickname: nickname)));},
                child: Text("Продолжить")
            )
          ],
        ),
      ),
    );
  }
}

class OtherMessage extends StatelessWidget {

  late String text;

  OtherMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: 20,
                      maxWidth: size.width * 0.7,
                      minWidth: size.width * 0.5
                  ),
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.lightBlueAccent,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          text,
                          style: TextStyle(fontFamily: 'Calibri',
                              fontSize: 10,
                              fontWeight: FontWeight.w400),
                        ),
                      )
                  )
              )
          )
        ]
    );
  }
}

class MyMessage extends StatelessWidget {

  late String text;

  MyMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10, top: 10),
          child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 20,
                  maxWidth: size.width * 0.7,
                  minWidth: size.width * 0.5
              ),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      text,
                      style: TextStyle(fontFamily: 'Calibri',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  )
              )
          ),
        )
      ],
    );
  }
}

