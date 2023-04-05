import 'dart:convert';
import 'dart:io';

import 'package:dlds/main.dart';
import 'package:dlds/model/dlds_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
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
                    const smallSpace = SizedBox(height: 20);
                    await showDialog(
                      context: context,
                      builder: (context) => ContentDialog(
                        constraints: const BoxConstraints.tightFor(),
                        title: const Center(
                            child:
                                Text('Report: Defects on the Steel Surface')),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text("Image Path: ${images[index].imgPath}"),
                                  Text(
                                      "Date: ${DateTime.now().toIso8601String()}")
                                ],
                              ),
                              smallSpace,
                              Text(
                                "Images",
                                style: FluentTheme.of(context).typography.title,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  images[index].originaImage,
                                  images[index].processedImage,
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: const [
                                  Text("Input Image"),
                                  Text("Processed Image"),
                                ],
                              ),
                              smallSpace,
                              Text(
                                "Graphs of Projection",
                                style: FluentTheme.of(context).typography.title,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: SfCartesianChart(
                                      borderColor:
                                          FluentTheme.of(context).accentColor,
                                      borderWidth: 1,
                                      tooltipBehavior:
                                          TooltipBehavior(enable: true),
                                      primaryXAxis: NumericAxis(
                                        title: AxisTitle(text: 'Index'),
                                      ),
                                      title:
                                          ChartTitle(text: 'Left Projection'),
                                      series: [
                                        LineSeries(
                                            dataSource:
                                                images[index].leftProjection,
                                            xValueMapper: (_, idx) => idx,
                                            yValueMapper: (_, idx) =>
                                                images[index]
                                                    .leftProjection[idx],
                                            name: 'Left Projection'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: SfCartesianChart(
                                      borderColor:
                                          FluentTheme.of(context).accentColor,
                                      borderWidth: 1,
                                      tooltipBehavior:
                                          TooltipBehavior(enable: true),
                                      primaryXAxis: NumericAxis(
                                        title: AxisTitle(text: 'Index'),
                                      ),
                                      title:
                                          ChartTitle(text: 'Right Projection'),
                                      series: [
                                        LineSeries(
                                            dataSource:
                                                images[index].rightProjection,
                                            xValueMapper: (_, idx) => idx,
                                            yValueMapper: (_, idx) =>
                                                images[index]
                                                    .rightProjection[idx],
                                            name: 'Right Projection'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        actions: [
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
