import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:furnico/wishlist/model/CollectionWishlist.dart';
import 'dart:convert';

class MyWishlist extends StatefulWidget {
  const MyWishlist({Key? key}) : super(key: key);

  @override
  _MyWishlistState createState() => _MyWishlistState();
}

class _MyWishlistState extends State<MyWishlist> {
  Future<CollectionWishlist?> fetchWishlist(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/wishlist/wishlist-json/');
    if (response != null) {
      return CollectionWishlist.fromJson(response);
    }
    return null;
  }

  void _showAddCollectionDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Collection'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Collection Name',
              hintText: 'Enter collection name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final request = context.read<CookieRequest>();
                  final response = await request.post(
                    'http://127.0.0.1:8000/wishlist/create-collection/',
                    jsonEncode({
                      'collection_name': nameController.text,
                    }),
                  );

                  if (response['success'] == true) {
                    setState(() {});
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Collection created successfully')),
                      );
                    }
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCollectionDialog(Collection collection) {
    final TextEditingController nameController = TextEditingController(
      text: collection.collectionName,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Collection'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Collection Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final request = context.read<CookieRequest>();
                  final response = await request.post(
                    'http://127.0.0.1:8000/wishlist/update-collection-name/${collection.collectionId}/',
                    jsonEncode({
                      'collection_name': nameController.text,
                    }),
                  );

                  if (response['success'] == true) {
                    setState(() {});
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Collection updated successfully')),
                      );
                    }
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCollection(int collectionId) async {
    final request = context.read<CookieRequest>();
    final response = await request.post(
      'http://127.0.0.1:8000/wishlist/delete-collection/$collectionId/',
      jsonEncode({}),
    );

    if (response['success'] == true) {
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collection deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Collections"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCollectionDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<CollectionWishlist?>(
        future: fetchWishlist(request),
        builder: (context, AsyncSnapshot<CollectionWishlist?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.collections.isEmpty == true) {
            return const Center(
              child: Text("No collections found"),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.collections.length,
            itemBuilder: (context, index) {
              final collection = snapshot.data!.collections[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(
                    collection.collectionName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditCollectionDialog(collection),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Collection'),
                            content: const Text('Are you sure you want to delete this collection?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteCollection(collection.collectionId);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    if (collection.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No items in this collection"),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: collection.items.length,
                        itemBuilder: (context, itemIndex) {
                          final item = collection.items[itemIndex];
                          return ListTile(
                            title: Text(item.productName),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final response = await request.post(
                                  'http://127.0.0.1:8000/wishlist/remove-wishlist/${item.productId}/',
                                  {},
                                );
                                if (response['success'] == true) {
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Item removed successfully'),
                                    ),
                                  );
                                }
                              },
                            ),
                            onTap: () {
                              // Navigate to product detail page if needed
                            },
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
