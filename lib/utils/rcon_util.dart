import 'dart:io';
import 'dart:typed_data';
import 'package:rcon/rcon.dart';

main(List<String> args) async {
  // String ip = input(
  //     "Enter the IP address of your server: ",
  //     (str) => InternetAddress.tryParse(str) != null,
  //     "Please enter a valid IP address.");
  // String port = input("Enter your server's RCON port: ",
  //     (str) => int.tryParse(str) != null, "Please enter a number.");
  // print("Waiting...");
  // Client client = await Client.create(ip, int.parse(port));
  // print("Connected to the server at $ip:$port");
  // input("Enter your server's RCON password: ", (str) => client.login(str),
  //     "Enter the correct password.");
  // print("You have been authenticated.");
  // print("You can now run any command by entering it below.");
  // print("You can end the program by typing \"rcon.exit\"");
  //
  // bool killswitch = false;
  // while (!killswitch) {
  //   String input = stdin.readLineSync() ?? "";
  //   if (input == "rcon.exit") {
  //     killswitch = true;
  //     continue;
  //   }
  //   print(processCommand(client, input));
  // }
  //
  // print("Program exited successfully.");
  //
  // client.close();

  RconUtil.init("49.235.139.219", 25575, "986920241");
  RconUtil.connect();
  RconUtil.processCommand("list");
  RconUtil.close();
}
//
// String input(String query, Function(String) check, String errorMessage) {
//   print(query);
//   String? out = stdin.readLineSync();
//   while (out == null || !check.call(out)) {
//     print(errorMessage);
//     out = stdin.readLineSync();
//   }
//   return out;
// }
//
// Message processCommand(Client client, String input) {
//   return client.send(Message.create(client, PacketType.command, input));
// }

/// Minecraft Rcon 工具类
class RconUtil {
  static late String _ipAddress;

  static late int _port;

  static late String _rconPassword;

  static Client? _client;

  static init(String ip, int port, String password) {
    _ipAddress = ip;
    _port = port;
    _rconPassword = password;
  }

  static connect() async {
    if (_client != null) {
      print("客户端未断开连接");
    }
    _client = await Client.create(
      _ipAddress,
      _port,
    );
    print("客户端创建逻辑执行完毕。");
    if (_client != null) {
      print("连接成功");
    }
    // Message? msg = _client?.send(Message.create(_client!, PacketType.login, _rconPassword));
    // String payload = msg!.payload;

    // print(payload);
    print("正在验证是否已登陆成功...");
    // if (isLoged != null) {
    //   print(isLoged ? "已登录" : "登陆失败！");
    // }

    if (_client != null) {
      print("连接成功！" + _client.toString());
      processCommand("list");
      return 0;
    } else {
      print("连接失败. 请重试");
    }
  }

  static Message? processCommand(String input) {
    return _client?.send(Message.create(_client!, PacketType.command, input));
  }

  // static Message? loginCommand() {
  //   return _client?.send(Message.create(_client!, PacketType.login, _rconPassword));
  // }

  static close() {
    if (_client != null) {
      _client?.close();
    }
  }
  
  static connectWithDatagram() {
    var uInt8List = Uint8List(1024);

    var datagram = Datagram(uInt8List, InternetAddress("49.235.139.219"), 25575);
  }
}
