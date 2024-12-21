import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

const apiKey = 'AIzaSyBXuP2zWkD8ZieMFOGwV8p_OS6yAB6a8lg';

void main() {
  runApp(const MyApp());
  Gemini.init(apiKey: apiKey);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController inputText = TextEditingController();
  String result = 'results are shown here';
  bool isloading = false;
  void promptResult() {
    setState(() {
      isloading = true;
    });

    Gemini.instance.prompt(parts: [
      Part.text(inputText.text),
    ]).then((value) {
      print(value?.output);
      result = value!.output!;
      result;
      setState(() {
        isloading = false;
      });
    }).catchError((e) {
      print('error ${e}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Ai_Bot'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isloading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Text(result),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          spacing: 10,
          children: [
            Expanded(
              child: Card(
                color: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextField(
                    controller: inputText,
                    decoration: InputDecoration(
                      hintText: 'write your prompt',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                promptResult();
                inputText.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              label: Icon(
                Icons.send,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
