import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dlds/main.dart';
import 'package:dlds/screens/project.dart';
import 'package:dlds/screens/settings.dart';
import 'package:dlds/theme.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

const List<Icon> icons = [
  Icon(FluentIcons.home),
  Icon(FluentIcons.list),
  Icon(FluentIcons.page_list_solid),
  Icon(FluentIcons.fabric_new_folder),
  Icon(FluentIcons.new_folder),
  Icon(FluentIcons.new_team_project),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NavigationPaneItem> items = [
    // PaneItemHeader(
    //   header: const Text("Projects"),
    // ),
    // PaneItem(
    //   title: const Text("Home"),
    //   icon: const Icon(FluentIcons.home),
    //   // body: const DefaultScreen(),
    //   body: const ProjectPage(),
    // ),
  ];

  var projectData;

  String projectJsonFilePath = "Projects/projects.json";

  /// index count of paneitems
  int _index = 0;

  @override
  void initState() {
    super.initState();
    getPanItems();
  }

  /// Function to get Projects
  /// saved in projects.json
  void getPanItems() async {
    var data = await File(projectJsonFilePath).readAsString();
    projectData = jsonDecode(data);
    for (int i = 0; i < projectData.length; i++) {
      PaneItem tmp = PaneItem(
        title: Text(projectData[i]["title"]),
        icon: icons[projectData[i]["icon"]],
        body: const ProjectPage(),
      );
      items.add(tmp);
    }
    setState(() {});
  }

  /// Function to save whatever is in
  /// variable projectData in `projects.json` file
  void saveIntoJson() {
    File(projectJsonFilePath).writeAsStringSync(jsonEncode(projectData));
  }

  @override
  Widget build(BuildContext context) {
    AppTheme appTheme = context.watch<AppTheme>();
    List<NavigationPaneItem> footerItems = [
      PaneItemSeparator(),
      PaneItem(
        title: const Text("Settings"),
        icon: const Icon(FluentIcons.settings),
        body: const Settings(),
      ),
      PaneItemAction(
        title: const Text("Create New Project"),
        icon: const Icon(FluentIcons.add),
        onTap: () async {
          var data = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) {
              return const ContentDialoague();
            },
          );
          if (data != null) {
            items.add(
              PaneItem(
                title: Text(data["title"]),
                icon: data["icon"],
                body: const ProjectPage(),
              ),
            );
            // Add this to the project.json too
            Map<String, dynamic> tmp = {
              "title": data["title"],
              "icon": icons.indexOf(data["icon"])
            };
            projectData.add(tmp);
            saveIntoJson();
          }
          setState(() {});
        },
      )
    ];

    return WindowBorder(
      color: Colors.transparent,
      width: 0.5,
      child: NavigationView(
        appBar: NavigationAppBar(
          height: 32,
          automaticallyImplyLeading: false,
          title: MoveWindow(
            child: const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text("Deep Learning Defect Sampling"),
            ),
          ),
          actions: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ToggleSwitch(
                content: const Text('Dark Mode'),
                checked: FluentTheme.of(context).brightness.isDark,
                onChanged: (v) {
                  if (v) {
                    appTheme.mode = ThemeMode.dark;
                  } else {
                    appTheme.mode = ThemeMode.light;
                  }
                },
              ),
              const WindowButtons(),
            ],
          ),
        ),
        pane: NavigationPane(
          header: FluentTheme.of(context).brightness.isDark
              ? SvgPicture.asset(
                  "assets/logo_white.svg",
                  width: 80,
                )
              : SvgPicture.asset(
                  "assets/logo_black.svg",
                  width: 80,
                ),
          selected: _index,
          onChanged: (v) => setState(() {
            _index = v;
          }),
          items: items,
          footerItems: footerItems,
        ),
      ),
    );
  }
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDart = FluentTheme.of(context).brightness.isDark;
    final buttonColors = WindowButtonColors(
      iconNormal: isDart ? Colors.white : Colors.black,
      mouseOver: const Color.fromRGBO(150, 150, 150, 0.5),
      mouseDown: const Color.fromRGBO(150, 150, 150, 0.3),
      iconMouseOver: isDart ? Colors.white : Colors.black,
      iconMouseDown: isDart ? Colors.white : Colors.black,
    );

    final closeButtonColors = WindowButtonColors(
        iconNormal: isDart ? Colors.white : Colors.black,
        mouseOver: const Color(0xFFD32F2F),
        mouseDown: const Color(0xFFB71C1C),
        iconMouseOver: Colors.white);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MinimizeWindowButton(colors: buttonColors),
        appWindow.isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(
          colors: closeButtonColors,
          onPressed: () {
            shell.kill();
            appWindow.close();
          },
        ),
      ],
    );
  }
}

class ContentDialoague extends StatefulWidget {
  const ContentDialoague({super.key});

  @override
  State<ContentDialoague> createState() => _ContentDialoagueState();
}

class _ContentDialoagueState extends State<ContentDialoague> {
  String title = "";
  Icon icon = icons[0];
  String errorText = "";
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Add New Project'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: "Project Name:",
            child: TextBox(
              placeholder: 'e.g. Steel Strip Batch #222',
              onChanged: (value) => title = value,
            ),
          ),
          InfoLabel(
            label: "Icon:",
            child: DropDownButton(
                title: icon,
                items: icons
                    .map((e) => MenuFlyoutItem(
                        text: e,
                        onPressed: () {
                          setState(() {
                            icon = e;
                          });
                        }))
                    .toList()),
          ),
          Text(
            errorText.isNotEmpty ? "Message: $errorText" : "",
            style: TextStyle(color: Colors.red),
          )
        ],
      ),
      actions: [
        Button(
          child: const Text('Add Project'),
          onPressed: () {
            if (title.isNotEmpty) {
              Navigator.pop(context, {"title": title, "icon": icon});
            } else {
              errorText = "Project Name could not be empty";
              setState(() {});
            }
          },
        ),
        FilledButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, null),
        ),
      ],
    );
  }
}
