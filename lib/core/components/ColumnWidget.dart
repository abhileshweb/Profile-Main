import 'package:flutter/material.dart';
import 'package:glory_todo_desktop/core/JsonManager/JsonManager.dart';
import 'package:glory_todo_desktop/core/Lang/Lang.dart';
import 'package:glory_todo_desktop/core/components/ColumnPopUpMenu.dart';
import 'package:glory_todo_desktop/core/components/TodoWidget.dart';
import 'package:glory_todo_desktop/core/models/Settings.dart';
import 'package:glory_todo_desktop/core/models/Todo.dart';

/*

  BU SAYFADA KOLONLAR VE HER KOLONA AİT GÖREVLER YER ALIYOR.

 */

class ColumnWidget extends StatefulWidget {
  bool isNight;
  String tableHeader;
  int columnId;
  String columnName;
  int projectId;
  String projectName;
  final Function updateColumns;
  ColumnWidget(this.isNight, this.tableHeader, this.projectId, this.projectName,
      this.columnId, this.columnName, this.updateColumns);

  @override
  _ColumnWidgetState createState() => _ColumnWidgetState();
}

class _ColumnWidgetState extends State<ColumnWidget> {
  var todoTextKey = GlobalKey<FormState>();
  var gorevEklemeKontrol = TextEditingController();
  var columnEditControl = TextEditingController();
  int todoCounter = 0;
  String todoContent;
  Future<List<Todo>> gorevlerListe;
  List<Settings> settings;

  void refreshSettings() {
    readSettings().then((value) {
      settings = value;
    });
  }

  void updateTodoList() {
    setState(() {
      gorevlerListe = findTodos(widget.projectId, widget.projectName,
          widget.columnId, widget.columnName);
    });
  }

