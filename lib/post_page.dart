import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum checkCondition {
  notChecked,
  hasFace,
  noFace,
}

extension ButtonText on checkCondition {
  String get text {
    switch (this) {
      case checkCondition.notChecked:
        return "認証する";
      case checkCondition.hasFace:
        return "顔あり";
      case checkCondition.noFace:
        return "顔なし";
    }
    assert(false, "Unexpected state");
    return null;
  }
}

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<File> _images = [];
  List<checkCondition> _conditions = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ML KIT FACE CHECKER"),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(width: 0.5)),
                child: Row(
                  children: [
                    Image.file(
                      _images[index],
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(_conditions[index].text),
                    const Spacer(),
                    RaisedButton(
                      onPressed: () {
                        _startVerification(index);
                      },
                      child: Text("検出する"),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                  ],
                ));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage1,
        child: Icon(Icons.add),
      ),
    );
  }

  void _pickImage1() async {
    var imageSource = ImageSource.gallery;

    try {
      final file = await ImagePicker().getImage(source: imageSource);
      setState(() {
        _images.add(File(file.path));
        _conditions.add(checkCondition.notChecked);
      });
      if (file == null) {
        throw Exception('ファイルを取得できませんでした');
      }
    } catch (e) {}
  }

  void _startVerification(int selectedIndex) async {
    final FaceDetectorOptions options =
        FaceDetectorOptions(enableTracking: true, enableContours: false);
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(_images[selectedIndex]);
    final FaceDetector faceDetector =
        FirebaseVision.instance.faceDetector(options);
    final test = await faceDetector.processImage(visionImage);
    setState(() {
      _conditions[selectedIndex] =
          test.isNotEmpty ? checkCondition.hasFace : checkCondition.noFace;
    });
    faceDetector.close();
  }
}

class ImageItem extends StatelessWidget {
  final File image;
  final int index;

  ImageItem(this.index, this.image);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text("image$index"),
        SizedBox(
          height: 60,
          width: 60,
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
