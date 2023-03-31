import 'dart:io';

import 'package:dlds/model/dlds_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  List<DLDSImage> images = [];
  List<int> selectedIndex = [];

  final spacer = const SizedBox(width: 20);

  void addNewImages() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<String?> paths = result.paths.toList();
      for (int i = 0; i < paths.length; i++) {
        images.add(await processDLDSImage(File(paths[i]!)));
      }
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
          onPressed: () {
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
              // Delete the selectedIndex
              List<DLDSImage> temp = [];
              for (int i = 0; i < images.length; i++) {
                if (selectedIndex.contains(i)) {
                  continue;
                }
                temp.add(images[i]);
              }
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
                      builder: (context) => ContentDialog(
                        constraints: const BoxConstraints.expand(),
                        title: const Text('Graph of Projections'),
                        content: Row(
                          children: [
                            Expanded(
                              child: SfCartesianChart(
                                tooltipBehavior: TooltipBehavior(enable: true),
                                primaryXAxis: NumericAxis(
                                  title: AxisTitle(text: 'Index'),
                                ),
                                title: ChartTitle(text: 'Left Projection'),
                                series: [
                                  LineSeries(
                                      dataSource: images[index].leftProjection,
                                      xValueMapper: (_, idx) => idx,
                                      yValueMapper: (_, idx) =>
                                          images[index].leftProjection[idx],
                                      name: 'Left Projection'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SfCartesianChart(
                                tooltipBehavior: TooltipBehavior(enable: true),
                                primaryXAxis: NumericAxis(
                                  title: AxisTitle(text: 'Index'),
                                ),
                                title: ChartTitle(text: 'Right Projection'),
                                series: [
                                  LineSeries(
                                      dataSource: images[index].rightProjection,
                                      xValueMapper: (_, idx) => idx,
                                      yValueMapper: (_, idx) =>
                                          images[index].rightProjection[idx],
                                      name: 'Right Projection'),
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
