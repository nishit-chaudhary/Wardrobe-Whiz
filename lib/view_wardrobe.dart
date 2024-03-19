import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_cloth_details.dart';

class MyWardrobeScreen extends StatefulWidget {
  @override
  _MyWardrobeScreenState createState() => _MyWardrobeScreenState();
}

class _MyWardrobeScreenState extends State<MyWardrobeScreen> {
  List<String> _categories = [
    'T-Shirt',
    'Shorts',
    'Anorak',
    'Blazer',
    'Blouse',
    'Bomber',
    'Button-Down',
    'Caftan',
    'Capris',
    'Cardigan',
    'Chinos',
    'Coat',
    'Coverup',
    'Culottes',
    'Cutoffs',
    'Dress',
    'Flannel',
    'Gauchos',
    'Halter',
    'Henley',
    'Hoodie',
    'Jacket',
    'Jeans',
    'Jeggings',
    'Jersey',
    'Jodhpurs',
    'Joggers',
    'Jumpsuit',
    'Kaftan',
    'Kimono',
    'Leggings',
    'Onesie',
    'Parka',
    'Peacoat',
    'Poncho',
    'Robe',
    'Romper',
    'Sarong' 'Skirt',
    'Sweater',
    'Sweatpants',
    'Sweatshorts',
    'Tank',
    'Top',
    'Trunks',
    'Turtleneck'
  ];

  dynamic image;
  dynamic category;
  dynamic color;
  String details = "Additional Details";

  Map<String, List<String>> _clothesByCategory =
  {}; // Map to store clothes by category

  @override
  void initState() {
    super.initState();
    _loadClothesByCategory();
  }

  Future<void> _loadClothDetails(String imagePath) async {
    image = File(imagePath);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clothDetails = prefs.getString('savedClothes');
    if (clothDetails != null) {
      Map<String, dynamic> cmap = json.decode(clothDetails);
      dynamic clothes = Map<String, List<dynamic>>.from(cmap);
      print("View Cloth Details!!!");
      print(clothes[imagePath]);

      category = clothes[imagePath][0];
      details = clothes[imagePath][1];
      color = Color(int.parse(clothes[imagePath][2]));
      print(category);
      print(details);
      print(color);
    }
  }

  Future<void> _loadClothesByCategory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? categoryMap = prefs.getString('catMap');
    if (categoryMap != null) {
      Map<String, dynamic> cmap = json.decode(categoryMap);
      dynamic catMapDetails = Map<String, List<dynamic>>.from(cmap);

      catMapDetails.forEach((key, value) {
        if (catMapDetails[key] != null) {
          List<String> clothes = [];
          for (String i in value) {
            clothes.add(i);
          }
          setState(() {
            _clothesByCategory[key] = clothes;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadClothesByCategory();
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wardrobe'),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          String category = _categories[index];
          List<String> clothes = _clothesByCategory[category] ?? [];
          return _buildExpansionTile(category, clothes);
        },
      ),
    );
  }

  Widget _buildExpansionTile(String category, List<String> clothes) {
    return ExpansionTile(
      title: Text(category),
      children: [
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: clothes.length,
          itemBuilder: (context, index) {
            String imagePath = clothes[index];
            return GestureDetector(
              onTap: () async {
                await _loadClothesByCategory();
                await _loadClothDetails(imagePath);
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EditClothDetails(
                          imagePath: imagePath,
                          category: category,
                          color: color,
                          details: details);
                    });
              },
              child: Card(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
