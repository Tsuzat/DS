import 'package:fluent_ui/fluent_ui.dart';

class DefaultScreen extends StatefulWidget {
  const DefaultScreen({super.key});

  @override
  State<DefaultScreen> createState() => _DefaultScreenState();
}

class _DefaultScreenState extends State<DefaultScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Default Screen",
      ),
    );
  }
}
