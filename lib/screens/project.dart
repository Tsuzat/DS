import 'dart:convert';
import 'dart:io';

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

import 'package:dlds/main.dart';
import 'package:dlds/model/dlds_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProjectPage extends StatefulWidget {
  final String projectFileName;
  const ProjectPage({super.key, required this.projectFileName});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late File projectFile;
  late List<String> projectImages;
  late String projectFilePath;
  List<DLDSImage> images = [];
  List<int> selectedIndex = [];

  final spacer = const SizedBox(width: 20);

  void addNewImages() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    if (result != null) {
      List<String?> paths = result.paths.toList();
      for (int i = 0; i < paths.length; i++) {
        images.add(await processDLDSImage(File(paths[i]!)));
        projectImages.add(paths[i]!);
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
    projectImages = [];
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

    for (int i = 0; i < data.length; i++) {
      projectImages.add(data[i].toString());
    }

    // Add the loaded image paths to `List<DLDSImage> images`
    for (String imgPath in projectImages) {
      images.add(await processDLDSImage(File(imgPath)));
    }

    // Re-paint the widget after loading add files
    setState(() {});
  }

  void updateJsonFile() async {
    await projectFile.writeAsString(jsonEncode(projectImages));
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
          message: "Add Images",
          child: w,
        ),
        wrappedItem: CommandBarButton(
          icon: const Icon(FluentIcons.add),
          label: const Text('New'),
          onPressed: () {
            addNewImages();
          },
        ),
      ),
      CommandBarBuilderItem(
        builder: (context, mode, w) => Tooltip(
          message: "Delete",
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
                    'If you delete files, you won\'t be able to recover it. Do you want to delete it?',
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
              List<DLDSImage> temp = [];
              List<String> tmpImages = [];
              for (int i = 0; i < images.length; i++) {
                if (selectedIndex.contains(i)) {
                  continue;
                }
                temp.add(images[i]);
                tmpImages.add(images[i].imgPath);
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
              projectImages = tmpImages;
              updateJsonFile();
              selectedIndex = [];
              setState(() {});
            }
          },
        ),
      ),
      CommandBarButton(
        icon: const Icon(FluentIcons.archive),
        label: const Text('Archive'),
        onPressed: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(
        right: 2,
      ),
      child: ScaffoldPage(
        header: PageHeader(
          title: const Text(
            "Project Name",
          ),
          commandBar: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            overflowBehavior: CommandBarOverflowBehavior.noWrap,
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
                  subtitle: Text(images[index].imgPath),
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

  final DLDSImage image;

  @override
  State<ReportPopUp> createState() => _ReportPopUpState();
}

class _ReportPopUpState extends State<ReportPopUp> {
  final GlobalKey globalKey = GlobalKey();
  final smallSpace = const SizedBox(height: 20);
  bool showGraph = true;
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
                    'Report: Defects on the Steel Surface (Preview)',
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
                if (showGraph)
                  Text(
                    "Graphs of Projection",
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
                                name: 'Left Projection'),
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
                                      widget.image.leftProjection[
                                          widget.image.indexOfLeftPeaks[idx]],
                                  name: 'Peaks')
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
                                name: 'Right Projection'),
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
                                      widget.image.rightProjection[
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
                horizonalLine,
                smallSpace,
                Text(
                  "Peaks in the graphs",
                  style: FluentTheme.of(context).typography.title,
                ),
                if (showPeaks)
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: SelectableText(
                      "Left Peaks: ${widget.image.indexOfLeftPeaks.map((e) => widget.image.leftProjection[e].toStringAsFixed(2)).toList().toString()}\n"
                      "Right Peaks: ${widget.image.indexOfRightPeaks.map((e) => widget.image.rightProjection[e].toStringAsFixed(2)).toList().toString()}",
                    ),
                  )
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
        Button(
          child: const Text("Save as Image"),
          onPressed: () async {
            RenderRepaintBoundary boundary = globalKey.currentContext!
                .findRenderObject() as RenderRepaintBoundary;
            final ui.Image uiImage = await boundary.toImage(pixelRatio: 1);

            // Add the background to image
            final recorder = ui.PictureRecorder();
            final canvas = Canvas(recorder);
            final paint = Paint()
              // ignore: use_build_context_synchronously
              ..color = FluentTheme.of(context).brightness.isDark
                  ? const Color(0xFF272727)
                  : const Color(0xFFf9f9f9);

            canvas.drawRect(
                Rect.fromLTWH(
                    0, 0, uiImage.width.toDouble(), uiImage.height.toDouble()),
                paint);
            canvas.drawImage(uiImage, Offset.zero, Paint());

            // Convert the canvas to a PNG bytes
            final picture = recorder.endRecording();
            final png = await picture.toImage(uiImage.width, uiImage.height);
            final pngByteData =
                await png.toByteData(format: ui.ImageByteFormat.png);
            final pngBytes = pngByteData!.buffer.asUint8List();

            // Get the location of file
            String? imgLocation = await FilePicker.platform.saveFile(
              dialogTitle: "Save To Image",
              fileName: "${fileName}_result.png",
              type: FileType.image,
              allowedExtensions: ["png"],
            );

            if (imgLocation == null || imgLocation.isEmpty) {
              // ignore: use_build_context_synchronously
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('File is not saved'),
                    content: const Text(
                        'The Operation was cancelled by user/system'),
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
            await File(imgLocation).writeAsBytes(pngBytes);
            // ignore: use_build_context_synchronously
            displayInfoBar(
              context,
              builder: (context, close) {
                return InfoBar(
                  title: const Text('File saved sucessfully'),
                  content:
                      Text('The image has been saved on location $imgLocation'),
                  // action: IconButton(
                  //   icon: const Icon(FluentIcons.clear),
                  //   onPressed: close,
                  // ),
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
          },
        ),
        FilledButton(
          child: const Text('Close Pop Up'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
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
