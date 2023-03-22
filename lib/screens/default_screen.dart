import 'dart:io';

import 'package:dlds/utils/img2graymat.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';

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
          ...files.map(
            (e) => ListTile(
              title: Image.file(e),
              onPressed: () {
                List<List<int>> matrix = img2mat(e);
              },
            ),
          ),
        ],
      ),
    );
  }
}
