import 'dart:io';

import 'package:dlds/backend/server.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:image/image.dart' as nimg;

class DLDSImage {
  /// Name/Path of the original image
  String imgPath;

  /// Image File that holds information for original image
  Image originaImage;

  /// Image File that holds information for processedImage
  final Image processedImage;

  /// Left Projection of original Image
  List<double> leftProjection;

  /// Right Projection of original Image
  List<double> rightProjection;

  /// index of Peaks in leftProjection
  List<int> indexOfLeftPeaks;

  /// index of Peaks in leftProjection
  List<int> indexOfRightPeaks;

  DLDSImage(
      this.imgPath,
      this.originaImage,
      this.processedImage,
      this.leftProjection,
      this.rightProjection,
      this.indexOfLeftPeaks,
      this.indexOfRightPeaks);
}

//! TODO : The Logic is not working as expected. Need to debug the code

Future<DLDSImage> processDLDSImage(File image) async {
  String imgPath = image.path;
  Map<String, dynamic> sendData = {"img_paths": imgPath};
  Map<String, dynamic> recvData = await svdBackEnd(sendData);
  // Received data is a map with keys as "left" and "right"
  // and values as List<dynamic>
  List<double> leftProjection = [];
  List<double> rightProjection = [];
  for (int i = 0; i < recvData['left'].length; i++) {
    leftProjection.add(recvData['left'][i] as double);
  }
  for (int i = 0; i < recvData['right'].length; i++) {
    rightProjection.add(recvData['right'][i] as double);
  }

  List<double> leftProjectionAbs = absOfList(leftProjection);
  List<double> rightProjectionAbs = absOfList(rightProjection);

  // Finding the average of left and right projection with absolute values
  double leftAvg = average(leftProjectionAbs);
  double rightAvg = average(rightProjectionAbs);

  // find the peaks of left and right projection based on the average(tolerance)
  List<int> leftPeaks = indexOfPeaks(leftProjectionAbs, leftAvg);
  List<int> rightPeaks = indexOfPeaks(rightProjectionAbs, rightAvg);

  // a List<List<double> that has dimensions of the image and initialized with 0
  List<List<double>> img = List.generate(
      leftProjection.length, (index) => List.filled(rightProjection.length, 0));

  // Set of visited values
  List<bool> colVisited = List.generate(img[0].length, (index) => false);
  // Iterate for each value of leftPeaks as Columns in Matrix
  for (int val in leftPeaks) {
    // We will check all rows near by leftPeaks[i] whose values are greater than tolerance
    int leftPointer = val;
    int rightPointer = val + 1;
    // Left Pointer appends the values in the row by on the moves to left
    // it will stop is leftProjectionAbs[leftPointer] < tolerance or leftPointer < 0
    while (leftPointer >= 0 && leftProjectionAbs[leftPointer] > leftAvg) {
      // increase the value of each element in row by 1 in matrix
      if (colVisited[leftPointer] == true) {
        leftPointer--;
        continue;
      } else {
        colVisited[leftPointer] = true;
        for (int i = 0; i < img[0].length; i++) {
          img[i][leftPointer] += 1;
        }
        leftPointer--;
      }
    }
    // Do the same for rightPonter
    while (rightPointer < leftPeaks.length &&
        leftProjection[rightPointer] > leftAvg) {
      if (colVisited[rightPointer] == true) {
        rightPointer++;
        continue;
      } else {
        colVisited[rightPointer] = true;
        for (int i = 0; i < img[0].length; i++) {
          img[i][rightPointer] += 1;
        }
        rightPointer++;
      }
    }
  }

  List<bool> rowVisited = List.generate(img.length, (index) => false);
  // Iterate for each value of rightPeaks as rows in Matrix
  for (int val in rightPeaks) {
    int leftPointer = val;
    int rightPointer = val + 1;
    while (leftPointer >= 0 && rightProjectionAbs[leftPointer] > rightAvg) {
      if (rowVisited[leftPointer] == true) {
        leftPointer--;
        continue;
      } else {
        rowVisited[leftPointer] = true;
        for (int i = 0; i < img.length; i++) {
          img[leftPointer][i] += 1;
        }
        leftPointer--;
      }
    }
    while (rightPointer < rightPeaks.length &&
        rightProjection[rightPointer] > rightAvg) {
      if (rowVisited[rightPointer] == true) {
        rightPointer++;
        continue;
      } else {
        rowVisited[rightPointer] = true;
        for (int i = 0; i < img.length; i++) {
          img[rightPointer][i] += 1;
        }
        rightPointer++;
      }
    }
  }

  // Image Processing Based on img matrix
  // Load the image
  nimg.Image? rawImg = nimg.decodeImage(image.readAsBytesSync());
  rawImg = nimg.decodeJpg(nimg.encodeJpg(rawImg!));
  for (int i = 0; i < img.length; i++) {
    for (int j = 0; j < img[0].length; j++) {
      if (img[i][j] > 1) {
        rawImg = nimg.drawPixel(
          rawImg!,
          j,
          i,
          nimg.ColorRgba8(255, 0, 0, 255),
          alpha: 0.5,
        );
      }
    }
  }

  Image processedImage = Image.memory(nimg.encodeJpg(rawImg!));
  return DLDSImage(image.path, Image.file(image), processedImage,
      leftProjection, rightProjection, leftPeaks, rightPeaks);
}

/// Returns the average of values of all elements in the list
double average(List<double> arr) {
  double avg = 0;
  for (int i = 0; i < arr.length; i++) {
    avg += arr[i];
  }
  avg /= arr.length;
  return avg;
}

/// Returns the index of all peaks in the list
List<int> indexOfPeaks(List<double> arr, double tolerance) {
  List<int> peaks = [];
  for (int i = 1; i < arr.length - 1; i++) {
    if (arr[i] < tolerance) continue;
    if (arr[i - 1] < arr[i] && arr[i] >= arr[i + 1]) {
      peaks.add(i);
    }
  }
  return peaks;
}

/// Returns the List with absolute values
List<double> absOfList(List<double> arr) {
  List<double> absArr = [];
  for (int i = 0; i < arr.length; i++) {
    absArr.add(arr[i].abs());
  }
  return absArr;
}
