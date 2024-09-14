import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gallery_images/Provider/gallery_provider_screen.dart';
import 'package:gallery_images/Screens/full_screen.dart';
import 'package:provider/provider.dart';


class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    provider.fetchImages();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !provider.isLoading) {
        provider.fetchImages(query: provider.query);
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = Provider.of<GalleryProvider>(context, listen: false);
      provider.resetGallery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
        TextField(
  controller: _searchController,
  decoration: InputDecoration(
      hintText: "Search images...",
      prefixIcon: Icon(Icons.search),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)))),
),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<GalleryProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width ~/ 150,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: provider.images.length,
                    itemBuilder: (context, index) {
                      final image = provider.images[index];
                      return GestureDetector(
                        onTap: () => _openImageFullscreen(context, image),
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                image['webformatURL'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 5,),
                            Text('Likes: ${image['likes']}'),
                            SizedBox(height: 2,),
                            Text('Views: ${image['views']}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (provider.isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openImageFullscreen(BuildContext context, dynamic image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imageUrl: image['largeImageURL']),
      ),
    );
  }
}
