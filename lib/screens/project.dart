import 'dart:io';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  List<String> images = List.generate(
      50,
      (index) =>
          "C:\\Users\\aloks\\Downloads\\NEU Metal Surface Defects Data\\valid\\Crazing\\Cr_11.bmp");

  List<int> selectedIndex = [];

  final spacer = const SizedBox(width: 20);

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
            // getImages();
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
              List<String> temp = [];
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
                      Image.file(
                        File(images[index]),
                        width: 200,
                        height: 200,
                      ),
                      spacer,
                      Image.file(
                        File(images[index]),
                        width: 200,
                        height: 200,
                      ),
                    ],
                  ),
                  subtitle: Text(images[index]),
                  onPressed: () {},
                );
              },
            );
          },
        ),
      ),
    );
  }
}