  void remove() {
    removeColumn(widget.projectId, widget.projectName, widget.columnId,
        widget.columnName);
    print("Silindi!");
    setState(() {
      widget.updateColumns();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshSettings();
  }

  void edit() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text(
              settings != null
                  ? settings[0].language == "English"
                      ? Lang.english["newColumnHeader"]
                      : Lang.turkce["newColumnHeader"]
                  : "New Column Name ",
              style: TextStyle(
                  color: widget.isNight ? Colors.white : Colors.black),
            ),
            content: TextFormField(
              controller: columnEditControl,
              style: TextStyle(
                  color: widget.isNight ? Colors.white : Colors.black),
              decoration: InputDecoration(
                  hintText: "Yeni Kolon Adını Giriniz",
                  hintStyle: TextStyle(
                      color: widget.isNight ? Colors.white : Colors.black)),
            ),
            backgroundColor:
                widget.isNight ? Color(0xFF212121) : Color(0xFFf1f2f6),
            actions: [
              Center(
                child: ElevatedButton(
                  // color: Colors.green.shade400,
                  onPressed: () {
                    setState(() {
                      //updatefunc
                      updateColumn(
                          widget.projectId,
                          widget.projectName,
                          widget.columnId,
                          widget.columnName,
                          columnEditControl.text);
                      widget.updateColumns();
                      gorevlerListe = findTodos(
                          widget.projectId,
                          widget.projectName,
                          widget.columnId,
                          columnEditControl.text);
                      widget.columnName = columnEditControl.text;
                      columnEditControl.clear();
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    child: Text(
                      settings != null
                          ? settings[0].language == "English"
                              ? Lang.english["editButton"]
                              : Lang.turkce["editButton"]
                          : "Edit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          );
        });
    print("Editlendi!");
  }

  @override
  Widget build(BuildContext context) {
    gorevlerListe = findTodos(widget.projectId, widget.projectName,
        widget.columnId, widget.columnName);

    //findColumnTodos(widget.tableUnicId); //widget.tableHeader
    return Container(
      key: ValueKey(widget.projectName),
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      width: 300,
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: MediaQuery.of(context).size.height - 50,
      ),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: widget.isNight ? Colors.black12 : Colors.grey.shade300,

              blurRadius: 6,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
          color: widget.isNight ? Color(0xFF1f2024) : Color(0xFFd7d8de),
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(widget.tableHeader,
                        style: TextStyle(
                          fontSize: 20,
                          color: widget.isNight ? Colors.white : Colors.black,
                        )),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 0,
                  child: ColumnPopUpMenu(widget.isNight, edit, remove),
                ),
              ],
            ),
          ),

          //Buraya Görevler Listesi gelmeli
          Container(
              width: 300,
              height: MediaQuery.of(context).size.height - 225,
              child: FutureBuilder(
                future: gorevlerListe,
                builder: (context, snapshot) {
                  List<Todo> listem = snapshot.data ?? [];
                  if (listem.length > 0) {
                    todoCounter = listem.length;
                    print("Görev :==> " + listem[0].todo);
                    return ListView.builder(
                        itemCount: listem.length,
                        itemBuilder: (BuildContext context, int index) {
                          return TodoWidget(
                              listem[index].todo,
                              listem[index].isCheck,
                              widget.isNight,
                              widget.projectId,
                              widget.projectName,
                              widget.columnId,
                              widget.columnName,
                              listem[index].todoId,
                              updateTodoList);
                        });
                  } else {
                    print("Herhangi bir görev bulunamadı!");
                    return Center(
                        child: Text(
                      settings != null
                          ? settings[0].language == "English"
                              ? Lang.english["noTodosHeader"]
                              : Lang.turkce["noTodosHeader"]
                          : "No task found!",
                      style: TextStyle(
                          color:
                              widget.isNight ? Colors.white60 : Colors.black87),
                    ));
                  }
                },
              )),
          //En altta ekleme butonu bulunmalı
          Container(
              width: 200,
              height: 20,
              child: IconButton(
                  icon: Icon(Icons.add,
                      color: widget.isNight ? Colors.white : Colors.black),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return new AlertDialog(
                            title: Text(
                              settings != null
                                  ? settings[0].language == "English"
                                      ? Lang.english["newTodoHeader"]
                                      : Lang.turkce["newTodoHeader"]
                                  : "New Todo Name?",
                              style: TextStyle(
                                  color: widget.isNight
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            content: Form(
                              key: todoTextKey,
                              child: TextFormField(
                                controller: gorevEklemeKontrol,
                                validator: (value) =>
                                    value != null ? null : "Bir görev giriniz.",
                                onSaved: (value) => todoContent = value,
                                style: TextStyle(
                                    color: widget.isNight
                                        ? Colors.white
                                        : Colors.black),
                                decoration: InputDecoration(
                                    hintText: settings != null
                                        ? settings[0].language == "English"
                                            ? Lang.english["newTodoHeader2"]
                                            : Lang.turkce["newTodoHeader2"]
                                        : "New Todo Name?",
                                    hintStyle: TextStyle(
                                        color: widget.isNight
                                            ? Colors.white
                                            : Colors.black)),
                              ),
                            ),
                            backgroundColor: widget.isNight
                                ? Color(0xFF212121)
                                : Color(0xFFf1f2f6),
                            actions: [
                              Center(
                                child: ElevatedButton(
                                  // color: Colors.green.shade400,
                                  onPressed: () {
                                    setState(() {
                                      if (todoTextKey.currentState.validate()) {
                                        todoTextKey.currentState.save();

                                        addTodo(
                                            Todo(todoCounter + 1,
                                                gorevEklemeKontrol.text, false),
                                            widget.projectId,
                                            widget.projectName,
                                            widget.columnId,
                                            widget.columnName);

                                        gorevlerListe = findTodos(
                                            widget.projectId,
                                            widget.projectName,
                                            widget.columnId,
                                            widget.columnName);
                                        gorevEklemeKontrol.clear();

                                        Navigator.pop(context);
                                      }
                                    });
                                  },
                                  child: Container(
                                    child: Text(
                                      settings != null
                                          ? settings[0].language == "English"
                                              ? Lang.english["addButton"]
                                              : Lang.turkce["addButton"]
                                          : "Add",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        }); //SetState sonu
                  })),
        ],
      ),
    );
  }
}
