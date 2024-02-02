import 'package:flutter/material.dart';

class SellerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> sellerData;

  const SellerDetailScreen({Key? key, required this.sellerData}) : super(key: key);




  @override
  State<SellerDetailScreen> createState() => _SellerDetailScreenState();
}

class _SellerDetailScreenState extends State<SellerDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seller Name: ${widget.sellerData['sellersName']}'),
          Text('Seller UID: ${widget.sellerData['sellersUID']}'),
          Text('Email: ${widget.sellerData['sellersEmail']}'),
          Text('Address: ${widget.sellerData['sellersAddress']}'),
          Text('Phone: ${widget.sellerData['sellersphone']}'),
          Text('Status: ${widget.sellerData['status']}'),
          if (widget.sellerData['status'] == 'disapproved')
            Text('Blocking Reason: ${widget.sellerData['blockingReason']}'),
        ],
      ),
    );
  }
}
