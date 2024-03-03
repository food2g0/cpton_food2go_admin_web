import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SellerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> sellerData;

  const SellerDetailScreen({Key? key, required this.sellerData}) : super(key: key);

  @override
  State<SellerDetailScreen> createState() => _SellerDetailScreenState();
}

class _SellerDetailScreenState extends State<SellerDetailScreen> {
  // Future<void> removeSeller() async {
  //   try {
  //     await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerData['sellersUID']).delete();
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Seller removed successfully'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //
  //     // Close the SellerDetailScreen after removal
  //     Navigator.of(context).pop();
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error removing seller: $e'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }
  // Future<void> getSellerEarnings() async {
  //   try {
  //     // Fetch the sales document for the specific month (e.g., '02_February')
  //     DocumentSnapshot salesSnapshot = await FirebaseFirestore.instance
  //         .collection('sales')
  //         .doc('02_February') // Replace '02_February' with the desired month
  //         .get();
  //
  //     // Check if the document exists
  //     if (salesSnapshot.exists) {
  //       // Get the earnings for the specific seller from the sales document
  //       var saleData = salesSnapshot.data();
  //       if (saleData != null) {
  //         var sellerUID = widget.sellerData['sellersUID'];
  //         var saleVal = saleData[sellerUID];
  //
  //         if (saleVal != null) {
  //           // Update the 'sellerEarnings' field in the UI
  //           setState(() {
  //             widget.sellerData['sellerEarnings'] = saleVal;
  //           });
  //         } else {
  //           // If saleVal is null, handle it accordingly
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Seller earnings data not found'),
  //               duration: Duration(seconds: 2),
  //             ),
  //           );
  //         }
  //       } else {
  //         // Handle the case where sales data is null
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('No sales data found for this month'),
  //             duration: Duration(seconds: 2),
  //           ),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('No sales data found for this month'),
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error fetching seller earnings: $e'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }




  Future<void> removeSellerItem() async {
    try {
      // Remove seller from the 'sellers' collection
      await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerData['sellersUID']).delete();

      // Get product IDs associated with the seller from the 'items' collection
      QuerySnapshot<Object?> productsSnapshot = await FirebaseFirestore.instance.collection('items').where('sellerUID',
          isEqualTo: widget.sellerData['sellersUID']).get();

      List<String> productIds = [];
      for (QueryDocumentSnapshot<Object?> product in productsSnapshot.docs) {
        productIds.add(product.id);
      }

      // Remove products associated with the seller from the 'items' collection
      for (String productId in productIds) {
        await FirebaseFirestore.instance.collection('items').doc(productId).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seller and associated products removed successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Close the SellerDetailScreen after removal
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing seller and associated products: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
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
                            image: NetworkImage(widget.sellerData['sellerPhoto'] ?? ''),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Seller Name:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.sellerData['sellersName'], style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 12.0),
                    Text(
                      'Email:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.sellerData['sellersEmail'], style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 12.0),
                    Text(
                      'Address:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.sellerData['sellersAddress'], style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 12.0),
                    Text(
                      'Phone:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.sellerData['sellersphone'], style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 20.0),
                    Text(
                      'Status:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.sellerData['status'], style: TextStyle(fontSize: 16.0)),
                    SizedBox(height: 20.0),
                    Text(
                      'Earnings:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\P: ${widget.sellerData['sellerEarnings']}',
                      style: TextStyle(fontSize: 16.0, color: Colors.green),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Remove Seller'),
                              content: Text('Are you sure you want to remove this seller?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await removeSellerItem();
                                  },
                                  child: Text('Remove'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      child: Text('Remove Seller'),
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
