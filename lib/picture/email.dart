import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drop_down_list/drop_down_list.dart';
import '../home.dart';





// Create a Form widget.
class EmailForm extends StatefulWidget {

  final String title;
  const EmailForm(this.title);


  @override
  EmailFormState createState() {
    return EmailFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class EmailFormState extends State<EmailForm> {





  Future <http.Response> createEmail(String email, String format, String ID) {
    return http.post(
      Uri.parse('https://shoothouse.cylab.be/email'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'format': format,
        'ID': ID,
      }),
    );
  }

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<EmailFormState>.
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  // Initial Selected Value
  String dropdownvalue = '.obj';

  // List of items in our dropdown menu
  var items = [
    '.obj',
    '.fbx',
    '.stl',
    '.gltf',
  ];

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return
      DecoratedBox(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage("assets/back.png"), fit: BoxFit.contain),
    ),
    child: Scaffold(
        appBar: AppBar(
          title: const Text('Send by email'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text("Email to send the file",
                  style: TextStyle(fontWeight: FontWeight.bold,height: 1, fontSize: 20)),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.email_outlined),
                  hintText: 'What do people call you?',
                  labelText: 'Please enter Email',),
                controller: myController,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text("Choose your format",
                style: TextStyle(fontWeight: FontWeight.bold,height: 1, fontSize: 20)),
              SizedBox(height: 10),
              DropdownButton(

                // Initial Value
                value: dropdownvalue,

                // Down Arrow Icon
                icon: const Icon(Icons.keyboard_arrow_down),

                // Array list of items
                items: items.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue = newValue!;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize: const Size(150, 70)),
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate() && EmailValidator.validate(myController.text))  {
                      print("sending");
                      createEmail(myController.text,dropdownvalue,widget.title);
                    }
                    else{
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            // Retrieve the text the that user has entered by using the
                            // TextEditingController.
                            content: Text("Please enter a valide email"),
                          );


                        },
                      );
                    }
                  },
                  child: const Text('Submit',style: TextStyle(fontWeight: FontWeight.bold,height: 1, fontSize: 20)),
                ),
              ),
            ],
          ),
        )));
  }
}
