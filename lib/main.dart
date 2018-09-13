import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final String firestoreCollection = 'todo_list';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.deepPurple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Rijndam Todo app'),
        ),
        body: TodoListScreen(firestoreCollection),
      ),
    );
  }
}

class TodoListScreen extends StatelessWidget {
  String _firestoreCollection;

  TodoListScreen(this._firestoreCollection);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream:
              Firestore.instance.collection(_firestoreCollection).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return FirestoreListView(documents: snapshot.data.documents);
          }),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SecondScreen(_firestoreCollection)),
          );
        },
        tooltip: 'Voeg een taak toe',
        child: new Icon(Icons.add),
      ),
    );
  }
}

class FirestoreListView extends StatelessWidget {
  final List<DocumentSnapshot> documents;

  FirestoreListView({this.documents});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documents.length,
      itemExtent: 90.0,
      itemBuilder: (BuildContext context, int index) {
        String title = documents[index].data['title'].toString();
        String description = documents[index].data['description'].toString();
        String hours = documents[index].data['hours'].toString();
        bool finished = false; //documents[index].data['finished'];

        //return TodoCard(documents[index]);

          return ListTile(
          title: Text(title),
          subtitle: Text(description),
          enabled: !finished,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SecondScreen('todo_list',
                      documentToUpdate: documents[index])),
            );
          },
        ); 
      },
    );
  }
}

class TodoCard extends StatefulWidget {
  final DocumentSnapshot documentToUpdate;

  TodoCard(this.documentToUpdate);

  @override
  _TodoCardState createState() => new _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  bool _isChecked = false;

  void onChanged(bool value) {
    setState(() {
      _isChecked = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Checkbox(
            value: _isChecked,
            activeColor: Colors.grey,
            onChanged: (bool value) {
              onChanged(value);
            }),
        Text(
          widget.documentToUpdate.data['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class SecondScreen extends StatefulWidget {
  final DocumentSnapshot documentToUpdate;

  final String _firestoreCollection;

  SecondScreen(this._firestoreCollection, {this.documentToUpdate});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class MyCustomFormState extends State<SecondScreen> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = new TextEditingController();
  TextEditingController descController = new TextEditingController();
  TextEditingController hoursController = new TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    hoursController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.documentToUpdate != null) {
      nameController.text = widget.documentToUpdate.data['title'].toString();
      descController.text =
          widget.documentToUpdate.data['description'].toString();
      hoursController.text = widget.documentToUpdate.data['hours'].toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Nieuwe taak"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Je hebt minimaal een naam nodig';
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Naam',
                ),
              ),
              TextFormField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                    labelText: 'Omschrijving',
                    hintText: 'Optioneel: Geef een omschrijving'),
              ),
              TextFormField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Aantal uur',
                    hintText:
                        'Optioneel: Hoe lang denk je ervoor nodig te hebben?'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, we want to show a Snackbar
                      //Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));

                      // we're updating an document
                      if (widget.documentToUpdate != null) {
                        Firestore.instance
                            .runTransaction((Transaction tx) async {
                          if (widget.documentToUpdate.exists) {
                            await widget.documentToUpdate.reference.updateData({
                              "title": nameController.text,
                              "description": descController.text,
                              "hours": hoursController.text
                            });
                          }
                        });

                        Navigator.pop(context);
                      } else {
                        Firestore.instance
                            .runTransaction((Transaction transaction) async {
                          CollectionReference reference = Firestore.instance
                              .collection(widget._firestoreCollection);
                          await reference.add({
                            "title": nameController.text,
                            "description": descController.text,
                            "hours": hoursController.text,
                            "finished": false,
                          });

                          Navigator.pop(context);
                        });
                      }
                    }
                  },
                  child: Text('Opslaan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
