class Todo {
  String name;
  DateTime createDate;

  Todo(this.name){
    createDate = DateTime.now();
  }
}