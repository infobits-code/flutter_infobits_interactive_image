library infobits_interactive_image;

import 'dart:io';
import 'dart:ui' as ui show Codec, FrameInfo, Image;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:infobits_interactive_image/models/coordinate.dart';

class InfobitsInteractiveImage extends StatefulWidget {
  const InfobitsInteractiveImage({Key? key}) : super(key: key);

  @override
  State<InfobitsInteractiveImage> createState() =>
      _InfobitsInteractiveImageState();
}

class _InfobitsInteractiveImageState extends State<InfobitsInteractiveImage> {
  File? selectedImage;
  ui.Image? decodedImage;
  GlobalKey imageKey = GlobalKey(debugLabel: "image_key");
  List<Coordinate> points = [];

  Future<void> openImage() async {
    debugPrint("Open image");
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      points = [];
      selectedImage = File(result.files.single.path!);
      decodedImage =
          await decodeImageFromList(selectedImage!.readAsBytesSync());
      debugPrint(selectedImage!.path);
      setState(() {});
    } else {
      // User canceled the picker
      debugPrint("cancelled");
    }
  }

  Future<void> onTapDown(TapDownDetails details) async {
    if (selectedImage == null) return;

    // debugPrint(
    //     "dx: ${details.localPosition.dx}, dy: ${details.localPosition.dy}");

    // debugPrint(
    //     "[image] width: ${decodedImage!.width}, height: ${decodedImage!.height}");

    // debugPrint(
    //     "[constraints] width: ${constraints.maxWidth}, height: ${constraints.maxHeight}");

    var imageRatio = getImageRatio();

    var x = details.localPosition.dx * imageRatio.widthRatio;
    var y = details.localPosition.dy * imageRatio.heightRatio;
    var coordinate = Coordinate(x: x, y: y);
    points.add(coordinate);
    debugPrint("Added $coordinate");

    setState(() {});
  }

  BoxRatio getImageRatio() {
    final box = imageKey.currentContext?.findRenderObject() as RenderBox;

    var widthRatio = decodedImage!.width / box.size.width;
    var heightRatio = decodedImage!.height / box.size.height;
    return BoxRatio(widthRatio: widthRatio, heightRatio: heightRatio);
  }

  Future<void> saveCoordinates() async {
    debugPrint("Save coordinates");

    String coordinatesCsv = points.map((e) => "${e.x},${e.y}").join("\n");

    var selectedImagePathParts = selectedImage!.path.split("/");

    String? outputFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName:
          '${selectedImagePathParts[selectedImagePathParts.length - 1]}-points.csv',
    );

    if (outputFilePath != null) {
      var outputFile = await File(outputFilePath).create();
      await outputFile.writeAsString(coordinatesCsv);
    } else {
      debugPrint("error");
    }
  }

  void removeCoordinate(Coordinate coordinate) {
    points.remove(coordinate);
    setState(() {});
  }

  String getImageName() {
    var selectedImagePathParts = selectedImage!.path.split("/");

    return selectedImagePathParts[selectedImagePathParts.length - 1];
  }

  Future<void> openPointsFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["csv"]);

    if (result != null) {
      points = [];
      var pointsFile = File(result.files.single.path!);

      var pointsCsv = await pointsFile.readAsLines();
      for (var line in pointsCsv) {
        points.add(Coordinate.fromString(line));
      }

      setState(() {});
    } else {
      // User canceled the picker
      debugPrint("cancelled");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: GestureDetector(
          onTap: () {
            if (selectedImage == null) {
              openImage();
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            margin: const EdgeInsets.all(10),
            constraints: const BoxConstraints(
              maxWidth: 600,
              minHeight: 400,
            ),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedImage == null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text("Click to Choose Image"),
                  ),
                if (selectedImage != null)
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(getImageName()),
                  )),
                if (selectedImage != null) _buildImageView(),
                if (selectedImage != null)
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Button(
                        text: "Output points",
                        onPressed: saveCoordinates,
                      ),
                      Button(
                        text: "Open new image",
                        onPressed: openImage,
                      ),
                      Button(
                        text: "Open points file",
                        onPressed: openPointsFile,
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildImageView() {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTapDown: (details) => onTapDown(details),
        child: Stack(children: [
          Image.file(
            selectedImage!,
            key: imageKey,
          ),
          for (var coordinate in points)
            Positioned(
              left: (coordinate.x / getImageRatio().widthRatio) - 3,
              top: (coordinate.y / getImageRatio().heightRatio) - 3,
              width: 6,
              height: 6,
              child: GestureDetector(
                onTap: () => removeCoordinate(coordinate),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
            )
        ]),
      );
    });
  }
}

class Button extends StatelessWidget {
  final String text;
  final void Function() onPressed;

  const Button({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(text),
      ),
    );
  }
}

class BoxRatio {
  final double widthRatio;
  final double heightRatio;

  const BoxRatio({required this.widthRatio, required this.heightRatio});
}
