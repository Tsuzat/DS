import 'dart:io';
import 'package:image/image.dart';

List<List<double>> img2mat(File imageFile) {
  var image = decodeImage(imageFile.readAsBytesSync());

  var gimg = grayscale(image!);

  // Convert image to grayscale matrix
  List<List<double>> grayscaleMatrix = [];
  for (int y = 0; y < gimg.height; y++) {
    List<double> row = [];
    for (int x = 0; x < gimg.width; x++) {
      Pixel pixel = gimg.getPixel(x, y);
      double grayValue =
          ((pixel.r * 0.299) + (pixel.g * 0.587) + (pixel.b * 0.114));
      row.add(grayValue);
    }
    grayscaleMatrix.add(row);
  }

  return grayscaleMatrix;
}
