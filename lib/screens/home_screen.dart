// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'package:camera_app/screens/image_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

ValueNotifier<List> imageList = ValueNotifier([]);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final imagePick = ImagePicker();

pickImage() async {
  final imagePick = await ImagePicker().pickImage(source: ImageSource.camera);
  if (imagePick == null) {
    return;
  } else {
    var dir = await getExternalStorageDirectory();
    File imagePath = File(imagePick.path);
    final newImage = await imagePath.copy('${dir!.path}/${DateTime.now()}.jpg');
    imageList.value.add(newImage.path);
    imageList.notifyListeners();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
        centerTitle: true,
      ),
      floatingActionButton: Container(
        height: 100,
        width: 100,
        padding: const EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {
            pickImage();
          },
          child: const Icon(
            Icons.camera_enhance_outlined,
            size: 35,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ValueListenableBuilder(
        valueListenable: imageList,
        builder: ((BuildContext context, List data, Widget? _) {
          return GridView.builder(
            itemCount: data.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 3, crossAxisSpacing: 3),
            itemBuilder: (BuildContext context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageScreen(img: data[index]),
                    ),
                  );
                },
                child: Hero(
                  tag: index,
                  child: Image(
                    fit: BoxFit.fill,
                    image: FileImage(
                      File(data[index]),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

createList() async {
  final dir = await getExternalStorageDirectory();
  if (dir != null) {
    var listDir = await dir.list().toList();
    for (var i = 0; i < listDir.length; i++) {
      if (listDir[i].path.endsWith('.jpg')) {
        imageList.value.add(listDir[i].path);
        imageList.notifyListeners();
      }
    }
  }
}
