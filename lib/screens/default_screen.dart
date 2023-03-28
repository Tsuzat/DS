import 'dart:io';

import 'package:dlds/backend/server.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:image/image.dart' as img;
import 'package:syncfusion_flutter_charts/charts.dart';

class DefaultScreen extends StatefulWidget {
  const DefaultScreen({super.key});

  @override
  State<DefaultScreen> createState() => _DefaultScreenState();
}

class _DefaultScreenState extends State<DefaultScreen> {
  List<File> files = [];

  void getImages() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      files = result.paths.map((path) => File(path!)).toList();
      setState(() {});
    } else {
      return;
    }
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
            getImages();
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
          onPressed: () {},
        ),
      ),
      CommandBarButton(
        icon: const Icon(FluentIcons.archive),
        label: const Text('Archive'),
        onPressed: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: ScaffoldPage.scrollable(
        header: PageHeader(
          title: const Text(
            "Image Picker",
          ),
          commandBar: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            overflowBehavior: CommandBarOverflowBehavior.noWrap,
            primaryItems: [
              ...simpleCommandBarItems,
            ],
          ),
        ),
        children: [
          ...files.map((imgFile) {
            Map<String, dynamic> data = {"img_paths": imgFile.path};
            return FutureBuilder(
              future: svdBackEnd(data),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final rData = snapshot.data;

                  // Store leftProjection and rightProjection in a List<double>
                  // where rData['left'] and rData['right'] are List<dynamic>

                  List<double> leftProjection = [];

                  for (int i = 0; i < rData!['left'].length; i++) {
                    leftProjection.add(rData['left'][i] as double);
                  }

                  List<double> rightProjection = [];

                  for (int i = 0; i < rData['right'].length; i++) {
                    rightProjection.add(rData['right'][i] as double);
                  }

                  // Store the index of absolute maximum of all values in leftProjection and rightProjection

                  final leftMaxIndex = leftProjection
                      .asMap()
                      .entries
                      .reduce((a, b) => a.value.abs() > b.value.abs() ? a : b)
                      .key;

                  final rightMaxIndex = rightProjection
                      .asMap()
                      .entries
                      .reduce((a, b) => a.value.abs() > b.value.abs() ? a : b)
                      .key;

                  img.Image? rawImg =
                      img.decodeImage(imgFile.readAsBytesSync());

                  // rawImg = img.decodeJpg(img.encodeJpg(rawImg!));

                  final newImg = img.drawRect(
                    rawImg!,
                    x1: leftMaxIndex - 10,
                    x2: leftMaxIndex + 10,
                    y1: rightMaxIndex - 10,
                    y2: rightMaxIndex + 10,
                    color: img.ColorRgba8(255, 0, 0, 255),
                  );

                  final imgToDisp = img.encodeJpg(newImg);
                  Image imgTrail = Image.memory(imgToDisp);

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.file(imgFile),
                        imgTrail,
                      ],
                    ),
                    // trailing: imgTrail,
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => ContentDialog(
                          constraints: const BoxConstraints.expand(),
                          title: const Text('Graph of Projections'),
                          content: Row(
                            children: [
                              Expanded(
                                child: SfCartesianChart(
                                  tooltipBehavior:
                                      TooltipBehavior(enable: true),
                                  primaryXAxis: NumericAxis(
                                    title: AxisTitle(text: 'Index'),
                                  ),
                                  title: ChartTitle(text: 'Left Projection'),
                                  series: [
                                    LineSeries(
                                        dataSource: leftProjection,
                                        xValueMapper: (_, idx) => idx,
                                        yValueMapper: (_, idx) =>
                                            leftProjection[idx],
                                        name: 'Left Projection'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SfCartesianChart(
                                  tooltipBehavior:
                                      TooltipBehavior(enable: true),
                                  primaryXAxis: NumericAxis(
                                    title: AxisTitle(text: 'Index'),
                                  ),
                                  title: ChartTitle(text: 'Right Projection'),
                                  series: [
                                    LineSeries(
                                        dataSource: rightProjection,
                                        xValueMapper: (_, idx) => idx,
                                        yValueMapper: (_, idx) =>
                                            rightProjection[idx],
                                        name: 'Left Projection'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            // Button(
                            //   child: const Text('Delete'),
                            //   onPressed: () {
                            //     Navigator.pop(context, 'User deleted file');
                            //     // Delete file here
                            //   },
                            // ),
                            FilledButton(
                              child: const Text('Close Pop Up'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                      setState(() {});
                    },
                  );
                }
                return const ProgressBar();
              },
            );
          }),
        ],
      ),
    );
  }
}
