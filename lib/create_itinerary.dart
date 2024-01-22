import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CreateItineraryScreen extends StatefulWidget {
  @override
  _CreateItineraryScreenState createState() => _CreateItineraryScreenState();
}

class _CreateItineraryScreenState extends State<CreateItineraryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _placeController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  var _isSending = false;

  List<Itinerary> itineraries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Itinerary'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _placeController,
              decoration: InputDecoration(labelText: 'Place'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a place';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Date'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a date';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Time'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a time';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Note'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a note';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () => _itinerary(),
              child: Text('Create Itinerary'),
            ),
            if (itineraries.isNotEmpty)
              ItineraryList(itineraries: itineraries),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Prompt user to fill in itinerary details
          Itinerary? newItinerary = await showDialog<Itinerary>(
            context: context,
            builder: (BuildContext context) {
              return AddItineraryDialog();
            },
          );

          // If user clicks "Save" in the dialog, add the new itinerary to the list
          if (newItinerary != null) {
            setState(() {
              itineraries.add(newItinerary);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _itinerary() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });
      _formKey.currentState!.save();

      try {
        final url = Uri.https(
          'smart-planner-travel-app-default-rtdb.asia-southeast1.firebasedatabase.app',
          'itinerary.json',
        );

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(
            {
              'place': _placeController.text,
              'date': _dateController.text,
              'time': _timeController.text,
              'note': _noteController.text,
            },
          ),
        );

        print(response.body);
        print(response.statusCode);

        if (response.statusCode == 200) {
          // Successfully created itinerary in Firebase
          print('Itinerary created successfully');
          Itinerary newItinerary = Itinerary(
            place: _placeController.text,
            date: _dateController.text,
            time: _timeController.text,
            note: _noteController.text,
          );
          setState(() {
            itineraries.add(newItinerary);
            _placeController.clear();
            _dateController.clear();
            _timeController.clear();
            _noteController.clear();
          });
        } else {
          // Error creating itinerary
          print('Error creating itinerary: ${response.reasonPhrase}');
        }
      } catch (e) {
        // Exception occurred
        print('Error creating itinerary: $e');
      }

      setState(() {
        _isSending = false;
      });
    }
  }
}

class Itinerary {
  final String place;
  final String date;
  final String time;
  final String note;

  Itinerary({
    required this.place,
    required this.date,
    required this.time,
    required this.note,
  });
}

class ItineraryCard extends StatelessWidget {
  final Itinerary itinerary;

  const ItineraryCard({required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(itinerary.place),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${itinerary.date}'),
            Text('Time: ${itinerary.time}'),
            Text('Note: ${itinerary.note}'),
          ],
        ),
      ),
    );
  }
}

class ItineraryList extends StatelessWidget {
  final List<Itinerary> itineraries;

  const ItineraryList({required this.itineraries});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: itineraries.length,
        itemBuilder: (context, index) {
          return ItineraryCard(itinerary: itineraries[index]);
        },
      ),
    );
  }
}

class AddItineraryDialog extends StatefulWidget {
  @override
  _AddItineraryDialogState createState() => _AddItineraryDialogState();
}

class _AddItineraryDialogState extends State<AddItineraryDialog> {
  late TextEditingController placeController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    placeController = TextEditingController();
    dateController = TextEditingController();
    timeController = TextEditingController();
    noteController = TextEditingController();
  }

  @override
  void dispose() {
    placeController.dispose();
    dateController.dispose();
    timeController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Itinerary'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: placeController,
              decoration: InputDecoration(labelText: 'Place'),
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: 'Time'),
            ),
            TextField(
              controller: noteController,
              decoration: InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog without saving
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Save the itinerary and close the dialog
            Itinerary newItinerary = Itinerary(
              place: placeController.text,
              date: dateController.text,
              time: timeController.text,
              note: noteController.text,
            );
            Navigator.of(context).pop(newItinerary);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
