import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dlds/main.dart';
import 'package:dlds/screens/settings.dart';
import 'package:dlds/theme.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'default_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NavigationPaneItem> items = [
    PaneItemHeader(
      header: const Text("Projects"),
    ),
    PaneItem(
      title: const Text("Home"),
      icon: const Icon(FluentIcons.home),
      body: const DefaultScreen(),
    ),
  ];

  /// index count of paneitems
  int _index = 0;

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
          showDialog(
            context: context,
            builder: (context) {
              String projectName = "";
              return ContentDialog(
                title: const Text('Add New Project'),
                content: TextBox(
                  placeholder: 'Project Name',
                  onChanged: (value) => projectName = value,
                ),
                actions: [
                  Button(
                    child: const Text('Add Project'),
                    onPressed: () {
                      Navigator.pop(context);
                      PaneItem temp = PaneItem(
                        title: Text(projectName),
                        icon: const Icon(FluentIcons.new_folder),
                        body: const DefaultScreen(),
                      );
                      items.add(temp);
                      setState(() {});
                    },
                  ),
                  FilledButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
            },
          );
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
          // header: FluentTheme.of(context).brightness.isDark
          //     ? Image.asset(
          //         "assets/logo_white.png",
          //         width: 80,
          //         filterQuality: FilterQuality.high,
          //       )
          //     : Image.asset(
          //         "assets/logo_black.png",
          //         width: 80,
          //         filterQuality: FilterQuality.high,
          //       ),
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
