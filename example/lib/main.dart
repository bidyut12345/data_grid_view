import 'package:flutter/material.dart';
import 'package:data_grid_view/data_grid_view.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: DataGridView(
                data: List.generate(
                  10000,
                  (i) => {
                    for (var v in List.generate(20, (i) => i.toString()))
                      v.toString():
                          "$v whgeruw weurbwuyegruwer weuhrbwuegrwie rwebruwehrwiuehrwe rweubruwehriweuhriwer weurbuwehriweuhrweiurgh",
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
