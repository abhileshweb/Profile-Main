import 'package:flutter/material.dart';
import 'package:glory_todo_desktop/Pages/TodosPage.dart';
import 'package:glory_todo_desktop/core/GloryIcons/GloryIcons.dart';
import 'package:glory_todo_desktop/core/models/Column.dart';
import 'package:glory_todo_desktop/core/models/Project.dart';
import 'package:glory_todo_desktop/core/models/Settings.dart';
import 'package:glory_todo_desktop/core/JsonManager/JsonManager.dart';
import 'package:page_transition/page_transition.dart';

class TabloWidget extends StatefulWidget {
  bool isNight;
  String tableHeader;
  int projectId;
  String projectName;
  final Function updateProjectsW;
  final Function refreshSettings;
  List<Settings> settings;
  TabloWidget(this.isNight, this.tableHeader, this.projectId, this.projectName,
      this.updateProjectsW, this.refreshSettings, this.settings);

  @override
  _TabloWidgetState createState() => _TabloWidgetState();
}

class _TabloWidgetState extends State<TabloWidget> {
  double checkedCount = 0;
  double noneCheckedCount = 0;
  double progresValue = 0.0;

  updateProgressBar() {
    countTodos(widget.projectId, widget.projectName).then((value) {
      print("GÖREV SAYISIIII ==============> " + value.toString());
      checkedCount = value[0].toDouble() != null ? value[0].toDouble() : 0;
      print("Yapılan Görev Sayisi :" + checkedCount.toString());

      noneCheckedCount =
          value[1].toDouble() != null ? value[1].toDouble() : 0.0;

      print("Yapılmayan Görev Sayisi : " + noneCheckedCount.toString());

      print(
          "----------------------------Progress Bar Güncellendi!------------------------------------");

      setState(() {
        progresValue =
            (checkedCount / (checkedCount + noneCheckedCount)).toDouble() !=
                    null
                ? (checkedCount / (checkedCount + noneCheckedCount)).toDouble()
                : 0.0;
      });

      print("Progresbar Value ================> " + progresValue.toString());
    });
  }

  List<Settings> settings;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      updateProgressBar();
    });
  }

  void refreshSettings() {
    readSettings().then((value) {
      settings = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.refreshSettings();
    return GestureDetector(
      key: ValueKey(widget.projectName),
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeftWithFade,
                //alignment: Alignment.bottomRight,
                child: TodosPage(
                    widget.isNight,
                    widget.tableHeader,
                    widget.projectId,
                    widget.projectName,
                    widget.updateProjectsW,
                    updateProgressBar,
                    this.refreshSettings,
                    this.settings)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        width: 250,
        height: 150,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.settings != null
                    ? widget.settings[0].colorMode == "Dark"
                        ? Colors.black26
                        : Colors.grey.shade300
                    : Colors.black26,

                blurRadius: 5,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
            color: widget.settings != null
                ? widget.settings[0].colorMode == "Dark"
                    ? Color(0xFF1c1d21)
                    : Color(0xFFd7d8de)
                : Color(0xFF1c1d21),
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 70.0),
              child: Text(widget.tableHeader,
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w300,
                    fontSize: 22,
                    color: widget.isNight ? Colors.white : Colors.black,
                  )),
            ),
            Container(
              width: 200,
              margin: EdgeInsets.symmetric(vertical: 5),
              child: checkProjectIsComplate(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  setColor() {}

  Widget checkProjectIsComplate() {
    if (progresValue == 1) {
      return Icon(
        Icons.check,
        color: Colors.greenAccent[400],
        size: 40,
      );
    } else {
      return LinearProgressIndicator(
        value: progresValue.isNaN ? 0.0 : progresValue,
        backgroundColor: Color(0x4D131111),
        minHeight: 6,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent[400]),
      );
    }
  }
}
