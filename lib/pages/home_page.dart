import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController inputText = TextEditingController();
  String result = 'results are shown here';
  bool isloading = false;
  // void promptResult() {
  //   setState(() {
  //     isloading = true;
  //   });

  //   Gemini.instance.prompt(parts: [
  //     Part.text(inputText.text),
  //   ]).then((value) {
  //     print(value?.output);
  //     result = value!.output!;
  //     result;
  //     setState(() {
  //       isloading = false;
  //     });
  //   }).catchError((e) {
  //     print('error ${e}');
  //   });
  // }

  XFile? img;
  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          img = image;
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void promptResponse() {
    if (img == null) {
      print('No image selected. Please pick an image first.');
      return;
    }

    try {
      final gemini = Gemini.instance;
      final file = File(img!.path);

      gemini.textAndImage(
        text: inputText.text, // Input text from the user
        images: [file.readAsBytesSync()], // Image as bytes
      ).then((value) {
        final contentPart = value?.content?.parts?.last.toString() ?? '';
        setState(() {
          result = contentPart;
        });
      }).catchError((e) {
        log('textAndImageInput error', error: e);
        print('Error during prompt response: $e');
      });
    } catch (e) {
      print('Error processing prompt response: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('$img');
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
              isloading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        image: img != null
                            ? DecorationImage(
                                image: FileImage(File(img!.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    )
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
                promptResponse();
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
            ElevatedButton.icon(
              onPressed: () {
                pickImage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              label: Icon(
                Icons.image,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
