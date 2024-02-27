import 'package:cpton_food2go_admin_web/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellersApplicants extends StatefulWidget {
  const SellersApplicants({Key? key}) : super(key: key);

  @override
  State<SellersApplicants> createState() => _SellersApplicantsState();
}

class _SellersApplicantsState extends State<SellersApplicants> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text('Sellers Applicant',
        style: TextStyle(color: AppColors().white,
        fontFamily: "Poppins"),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sellers')
            .where('status', isEqualTo: 'disapproved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Sellers Applicant found.'),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              // Assuming your seller document has a field named 'name'
              final sellersName = doc['sellersName'];
              return ListTile(
                title: Text(sellersName),
                // Add more ListTile properties or widgets as needed
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
