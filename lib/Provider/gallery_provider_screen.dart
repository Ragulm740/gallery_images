import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class GalleryProvider extends ChangeNotifier {
  final String _apiKey = '45956154-51ed13a8a5f781da8487ce5d8';
  List<dynamic> _images = [];
  int _page = 1;
  String _query = '';
  bool _isLoading = false;

  List<dynamic> get images => _images;
  bool get isLoading => _isLoading;
  
  // Public getter for the private field _query
  String get query => _query;

  Future<void> fetchImages({String query = ''}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'https://pixabay.com/api/?key=$_apiKey&q=$query&image_type=photo&page=$_page&per_page=20');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _images.addAll(data['hits']);
      _page++;
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetGallery(String query) {
    _images.clear();
    _query = query;
    _page = 1;
    fetchImages(query: _query);
  }
}
