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
        messages.add(MyMessage(text: message, nickname: nickname,));
      }
      else {
        messages.add(OtherMessage(text: message, nickname: nickname,));
      }
    });
  }

  void addSticker(id, nickname) {
    setState(() {
      if (nickname == widget.userNickname) {
        messages.add(MySticker(id: id, nickname: nickname,));
      }
      else {
        messages.add(OtherSticker(id: id, nickname: nickname));
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
    socket = IO.io('https://877c-188-132-129-48.ngrok-free.app', <String, dynamic>{'transports': ['websocket'],});
    socket.on('get_message', (messageData) => addMessage(messageData['message'], messageData['nickname']));
    socket.on('get_sticker', (messageData) => addSticker(messageData['id'], messageData['nickname']));
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
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.all(5),
                            child: SingleChildScrollView(
                              child: Column(
                                  children: [
                                    Row(
                                        children: [
                                          Sticker(id: 1, login: widget.userNickname, socket: socket),
                                          Sticker(id: 2, login: widget.userNickname, socket: socket),
                                          Sticker(id: 3, login: widget.userNickname, socket: socket),
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          Sticker(id: 4, login: widget.userNickname, socket: socket),
                                          Sticker(id: 5, login: widget.userNickname, socket: socket),
                                          Sticker(id: 6, login: widget.userNickname, socket: socket),
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          Sticker(id: 7, login: widget.userNickname, socket: socket),
                                          Sticker(id: 8, login: widget.userNickname, socket: socket),
                                          Sticker(id: 9, login: widget.userNickname, socket: socket),
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          Sticker(id: 10, login: widget.userNickname, socket: socket),
                                        ]
                                    ),
                                  ]
                              )
                            )
                          );
                        },
                      );
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

  String nickname = '';

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
            Padding(padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
              child: TextField(
                onChanged: (value) {
                  nickname = value;
                },
              ),
            ),

            ElevatedButton(
                onPressed: () {
                  if (nickname != '') {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => ChatPage(userNickname: nickname)));
                  }

                },
                child: Text("Продолжить")
            ),
            Padding(padding: EdgeInsets.only(top: 20, left: 30, right: 30),
              child: Text("Пожалуйста! Исползуйте оригинальный никнейм, не содержащий негативных высказываний или нецензурной лексики",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Calibri',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OtherMessage extends StatelessWidget {

  late String text;
  late String nickname;

  OtherMessage({super.key, required this.text, required this.nickname});

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
                  ),
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.lightBlueAccent,
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                    nickname,
                                    style: TextStyle(fontFamily: 'Calibri',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)
                                ),
                              ),
                              Text(
                                  text,
                                  style: TextStyle(fontFamily: 'Calibri',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white)
                              ),
                            ],
                          )

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
  late String nickname;

  MyMessage({super.key, required this.text, required this.nickname});

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
              ),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal,
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                                nickname,
                                style: TextStyle(fontFamily: 'Calibri',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)
                            ),
                          ),
                          Text(
                              text,
                              style: TextStyle(fontFamily: 'Calibri',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white)
                          ),
                        ],
                      )
                  )
              )
          ),
        )
      ],
    );
  }
}

class OtherSticker extends StatelessWidget {

  late int id;
  late String nickname;

  OtherSticker({super.key, required this.id, required this.nickname});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10, top: 10),
          child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 20,
                  maxWidth: size.width * 0.3,
                  minWidth: size.width * 0.3
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                        nickname,
                        style: TextStyle(fontFamily: 'Calibri',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black)
                    ),
                  ),
                  Image.asset(
                      'assets/stickers/${id}.png', height: size.width * 0.4,
                      width: size.width * 0.4)
                ],
              )
          ),
        )
      ],
    );
  }
}

class MySticker extends StatelessWidget {

  late int id;
  late String nickname;

  MySticker({super.key, required this.id, required this.nickname});

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
                  maxWidth: size.width * 0.4,
                  minWidth: size.width * 0.4
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                        nickname,
                        style: TextStyle(fontFamily: 'Calibri',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black)
                    ),
                  ),
                  Image.asset(
                      'assets/stickers/${id}.png', height: size.width * 0.4,
                      width: size.width * 0.4)
                ],
              )

          ),
        )
      ],
    );
  }
}

class Sticker extends StatefulWidget {
  late int id;
  late String login;
  late IO.Socket socket;
  Sticker({super.key, required this.id, required this.login, required this.socket});

  @override
  State<Sticker> createState() => _StickerState();
}

class _StickerState extends State<Sticker> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
        width: (size.width - 10) * 0.333,
        height: (size.width - 10) * 0.333,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Center(
              child: Ink.image(
                image: AssetImage(
                    'assets/stickers/${widget.id}.png'
                ),
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: () {
                    widget.socket.emit('send_sticker',
                        {'nickname': widget.login, 'id': widget.id});
                    Navigator.pop(context);
                  },
                ),
              )
          ),
        )
    );
  }
}
