import 'package:dlds/screens/settings.dart';
import 'package:dlds/theme.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'default_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
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
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    windowManager.destroy();
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
        onTap: () {},
      )
    ];

    return NavigationView(
      appBar: NavigationAppBar(
        height: 32,
        automaticallyImplyLeading: false,
        title: const DragToMoveArea(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text("Deep Learning Defect Sampling"),
          ),
        ),
        actions: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: ToggleSwitch(
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
            ),
            const WindowButtons(),
          ],
        ),
      ),
      pane: NavigationPane(
        selected: _index,
        onChanged: (v) => setState(() {
          _index = v;
        }),
        items: items,
        footerItems: footerItems,
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
