import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

import 'package:ds/main.dart';
import 'package:ds/model/ds_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key, required this.projectFileName});

  final String projectFileName;

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late File projectFile;
  late String projectFilePath;
  List<DSImage> images = [];
  List<int> selectedIndex = [];

  final spacer = const SizedBox(width: 20);

  void addNewImages() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    if (result != null) {
      List<String?> paths = result.paths.toList();
      for (String? path in paths) {
        images.add(await processDLDSImage(
          imagePath: path!,
          leftProjection: [],
          rightProjection: [],
        ));
      }
      // Update Project Images and repaint the widget
      updateJsonFile();
      setState(() {});
    } else {
      return;
    }
  }

  void loadProject() async {
    projectFilePath = "$appDir\\Projects\\${widget.projectFileName}";
    // read json file path
    projectFile = File(projectFilePath);
    // If projectFile does not exists then create one
    if (!await projectFile.exists()) {
      // Create the file and dump empty list in it
      await projectFile.create();
      await projectFile.writeAsString(jsonEncode([]));
    }
    // Load the project
    // read the file and decode into json
    String tmp = await projectFile.readAsString();
    var data = jsonDecode(tmp);

    // Add the loaded image paths to `List<DLDSImage> images`
    for (int i = 0; i < data.length; i++) {
      String imagePath = data[i]["path"].toString();
      // convert List<dynamic> to List<double>
      List<int> leftProjection = [];
      for (var i in data[i]["left"]) {
        leftProjection.add(i.toInt());
      }
      List<int> rightProjection = [];
      for (var i in data[i]["right"]) {
        rightProjection.add(i.toInt());
      }
      images.add(
        await processDLDSImage(
          imagePath: imagePath,
          leftProjection: leftProjection,
          rightProjection: rightProjection,
        ),
      );
    }

    // Re-paint the widget after loading add files
    setState(() {});
  }

  void updateJsonFile() async {
    List<Map<String, dynamic>> data = images
        .map((e) => {
              "path": e.imgPath,
              "left": e.leftProjection,
              "right": e.rightProjection,
            })
        .toList();
    await projectFile.writeAsString(jsonEncode(data));
  }

  @override
  void initState() {
    loadProject();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Define list of CommandBarItem
    final simpleCommandBarItems = <CommandBarItem>[
      CommandBarBuilderItem(
        builder: (context, mode, w) => Tooltip(
          message: "Add New Images in Project",
          child: w,
        ),
        wrappedItem: CommandBarButton(
          icon: const Icon(FluentIcons.add),
          label: const Text('Add'),
          onPressed: () {
            addNewImages();
          },
        ),
      ),
      CommandBarBuilderItem(
        builder: (context, mode, w) => Tooltip(
          message: "Delete Selected Images",
          child: w,
        ),
        wrappedItem: CommandBarButton(
          icon: const Icon(FluentIcons.delete),
          label: const Text('Delete'),
          onPressed: () async {
            // if selectedIndex is empty give a info message
            if (selectedIndex.isEmpty) {
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('You have not selected any item(s)'),
                    action: IconButton(
                      icon: const Icon(FluentIcons.clear),
                      onPressed: close,
                    ),
                    severity: InfoBarSeverity.warning,
                  );
                },
              );
            } else {
              // Before deleting the files ask for confirmation
              bool? confirmDelete = await showDialog<bool>(
                context: context,
                builder: (context) => ContentDialog(
                  title: const Text('Delete files permanently?'),
                  content: const Text(
                    'If you delete files, you won\'t be able to recover it. '
                    'Don\'t worry, file will not be deleted from your system but just from this project. '
                    'Do you want to delete it?',
                  ),
                  actions: [
                    Button(
                      child: const Text('Delete'),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                    FilledButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
              );
              // if user cancels delete, return
              if (confirmDelete! == false) return;
              // Delete the selectedIndex
              List<DSImage> temp = [];
              for (int i = 0; i < images.length; i++) {
                if (selectedIndex.contains(i)) {
                  continue;
                }
                temp.add(images[i]);
              }
              // ignore: use_build_context_synchronously
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text(
                        'Selected Items have beed deleted Successfully'),
                    action: IconButton(
                      icon: const Icon(FluentIcons.clear),
                      onPressed: close,
                    ),
                    severity: InfoBarSeverity.success,
                  );
                },
              );
              images = temp;
              updateJsonFile();
              selectedIndex = [];
              setState(() {});
            }
          },
        ),
      ),
      if (selectedIndex.isNotEmpty)
        CommandBarButton(
          icon: const Icon(FluentIcons.multi_select),
          label: Text(selectedIndex.length == images.length
              ? 'Unselect All'
              : 'Select All'),
          onPressed: () {
            if (selectedIndex.length == images.length) {
              selectedIndex = [];
            } else {
              selectedIndex = [];
              selectedIndex.addAll(
                List.generate(images.length, (index) => index),
              );
            }
            setState(() {});
          },
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(
        right: 2,
      ),
      child: ScaffoldPage(
        header: PageHeader(
          title: Text(widget.projectFileName.replaceAll('.json', '')),
          commandBar: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
            primaryItems: [
              ...simpleCommandBarItems,
            ],
          ),
        ),
        content: LayoutBuilder(
          builder: (context, contrains) {
            double width = contrains.maxWidth;
            return GridView.builder(
              itemCount: images.length,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (width ~/ 500),
                childAspectRatio: 2,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    children: [
                      Checkbox(
                        checked: selectedIndex.contains(index),
                        onChanged: (value) {
                          setState(
                            () {
                              if (selectedIndex.contains(index)) {
                                selectedIndex.remove(index);
                              } else {
                                selectedIndex.add(index);
                              }
                            },
                          );
                        },
                      ),
                      spacer,
                      Image(
                        image: images[index].originaImage.image,
                        width: 200,
                        height: 200,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.fill,
                      ),
                      spacer,
                      Image(
                        image: images[index].processedImage.image,
                        width: 200,
                        height: 200,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(images[index].imgPath),
                      Text(
                          "Defect: ${images[index].percentageOfDefect.toStringAsFixed(2)}%")
                    ],
                  ),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => ReportPopUp(image: images[index]),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ReportPopUp extends StatefulWidget {
  const ReportPopUp({
    super.key,
    required this.image,
  });

  final DSImage image;

  @override
  State<ReportPopUp> createState() => _ReportPopUpState();
}

class _ReportPopUpState extends State<ReportPopUp> {
  final GlobalKey globalKey = GlobalKey();
  final smallSpace = const SizedBox(height: 20);
  bool showGraph = true;
  bool showAbsGraph = true;
  bool showPeaks = true;
  bool showPeaksOnGraph = true;
  @override
  Widget build(BuildContext context) {
    final horizonalLine = Container(
      height: 1,
      margin: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width,
      color: const Color.fromARGB(255, 109, 109, 109),
    );
    var datetime = DateTime.now();
    String date = datetime
        .toIso8601String()
        .substring(0, 10)
        .split("-")
        .reversed
        .join("-");
    String fileName = extractFileName(widget.image.imgPath);
    return ContentDialog(
      constraints: const BoxConstraints.tightFor(),
      // title: const Center(
      //   child: Text('Report: Defects on the Steel Surface (Preview)'),
      // ),
      content: SingleChildScrollView(
        child: RepaintBoundary(
          key: globalKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PageHeader(
                  title: Text(
                    'Report: Defects on the Steel Surface',
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Image Path: ${widget.image.imgPath}"),
                    Text("Date: $date")
                  ],
                ),
                smallSpace,
                Text(
                  "Images",
                  style: FluentTheme.of(context).typography.title,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        widget.image.originaImage,
                        const Text("Input Image"),
                      ],
                    ),
                    FluentTheme.of(context).brightness.isDark
                        ? SvgPicture.asset("assets/arrow_white.svg")
                        : SvgPicture.asset("assets/arrow_black.svg"),
                    Column(
                      children: [
                        widget.image.processedImage,
                        const Text("Processed Output Image"),
                      ],
                    ),
                  ],
                ),
                horizonalLine,
                smallSpace,
                if (showGraph || showAbsGraph)
                  Text(
                    "Graphs of Projections",
                    style: FluentTheme.of(context).typography.title,
                  ),
                if (showGraph)
                  Row(
                    children: [
                      Expanded(
                        child: SfCartesianChart(
                          // borderColor: FluentTheme.of(context).accentColor,
                          // borderWidth: 1,
                          tooltipBehavior: TooltipBehavior(enable: true),
                          primaryXAxis: NumericAxis(
                            title: AxisTitle(text: 'Index for Columns'),
                          ),
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(text: 'Values'),
                          ),
                          title: ChartTitle(text: 'Left Projection'),
                          series: [
                            LineSeries(
                              dataSource: widget.image.leftProjection,
                              xValueMapper: (_, idx) => idx,
                              yValueMapper: (_, idx) =>
                                  widget.image.leftProjection[idx],
                              name: 'Left Projection',
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SfCartesianChart(
                          // borderColor: FluentTheme.of(context).accentColor,
                          // borderWidth: 1,
                          tooltipBehavior: TooltipBehavior(enable: true),
                          primaryXAxis: NumericAxis(
                            title: AxisTitle(text: 'Index for Rows'),
                          ),
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(text: 'Values'),
                          ),
                          title: ChartTitle(text: 'Right Projection'),
                          series: [
                            LineSeries(
                              dataSource: widget.image.rightProjection,
                              xValueMapper: (_, idx) => idx,
                              yValueMapper: (_, idx) =>
                                  widget.image.rightProjection[idx],
                              name: 'Right Projection',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                smallSpace,
                if (showAbsGraph)
                  Row(
                    children: [
                      Expanded(
                        child: SfCartesianChart(
                          tooltipBehavior: TooltipBehavior(enable: true),
                          primaryXAxis: NumericAxis(
                            title: AxisTitle(text: 'Index for Columns'),
                          ),
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(text: 'Values'),
                          ),
                          title: ChartTitle(text: 'Left Absolute Projection'),
                          series: [
                            LineSeries(
                                dataSource: widget.image.leftAbsProjection,
                                xValueMapper: (_, idx) => idx,
                                yValueMapper: (_, idx) =>
                                    widget.image.leftAbsProjection[idx],
                                name: 'Left Absolute Projection'),
                            if (showPeaksOnGraph)
                              LineSeries(
                                  animationDelay: 0,
                                  animationDuration: 0,
                                  enableTooltip: false,
                                  color: Colors.transparent,
                                  markerSettings: MarkerSettings(
                                    isVisible: true,
                                    color: FluentTheme.of(context).accentColor,
                                    shape: DataMarkerType.circle,
                                    borderWidth: 0,
                                  ),
                                  dataSource: widget.image.indexOfLeftPeaks,
                                  xValueMapper: (_, idx) =>
                                      widget.image.indexOfLeftPeaks[idx],
                                  yValueMapper: (_, idx) =>
                                      widget.image.leftAbsProjection[
                                          widget.image.indexOfLeftPeaks[idx]],
                                  name: 'Peaks')
                          ],
                        ),
                      ),
                      Expanded(
                        child: SfCartesianChart(
                          tooltipBehavior: TooltipBehavior(enable: true),
                          primaryXAxis: NumericAxis(
                            title: AxisTitle(text: 'Index for Rows'),
                          ),
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(text: 'Values'),
                          ),
                          title: ChartTitle(text: 'Right Absolute Projection'),
                          series: [
                            LineSeries(
                                dataSource: widget.image.rightAbsProjection,
                                xValueMapper: (_, idx) => idx,
                                yValueMapper: (_, idx) =>
                                    widget.image.rightAbsProjection[idx],
                                name: 'Right Absolute Projection'),
                            if (showPeaksOnGraph)
                              LineSeries(
                                  animationDelay: 0,
                                  animationDuration: 0,
                                  enableTooltip: false,
                                  color: Colors.transparent,
                                  markerSettings: MarkerSettings(
                                    isVisible: true,
                                    color: FluentTheme.of(context).accentColor,
                                    shape: DataMarkerType.circle,
                                    borderWidth: 0,
                                  ),
                                  dataSource: widget.image.indexOfRightPeaks,
                                  xValueMapper: (_, idx) =>
                                      widget.image.indexOfRightPeaks[idx],
                                  yValueMapper: (_, idx) =>
                                      widget.image.rightAbsProjection[
                                          widget.image.indexOfRightPeaks[idx]],
                                  name: 'Peaks')
                          ],
                        ),
                      ),
                    ],
                  ),
                if (showGraph)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Graph Indications: "),
                      const SizedBox(
                        width: 40,
                      ),
                      Icon(
                        FluentIcons.chrome_minimize,
                        color: FluentTheme.of(context).accentColor,
                      ),
                      const SizedBox(width: 10),
                      const Text("Projection Graph"),
                      const SizedBox(width: 30),
                      Icon(
                        FluentIcons.circle_fill,
                        color: FluentTheme.of(context).accentColor,
                      ),
                      const SizedBox(width: 10),
                      const Text("Peak Points in Graph")
                    ],
                  ),
                if (showAbsGraph || showGraph) horizonalLine,
                smallSpace,
                Text(
                  "Result",
                  style: FluentTheme.of(context).typography.title,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: SelectableText.rich(
                    TextSpan(
                      children: [
                        if (showPeaks)
                          TextSpan(
                            text: "Left Peaks: ",
                            style: TextStyle(
                              color: FluentTheme.of(context).accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (showPeaks)
                          TextSpan(
                            text: widget.image.indexOfLeftPeaks
                                .map((e) => widget.image.leftAbsProjection[e]
                                    .toString())
                                .toList()
                                .toString(),
                          ),
                        if (showPeaks)
                          TextSpan(
                            text: "\nRight Peaks: ",
                            style: TextStyle(
                              color: FluentTheme.of(context).accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (showPeaks)
                          TextSpan(
                            text: widget.image.indexOfRightPeaks
                                .map((e) => widget.image.rightAbsProjection[e]
                                    .toString())
                                .toList()
                                .toString(),
                          ),
                        TextSpan(
                          text: "\nPercentage of Defect: ",
                          style: TextStyle(
                            color: FluentTheme.of(context).accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                              "${widget.image.percentageOfDefect.toStringAsFixed(2)} %",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        RadioButton(
            checked: showGraph,
            content: const Text("Show Graph"),
            onChanged: (v) => setState(() {
                  showGraph = v;
                })),
        RadioButton(
            checked: showAbsGraph,
            content: const Text("Show Absolute Graph"),
            onChanged: (v) => setState(() {
                  showAbsGraph = v;
                })),
        RadioButton(
            checked: showPeaks,
            content: const Text("Show Peaks (Values)"),
            onChanged: (v) => setState(() {
                  showPeaks = v;
                })),
        RadioButton(
            checked: showPeaksOnGraph,
            content: const Text("Show Peaks (On Graphs)"),
            onChanged: (v) => setState(() {
                  showPeaksOnGraph = v;
                })),
        DropDownButton(
          title: const Text("Save as"),
          items: [
            MenuFlyoutItem(
              text: const Text("Image with backgound"),
              onPressed: () async {
                // get widget as image
                Uint8List pngBytes = await widgetToImage(
                  globalKey: globalKey,
                  isDark: FluentTheme.of(context).brightness.isDark,
                  withBG: true,
                  pixelRatio: 10,
                );

                // ignore: use_build_context_synchronously
                saveByteDataIntoFile(
                    fileName: "${fileName}_report.png",
                    context: context,
                    dataInBytes: pngBytes,
                    fileType: FileType.image,
                    allowedExtensions: ["png"]);
              },
            ),
            MenuFlyoutItem(
              text: const Text("transparent image"),
              onPressed: () async {
                // get widget as image
                Uint8List pngBytes = await widgetToImage(
                  globalKey: globalKey,
                  isDark: FluentTheme.of(context).brightness.isDark,
                  withBG: false,
                  pixelRatio: 10,
                );

                // ignore: use_build_context_synchronously
                saveByteDataIntoFile(
                    fileName: "${fileName}_report.png",
                    context: context,
                    dataInBytes: pngBytes,
                    fileType: FileType.image,
                    allowedExtensions: ["png"]);
              },
            ),
            MenuFlyoutItem(
                text: const Text("PDF"),
                onPressed: () async {
                  // get widget as image
                  Uint8List pngBytes = await widgetToImage(
                    globalKey: globalKey,
                    isDark: FluentTheme.of(context).brightness.isDark,
                    withBG: true,
                    pixelRatio: 10,
                  );

                  final pwImage = pw.MemoryImage(pngBytes);

                  final document = pw.Document();
                  document.addPage(
                    pw.Page(
                      pageFormat: PdfPageFormat(pwImage.width!.toDouble(),
                          pwImage.height!.toDouble()),
                      build: (pw.Context context) {
                        return pw.Center(
                          child: pw.Image(pw.MemoryImage(pngBytes)),
                        );
                      },
                    ),
                  );

                  // ignore: use_build_context_synchronously
                  saveByteDataIntoFile(
                      fileName: "${fileName}_report.pdf",
                      context: context,
                      dataInBytes: await document.save(),
                      // fileType: FileType.custom,
                      allowedExtensions: ["pdf"]);
                })
          ],
        ),
        FilledButton(
          child: const Text('Close Pop Up'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

/// Function to save file with provided context and data as bytes
void saveByteDataIntoFile(
    {required String fileName,
    required BuildContext context,
    required List<int> dataInBytes,
    FileType fileType = FileType.any,
    List<String>? allowedExtensions}) async {
  // Get the location of file
  String? imgLocation = await FilePicker.platform.saveFile(
    dialogTitle: "Save To Image",
    fileName: fileName,
    type: fileType,
    allowedExtensions: allowedExtensions,
  );

  if (imgLocation == null || imgLocation.isEmpty) {
    // ignore: use_build_context_synchronously
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('File is not saved'),
          content: const Text('The Operation was cancelled by user/system'),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.warning,
        );
      },
    );
    return;
  }
  await File(imgLocation).writeAsBytes(dataInBytes);
  // ignore: use_build_context_synchronously
  displayInfoBar(
    context,
    builder: (context, _) {
      return InfoBar(
        title: const Text('File saved sucessfully'),
        content: Text('The image has been saved on location $imgLocation'),
        action: Button(
          child: const Text("Open File"),
          onPressed: () async {
            await Process.run('explorer.exe', [imgLocation]);
          },
        ),
        severity: InfoBarSeverity.success,
      );
    },
  );
}

/// Function to get widget as an image. It takes following options
/// - globalKey [required] : `GlobalKey()` that has been passed as RepaintBoundary Key
/// - withBG: Weather you want to have image an backgound or not, default is `true`
/// - pixelRation: Default is 1 but can be increased for better image quality
/// - isDark [required]: to check if theme of the app is dark or light
Future<Uint8List> widgetToImage(
    {required GlobalKey globalKey,
    bool withBG = true,
    double pixelRatio = 1,
    required bool isDark}) async {
  RenderRepaintBoundary boundary =
      globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final ui.Image uiImage = await boundary.toImage(pixelRatio: 3);

  // Add the background to image
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()
    ..color = withBG
        ? (isDark ? const Color(0xFF272727) : const Color(0xFFf9f9f9))
        : Colors.transparent;

  canvas.drawRect(
      Rect.fromLTWH(0, 0, uiImage.width.toDouble(), uiImage.height.toDouble()),
      paint);
  canvas.drawImage(uiImage, Offset.zero, Paint());

  // Convert the canvas to a PNG bytes
  final picture = recorder.endRecording();
  final png = await picture.toImage(uiImage.width, uiImage.height);
  final pngByteData = await png.toByteData(format: ui.ImageByteFormat.png);
  return pngByteData!.buffer.asUint8List();
}

/// Function that gives the name of file without the extension
String extractFileName(String filePath) {
  // Find the last index of the path separator (\ or /)
  int separatorIndex = filePath.lastIndexOf(Platform.pathSeparator);

  // Get the substring after the separator (i.e., the file name with extension)
  String fileName = filePath.substring(separatorIndex + 1);

  // Find the last index of the dot (.) in the file name
  int dotIndex = fileName.lastIndexOf('.');

  // Get the substring before the dot (i.e., the file name without extension)
  String imageName = fileName.substring(0, dotIndex);

  return imageName;
}
