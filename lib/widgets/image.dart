import 'package:flutter/material.dart';

//import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ImageInputState();
  }
}

class ImageInputState extends State<ImageInput> {
  File _imageFile;

//  void _getImage(ImageSource sourse){
//    ImagePicker.pickImage(source: sourse).then((File file){
//        setState(){
//          _imageFile = file;
//        };
//      Navigator.pop(context);
//    });
//  }

  void _openImagePicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text('Use camera'),
                  onPressed: () {
//                    _getImage(ImageSource.camera);
                  },
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text('Use gallery'),
                  onPressed: () {
//                    _getImage(ImageSource.gallery);
                  },
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        OutlineButton(
          borderSide:
              BorderSide(color: Theme.of(context).accentColor, width: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.camera_alt,
                color: Theme.of(context).accentColor,
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                'Add image',
                style: TextStyle(color: Theme.of(context).accentColor),
              )
            ],
          ),
          onPressed: _openImagePicker,
        ),
        SizedBox(
          height: 10.0,
        ),
        _imageFile == null
            ? Text('Please pick an image')
            : Image.file(
                _imageFile,
                fit: BoxFit.cover,
                height: 300.0,
                alignment: Alignment.topCenter,
              )
      ],
    );
  }
}
