import 'package:fluent_ui/fluent_ui.dart';

class DLDSProject {
  String title;
  Icon icon;
  String project_file;

  DLDSProject(this.title, this.icon, this.project_file);

  DLDSProject fromJson(Map<String, dynamic> data) {
    String? title = data["title"];
    Icon? icon = icons[data["icon"]];
    String project_file = data["project_file"];
    return DLDSProject(title!, icon, project_file);
  }
}

const List<Icon> icons = [
  Icon(FluentIcons.home),
  Icon(FluentIcons.list),
  Icon(FluentIcons.page_list_solid),
  Icon(FluentIcons.fabric_new_folder),
  Icon(FluentIcons.new_folder),
  Icon(FluentIcons.new_team_project),
];
