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
  Future<void> removeSellerItem() async {
    try {
      // Remove seller from the 'sellers' collection
      await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerData['sellersUID']).delete();

      // Get product IDs associated with the seller from the 'items' collection
      QuerySnapshot<Object?> productsSnapshot = await FirebaseFirestore.instance.collection('items').where('sellerUID', isEqualTo: widget.sellerData['sellersUID']).get();

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
                      '\$${widget.sellerData['sellerEarnings']}',
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
