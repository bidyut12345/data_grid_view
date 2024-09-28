import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:data_grid_view/data_grid_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart' as others_webview;
import 'package:webview_windows/webview_windows.dart' as window_webview;

class DgWebView extends StatefulWidget {
  const DgWebView({Key? key, required this.dg, required this.filterdata}) : super(key: key);
  final DataGridView dg;
  final List<Map<String, dynamic>> filterdata;
  @override
  State<DgWebView> createState() => _DgWebViewState();
}

class _DgWebViewState extends State<DgWebView> {
  window_webview.WebviewController? windowWebViewController;
  final List<StreamSubscription> windowWebViewSubscriptions = [];
  others_webview.WebViewController? othersWebViewController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!kIsWeb) {
      if (Platform.isWindows) {
        initWindows();
      } else {
        othersWebViewController = others_webview.WebViewController();
        othersWebViewController = others_webview.WebViewController()
          ..enableZoom(false)
          ..setJavaScriptMode(others_webview.JavaScriptMode.unrestricted)
          ..setOnConsoleMessage((message) {
            print(message);
          })
          // ..setNavigationDelegate(
          //   others_webview.NavigationDelegate(
          //     // onProgress: (int progress) {
          //     //   // Update loading bar.
          //     // },
          //     // onPageStarted: (String url) {},
          //     // onPageFinished: (String url) {},
          //     // onHttpError: ( others_webview.HttpResponseError error) {},
          //     // onWebResourceError: ( others_webview.WebResourceError error) {},
          //     onNavigationRequest: (others_webview.NavigationRequest request) {
          //       if (request.url.startsWith('dddf://cellclick')) {
          //         print(request.url);
          //         return others_webview.NavigationDecision.prevent;
          //       }
          //       return others_webview.NavigationDecision.navigate;
          //     },
          //   ),
          // )
          ..loadHtmlString(getHtmlFile("400"));
      }
    }
  }

  Future<void> initWindows() async {
    // Optionally initialize the webview environment using
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    //await WebviewController.initializeEnvironment(
    //    additionalArguments: '--show-fps-counter');

    try {
      windowWebViewController = window_webview.WebviewController();
      await windowWebViewController?.initialize();
      // windowWebViewSubscriptions.add(windowWebViewController!.url.listen((url) {
      //   print(url);
      //   if (url.startsWith('dddf://cellclick')) {
      //     print(url);
      //     // return NavigationDecision.prevent;
      //   }
      // }));
      windowWebViewSubscriptions.add(windowWebViewController!.webMessage.listen((url) {
        print(url);
        // if (url.startsWith('dddf://cellclick')) {
        //   print(url);
        //   // return NavigationDecision.prevent;
        // }
      }));
      // _subscriptions.add(_controller.containsFullScreenElementChanged.listen((flag) {
      //   debugPrint('Contains fullscreen element: $flag');
      //   // windowManager.setFullScreen(flag);
      // }));

      await windowWebViewController?.setBackgroundColor(Colors.transparent);
      await windowWebViewController?.setPopupWindowPolicy(window_webview.WebviewPopupWindowPolicy.deny);
      // await _controller.loadUrl('https://flutter.dev');
      var fl = File("dgfile.html");
      fl.writeAsStringSync(getHtmlFile("100"));
      await windowWebViewController?.loadUrl("file:\\\\${fl.absolute.path}");
      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}'),
                      Text('Message: ${e.message}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      });
    }
  }

  String getHtmlFile(String zoom) {
    if (widget.filterdata.isEmpty) {
      return "<b> Nothing found </b>";
    }
    var str = """
<html>
<head>
<script> 
function SM(val) 
{ 
     ${zoom == '400' ? 'console.debug(val);' : 'window.chrome.webview.postMessage(val);'}     
} 
</script>
<style>
body{
    margin:0px;
    padding:0px;
}
.btn:not(:disabled):not(.disabled) {
    cursor: pointer;
}

td button {
    color: #fff;
    background-color: #28a745;
    border-color: #28a745;
}
td button {
    text-decoration:none;
    display: inline-block;
    font-weight: 400;
    text-align: center;
    white-space: nowrap;
    vertical-align: middle;
    -webkit-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
    border: 1px solid transparent;
    padding: .375rem .75rem;
    font-size: 1rem;
    line-height: 1.5;
    border-radius: .25rem;
    transition: color .15s ease-in-out, background-color .15s ease-in-out, border-color .15s ease-in-out, box-shadow .15s ease-in-out;
}
.table {
    width: 100%;
    max-width: 100%; 
    background-color: transparent;
    border-collapse: collapse;
}
.table-dark {
    color: #fff;
    background-color: #212529;
}
.thead-dark {
    color: #fff;
    background-color: #212529;
}
thead th {
    background-color: #212529;
    position:sticky;
    top: -1px;
    margin-top:-1px;
}
.table-dark.table-striped tbody tr:nth-of-type(odd) {
    background-color: rgba(255, 255, 255, .05);
}
.table-dark td, .table-dark th, .table-dark thead th {
    border-color: #32383e!important;
} 
.table thead th {
    vertical-align: bottom;
    border-bottom: 0.5px solid #dee2e6;
}
 

 
.table td, .table th {
    padding: .25rem; 
    vertical-align: center;
    border-top: 0.5px solid #dee2e6;
}
th {
    text-align: inherit; 
}
.th
{
  display:flex;
  width:100%;
}
.th div:first-child
{
  flex:1; 
}
.th div:last-child
{ 
  width:20px; 
}
</style>
</head>
""";
    str += '<body style="margin:0px;zoom:$zoom%;"><table class="table table-striped table-dark">';
    str += '<thead class="thead-dark"><tr>';
    str += widget.filterdata.first.keys
        .map((e) => (widget.dg.hiddenDataColumns ?? []).contains(e)
            ? ""
            : "<th><div class='th'><div>${widget.dg.dataColumnHeadertexts?[e] ?? e}</div><div></div></div></th>")
        .join();
    str += '</tr></thead>';
    str += '<tbody>';
    //index1 == 0 ? "<td><button onclick='SM(\"$rowIndex,$index1\");' >Load</button></td>" :
    str += widget.filterdata
        .mapIndexed((rowIndex, row) =>
            """<tr>${row.keys.mapIndexed((cellIndex, fieldName) => (widget.dg.hiddenDataColumns ?? []).contains(fieldName) ? "" : "<td>${row[fieldName]}</td>").join()}</tr>""")
        .join();
    str += '</tbody>';
    str += '</table>';
    // File("sda.html").writeAsStringSync(str);
    // await _controller.loadStringContent(str);d
    // print(File("sda.html").absolute.path);
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? Container()
        : Platform.isWindows
            ? (windowWebViewController == null || !windowWebViewController!.value.isInitialized)
                ? Container()
                : window_webview.Webview(
                    windowWebViewController!,
                    // permissionRequested: _onPermissionRequested,
                  )
            : Container();
  }

  // Future<window_webview.WebviewPermissionDecision> _onPermissionRequested(
  //     String url, window_webview.WebviewPermissionKind kind, bool isUserInitiated) async {
  //   final decision = await showDialog<window_webview.WebviewPermissionDecision>(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //       title: const Text('WebView permission requested'),
  //       content: Text('WebView has requested permission \'$kind\''),
  //       actions: <Widget>[
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, window_webview.WebviewPermissionDecision.deny),
  //           child: const Text('Deny'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, window_webview.WebviewPermissionDecision.allow),
  //           child: const Text('Allow'),
  //         ),
  //       ],
  //     ),
  //   );

  //   return decision ?? window_webview.WebviewPermissionDecision.none;
  // }

  @override
  void dispose() {
    for (var s in windowWebViewSubscriptions) {
      s.cancel();
    }
    windowWebViewController?.dispose();
    super.dispose();
  }
}
