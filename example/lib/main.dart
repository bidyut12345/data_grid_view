import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:data_grid_view/data_grid_view.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/devtools.dart';
import 'package:webf/webf.dart';
// import 'package:linked_scroll_controller/linked_scroll_controller.dart';
// import 'package:webview_all/webview_all.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'DataGridView Demopage'),
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
  // var scHorizontal = LinkedScrollControllerGroup();
  // late ScrollController scHeader;
  // ScrollController scVertical = ScrollController();
  WebFController? controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.run(() {
      controller = WebFController(
        context,
        devToolsService: ChromeDevToolsService(),
      );
      controller?.preload(WebFBundle.fromContent("<html><b>sadfsdfsd</b></html>"));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            //   // child: Text("Asdasd"),
            //   child: SingleChildScrollView(
            //     child: Table(
            //       children: List.generate(
            //         1000,
            //         (index) => TableRow(
            //           children: List.generate(
            //             5,
            //             (index) => Text(
            //               "$index w",
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // child: Text("Asdasd"),
            // child: Scrollbar(
            //   controller: scVertical,
            //   thumbVisibility: true,
            //   trackVisibility: true,
            //   child: Scrollbar(
            //     controller: scHeader,
            //     thumbVisibility: true,
            //     trackVisibility: true,
            //     child: Row(
            //       children: [
            //         Expanded(
            //           child: Column(
            //             children: [
            //               Container(
            //                 color: Colors.grey,
            //                 height: 30,
            //                 child: ListView.builder(
            //                   controller: scHeader,
            //                   itemCount: 50,
            //                   scrollDirection: Axis.horizontal,
            //                   itemBuilder: (context, index) => Text("$index sssssssssss ssssssssssssss"),
            //                 ),
            //               ),
            //               Expanded(
            //                 child: ListView.builder(
            //                   itemCount: 10000,
            //                   cacheExtent: 50000,
            //                   controller: scVertical,
            //                   itemBuilder: (context, index) {
            //                     return SizedBox(
            //                       height: 30,
            //                       child: ScrollConfiguration(
            //                         behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            //                         child: ListView.builder(
            //                           controller: scHorizontal.addAndGet(),
            //                           itemCount: 50,
            //                           scrollDirection: Axis.horizontal,
            //                           itemBuilder: (context, index1) => Text("$index sssssssssss ssssssssssssss"),
            //                         ),
            //                       ),
            //                     );
            //                   },
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // child: DataGridView(
            //   data: List.generate(
            //     100,
            //     (i) => {
            //       for (var v in List.generate(20, (i) => i.toString())) v.toString(): "$i whg ",
            //     },
            //   ),
            // ),
            child: controller == null ? Container() : WebF(controller: controller),
          ),
        ],
      ),
    );
  }
}
