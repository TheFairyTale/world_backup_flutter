import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class HttpTestRoute extends StatefulWidget {
  const HttpTestRoute({super.key});

  @override
  State<HttpTestRoute> createState() => _HttpTestRouteState();
}

class _HttpTestRouteState extends State<HttpTestRoute> {
  bool _loading = false;
  String _text = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Expanded(
          child: Column(
            children: [
              ElevatedButton(
                  // 点按onPressed ，如果为true 则不执行请求操作（证明已有一个http 请求在进行了）
                  onPressed: () {
                    _loading ? null : request();
                  },
                  child: Text("调用Api 的实际情况")),
              Container(
                // 调用媒体查询组件获取界面宽度
                width: MediaQuery.of(context).size.width - 50.0,
                //
                child: Text(_text.replaceAll(RegExp(r"\s"), "")),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 具体http 请求封装方法
  request() async {
    setState(() {
      _loading = true;
      _text = "正在请求...";
    });

    try {
      // 新建一个HttpClient
      HttpClient httpClient = HttpClient();
      // 打开一个Http 连接
      HttpClientRequest request =
          await httpClient.getUrl(Uri.parse("http://124.70.177.56:5709/"));
      // 设置浏览器UA值
      request.headers.add("user-agent",
          "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1");
      // 等待连接服务器（调用该close() 会将请求信息发给服务器）
      HttpClientResponse response = await request.close();
      // 读取响应内容
      _text = await response.transform(utf8.decoder).join();
      // 输出响应头
      print("响应头: ");
      print(response.headers);

      // 关闭client后，通过该client 发起的所有请求都将终止
      httpClient.close();
    } catch (e) {
      _text = "请求失败了: $e";
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
