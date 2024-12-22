import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // TextEditingController inputText = TextEditingController();
  // String result = 'results are shown here';
  // bool isloading = false;
  // // void promptResult() {
  // //   setState(() {
  // //     isloading = true;
  // //   });

  // //   Gemini.instance.prompt(parts: [
  // //     Part.text(inputText.text),
  // //   ]).then((value) {
  // //     print(value?.output);
  // //     result = value!.output!;
  // //     result;
  // //     setState(() {
  // //       isloading = false;
  // //     });
  // //   }).catchError((e) {
  // //     print('error ${e}');
  // //   });
  // // }

  // XFile? img;
  // void pickImage() async {
  //   final ImagePicker picker = ImagePicker();
  //   try {
  //     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  //     if (image != null) {
  //       setState(() {
  //         img = image;
  //       });
  //     } else {
  //       print('No image selected.');
  //     }
  //   } catch (e) {
  //     print('Error picking image: $e');
  //   }
  // }

  // void promptResponse() {
  //   if (img == null) {
  //     print('No image selected. Please pick an image first.');
  //     return;
  //   }

  //   try {
  //     final gemini = Gemini.instance;
  //     final file = File(img!.path);

  //     gemini.textAndImage(
  //       text: inputText.text, // Input text from the user
  //       images: [file.readAsBytesSync()], // Image as bytes
  //     ).then((value) {
  //       final contentPart = value?.content?.parts?.last.toString() ?? '';
  //       setState(() {
  //         result = contentPart;
  //       });
  //     }).catchError((e) {
  //       log('textAndImageInput error', error: e);
  //       print('Error during prompt response: $e');
  //     });
  //   } catch (e) {
  //     print('Error processing prompt response: $e');
  //   }
  // }

  // using Uri do it the same work

  XFile? pickedImage;
  String mytext = '';
  bool scanning = false;

  TextEditingController prompt = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  final apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyAnf2-iSXEQIluENf2zq7IHIzXJ8nKGRjE';

  final header = {
    'Content-Type': 'application/json',
  };

  getImage(ImageSource ourSource) async {
    XFile? result = await _imagePicker.pickImage(source: ourSource);

    if (result != null) {
      setState(() {
        pickedImage = result;
      });
    }
  }

  getdata(image, promptValue) async {
    setState(() {
      scanning = true;
      mytext = '';
    });

    try {
      List<int> imageBytes = File(image.path).readAsBytesSync();
      String base64File = base64.encode(imageBytes);

      final data = {
        "contents": [
          {
            "parts": [
              {"text": promptValue},
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64File,
                }
              }
            ]
          }
        ],
      };

      await http
          .post(Uri.parse(apiUrl), headers: header, body: jsonEncode(data))
          .then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          mytext = result['candidates'][0]['content']['parts'][0]['text'];
        } else {
          mytext = 'Response status : ${response.statusCode}';
        }
      }).catchError((error) {
        print('Error occored ${error}');
      });
    } catch (e) {
      print('Error occured ${e}');
    }

    scanning = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Ai_Bot'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    image: pickedImage != null
                        ? DecorationImage(
                            image: FileImage(File(pickedImage!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                scanning
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Card(
                        child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(mytext),
                      )),
                SizedBox(height: 100),
              ],
            ),
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
                    controller: prompt,
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
                getdata(pickedImage, prompt.text);
                prompt.clear();
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
                getImage(ImageSource.gallery);
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
