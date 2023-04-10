import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dlds/backend/server.dart';
import 'package:dlds/screens/home_page.dart';
import 'package:dlds/theme.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:system_theme/system_theme.dart';
import 'package:provider/provider.dart';
import 'package:process_run/shell_run.dart';

final shell = Shell();

final String appDir = Directory.current.absolute.path;

void main() async {
  // run backend
  WidgetsFlutterBinding.ensureInitialized();

  await SystemTheme.accentColor.load();

  await flutter_acrylic.Window.initialize();
  await flutter_acrylic.Window.hideWindowControls();

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1050, 600);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "DLDS";
    win.show();
  });

  /// get present working directory

  String pwd = shell.path;
  String backendExe = "$pwd\\backend_bin_Csharp\\server.exe";

  /// Checking if Backend is running using [checkBackend] function
  /// If backend is not running then run the backend
  if (!await checkBackend()) {
    shell.run(backendExe);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp(
          title: "DLDS",
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          color: appTheme.color,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          theme: FluentThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor: appTheme.windowEffect !=
                          flutter_acrylic.WindowEffect.disabled
                      ? Colors.transparent
                      : null,
                ),
                child: child!,
              ),
            );
          },
          routes: {"/": (context) => const HomePage()},
          initialRoute: "/",
        );
      },
    );
  }
}
