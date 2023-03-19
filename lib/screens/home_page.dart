import 'package:dlds/screens/settings.dart';
import 'package:dlds/theme.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
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
  Widget build(BuildContext context) {
    AppTheme appTheme = context.watch<AppTheme>();

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
      content: const Settings(),
    );
  }
}

// class WindowButtons extends StatefulWidget {
//   const WindowButtons({Key? key}) : super(key: key);

//   @override
//   _WindowButtonsState createState() => _WindowButtonsState();
// }

// class _WindowButtonsState extends State<WindowButtons> {
//   void maximizeOrRestore() {
//     setState(() {
//       appWindow.maximizeOrRestore();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         MinimizeWindowButton(colors: buttonColors),
//         appWindow.isMaximized
//             ? RestoreWindowButton(
//                 colors: buttonColors,
//                 onPressed: maximizeOrRestore,
//               )
//             : MaximizeWindowButton(
//                 colors: buttonColors,
//                 onPressed: maximizeOrRestore,
//               ),
//         CloseWindowButton(colors: closeButtonColors),
//       ],
//     );
//   }
// }

// class WindowButtons extends StatefulWidget {
//   const WindowButtons({super.key});

//   @override
//   State<WindowButtons> createState() => _WindowButtonsState();
// }

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
