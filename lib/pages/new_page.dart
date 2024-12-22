import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageChat extends StatefulWidget {
  const ImageChat({super.key});

  @override
  State<ImageChat> createState() => _ImageChatState();
}

class _ImageChatState extends State<ImageChat> {
  XFile? pickedImage;
  String mytext = '';
  bool scanning = false;

  TextEditingController prompt = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  final apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyAnf2-iSXEQIluENf2zq7IHIzXJ8nKGRjE";

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
        title: Text(
          'Google Gemini',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                getImage(ImageSource.gallery);
              },
              icon: Icon(
                Icons.photo,
                color: Colors.white,
              )),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            pickedImage == null
                ? Container(
                    height: 340,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'No Image Selected',
                        style: TextStyle(fontSize: 22),
                      ),
                    ))
                : Container(
                    height: 340,
                    child: Center(
                        child: Image.file(
                      File(pickedImage!.path),
                      height: 400,
                    ))),
            SizedBox(height: 20),
            TextField(
              controller: prompt,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.pending_sharp,
                  color: Colors.black,
                ),
                hintText: 'Enter your prompt here',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: () {
                getdata(pickedImage, prompt.text);
              },
              icon: Icon(
                Icons.generating_tokens_rounded,
                color: Colors.white,
              ),
              label: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Generate Answer',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              style: ElevatedButton.styleFrom(
                  // primary: Colors.black,
                  ),
            ),
            SizedBox(height: 30),
            scanning
                ? Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                        child: SpinKitThreeBounce(
                      color: Colors.black,
                      size: 20,
                    )),
                  )
                : Text(mytext,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
