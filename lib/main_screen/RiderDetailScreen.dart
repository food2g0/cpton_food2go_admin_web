import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RiderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> riderData;

  const  RiderDetailScreen({Key? key, required this.riderData}) : super(key: key);

  @override
  State<RiderDetailScreen> createState() => _RiderDetailScreenState();
}

class _RiderDetailScreenState extends State<RiderDetailScreen> {


  @override
  Widget build(BuildContext context) {
    final earnings = widget.riderData['earnings'];
    final earningsDouble = earnings != null ? double.parse(earnings.toString()) : 0.0;

    final result = earningsDouble * 0.7;
    final resultString = '\P: $result';

    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 150.0,
                        width: 150.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(widget.riderData['riderAvatarUrl'] ?? ''),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    const Text(
                      'Rider Name:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.riderData['riderName'], style: TextStyle(fontSize: 16.0)),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Email:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.riderData['riderEmail'], style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 12.0),
                    const Text(
                      'Address:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.riderData['address'], style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 12.0),
                    const Text(
                      'Phone:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.riderData['phone'], style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 20.0),
                    const Text(
                      'Status:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.riderData['status'], style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 20.0),
                    const Text(
                      'Earnings:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      resultString,
                      style: TextStyle(fontSize: 16.0, color: Colors.green),
                    ),

                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Remove Rider'),
                              content: const Text('Are you sure you want to remove this rider?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),

                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      child: const Text('Remove rider'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
