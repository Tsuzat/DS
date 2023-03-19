import 'package:dlds/theme.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:provider/provider.dart';

const List<String> accentColorNames = [
  'System',
  'Yellow',
  'Orange',
  'Red',
  'Magenta',
  'Purple',
  'Blue',
  'Teal',
  'Green',
];

const windowsWindowEffects = [
  WindowEffect.disabled,
  WindowEffect.solid,
  WindowEffect.transparent,
  WindowEffect.aero,
  WindowEffect.acrylic,
  WindowEffect.tabbed,
];

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Widget spacer = const SizedBox(height: 20);
  Widget biggerSpacer = const SizedBox(height: 41);

  @override
  Widget build(BuildContext context) {
    AppTheme appTheme = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.only(right: 1),
      child: ScaffoldPage.scrollable(
        header: const PageHeader(
          title: Text(
            "Settings",
          ),
        ),
        children: [
          Text('Theme mode',
              style: FluentTheme.of(context).typography.subtitle),
          spacer,
          ...List.generate(
            ThemeMode.values.length,
            (index) {
              final mode = ThemeMode.values[index];
              return Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8.0),
                child: RadioButton(
                  checked: appTheme.mode == mode,
                  onChanged: (value) {
                    if (value) {
                      appTheme.mode = mode;
                      appTheme.setEffect(appTheme.windowEffect, context);
                    }
                  },
                  content: Text('$mode'.replaceAll('ThemeMode.', '')),
                ),
              );
            },
          ),
          biggerSpacer,
          Text('Accent Color',
              style: FluentTheme.of(context).typography.subtitle),
          spacer,
          Wrap(
            children: [
              Tooltip(
                message: accentColorNames[0],
                child: _buildColorBlock(appTheme, systemAccentColor),
              ),
              ...List.generate(
                Colors.accentColors.length,
                (index) {
                  final color = Colors.accentColors[index];
                  return Tooltip(
                    message: accentColorNames[index + 1],
                    child: _buildColorBlock(appTheme, color),
                  );
                },
              ),
            ],
          ),
          biggerSpacer,
          Text(
            'Window Transparency',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          spacer,
          const InfoBar(
            title: Text('Windows Transparency Information'),
            content: Text(
              'It is recommended to change to transparency to solid/disabled on changing System Theme.\n'
              'Acrylic and Tabbed work on Windows 11 better and Aero works on Windows 10 better, natively.',
            ),
            severity: InfoBarSeverity.info,
            isLong: true,
          ),
          spacer,
          ...List.generate(
            windowsWindowEffects.length,
            (index) {
              final mode = windowsWindowEffects[index];
              return Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8.0),
                child: RadioButton(
                  checked: appTheme.windowEffect == mode,
                  onChanged: (value) {
                    if (value) {
                      appTheme.windowEffect = mode;
                      appTheme.setEffect(mode, context);
                    }
                  },
                  content: Text(
                    mode.toString().replaceAll('WindowEffect.', ''),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildColorBlock(AppTheme appTheme, AccentColor color) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Button(
      onPressed: () {
        appTheme.color = color;
      },
      style: ButtonStyle(
        padding: ButtonState.all(EdgeInsets.zero),
        backgroundColor: ButtonState.resolveWith((states) {
          if (states.isPressing) {
            return color.light;
          } else if (states.isHovering) {
            return color.lighter;
          }
          return color;
        }),
      ),
      child: Container(
        height: 40,
        width: 40,
        alignment: AlignmentDirectional.center,
        child: appTheme.color == color
            ? Icon(
                FluentIcons.check_mark,
                color: color.basedOnLuminance(),
                size: 22.0,
              )
            : null,
      ),
    ),
  );
}
