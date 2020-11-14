import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum CheckCondition {
  notChecked,
  hasFace,
  noFace,
}

extension ButtonText on CheckCondition {
  String get text {
    switch (this) {
      case CheckCondition.notChecked:
        return "認証する";
      case CheckCondition.hasFace:
        return "顔あり";
      case CheckCondition.noFace:
        return "顔なし";
    }
    assert(false, "Unexpected state");
    return null;
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<File> _images = [];
  List<CheckCondition> _conditions = [];

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
        child: (_images.length == 0)
            ? Text("ボタンで写真を追加してください")
            : ListView.builder(
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return _ItemCell(
                    image: _images[index],
                    checkCondition: _conditions[index],
                    checkImage: () => checkImage(index),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.add),
      ),
    );
  }

  void _pickImage() async {
    var imageSource = ImageSource.gallery;

    try {
      final file = await ImagePicker().getImage(source: imageSource);
      setState(() {
        _images.add(File(file.path));
        _conditions.add(CheckCondition.notChecked);
      });
      if (file == null) {
        throw Exception('ファイルを取得できませんでした');
      }
    } catch (e) {}
  }

  void checkImage(int selectedIndex) async {
    final FaceDetectorOptions options =
        FaceDetectorOptions(enableTracking: true, enableContours: false);
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(_images[selectedIndex]);
    final FaceDetector faceDetector =
        FirebaseVision.instance.faceDetector(options);
    final test = await faceDetector.processImage(visionImage);
    setState(() {
      _conditions[selectedIndex] =
          test.isNotEmpty ? CheckCondition.hasFace : CheckCondition.noFace;
    });
    faceDetector.close();
  }
}

class _ItemCell extends StatelessWidget {
  const _ItemCell({
    Key key,
    @required this.image,
    @required this.checkCondition,
    @required this.checkImage,
  }) : super(key: key);
  final File image;
  final CheckCondition checkCondition;
  final VoidCallback checkImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(width: 0.5)),
      child: Row(
        children: [
          Image.file(
            image,
            width: 64,
            height: 64,
          ),
          const SizedBox(
            width: 16,
          ),
          Text(checkCondition.text),
          const Spacer(),
          RaisedButton(
            onPressed: () {
              checkImage();
            },
            child: Text("検出する"),
          ),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
    );
  }
}
