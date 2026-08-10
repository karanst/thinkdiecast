import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DialogWidgets/see_details_dialog.dart';

class SearchListScreen extends StatefulWidget {
  final String searchKeyword;
  const SearchListScreen({Key? key, required this.searchKeyword})
      : super(key: key);

  @override
  State<SearchListScreen> createState() => _SearchListScreenState();
}

class _SearchListScreenState extends State<SearchListScreen> {
  List data = [];
  List<DocumentSnapshot> filteredDocs = [];

  String? userId;

  fetchDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userId = preferences.getString('userId');
    });

  }

  Stream<List<DocumentSnapshot>> getSearchResults() async* {
    await for (var snapshot in FirebaseFirestore.instance
        .collection('Products')
        .where('createdBy', isEqualTo: userId)
        .snapshots()) {
      // Clear the filteredDocs list before processing new data
      filteredDocs.clear();

      for (var document in snapshot.docs) {
        if (document['name']
            .toString()
            .toLowerCase()
            .contains(widget.searchKeyword.toLowerCase()) ||
            document['color']
                .toString()
                .toLowerCase()
                .contains(widget.searchKeyword.toLowerCase()) ||
            document['category']
                .toString()
                .toLowerCase()
                .contains(widget.searchKeyword.toLowerCase()) ||
            document['scale']
                .toString()
                .toLowerCase()
                .contains(widget.searchKeyword.toLowerCase()) ||
            document['brand']
                .toString()
                .toLowerCase()
                .contains(widget.searchKeyword.toLowerCase())) {
          filteredDocs.add(document); // Add the DocumentSnapshot to the list
        }
      }

      // Yield the filtered list of DocumentSnapshot objects
      yield filteredDocs;
    }
  }


  @override
  void initState() {
    fetchDetails();
    super.initState();
    // getSearchResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            height: 90,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Color(0xfff2f2f2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Showing results for:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
                Text(
                  '"${widget.searchKeyword}"',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: StreamBuilder<List<DocumentSnapshot>>(
                stream: getSearchResults(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // List<DocumentSnapshot> documents = snapshot.data!.docs;
                  final results = snapshot.data!;
                  print('object ${results.length}');

                  return results.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 15.0,
                                    crossAxisSpacing: 4.0,
                                    childAspectRatio: 0.8),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot document = results[index];
                              return InkWell(
                                  onTap: () {
                                    // showDialog(
                                    //   context: context,
                                    //   builder: (BuildContext context) {
                                    //     return SeeDetailsDialog(data: document);
                                    //   },
                                    // );
                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=> SeeDetails()));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                document['image']!))),
                                    // child: Image.network(
                                    //     document['image']!),
                                  ));
                            },
                          ),
                        )
                      : const Center(
                          child: Text(
                            'No Results Found!!',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        );
                }),
          )),
        ],
      ),
    );
  }
}
