import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cookbook_app/core/theme/sizes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cookbook_app/data/models/recipe_model.dart';

class CreateCustomRecipe extends StatefulWidget {
  const CreateCustomRecipe({super.key});

  @override
  State<CreateCustomRecipe> createState() => _CreateCustomRecipeState();
}

class _CreateCustomRecipeState extends State<CreateCustomRecipe> {
  final List<File?> _pickedImages = [];
  final _picker = ImagePicker();
  final _recipeTitleController = TextEditingController();
  final _authorNameController = TextEditingController();
  final _ingridientsController = TextEditingController();
  final _descriptionController = TextEditingController();

  void pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _pickedImages.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  Widget pickImagesButton(String text) {
    return OutlinedButton.icon(
      onPressed: () => pickImages(),
      label: Text(
        text,
        style: TextStyle(color: const Color.fromARGB(255, 220, 165, 0)),
      ),
      icon: Icon(Icons.add),
      style: OutlinedButton.styleFrom(
        iconColor: const Color.fromARGB(255, 220, 165, 0),
        overlayColor: const Color.fromARGB(255, 220, 165, 0),
        side: BorderSide(color: const Color.fromARGB(255, 220, 165, 0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size(400, 50),
      ),
    );
  }

  @override
  void dispose() {
    _recipeTitleController.dispose();
    _authorNameController.dispose();
    _ingridientsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Sizes.l.value),
      child: Column(
        children: [
          Text(
            "NEW RECIPE",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          ),
          Divider(height: Sizes.l.value, thickness: 2),
          SizedBox(height: Sizes.m.value),
          //Title
          TextField(
            controller: _recipeTitleController,
            decoration: InputDecoration(
              label: Text("Title"),
              hint: Text(
                "For example, Sushi-maki",
                style: TextStyle(color: Colors.grey),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          SizedBox(height: Sizes.m.value),
          //Author
          TextField(
            controller: _authorNameController,
            decoration: InputDecoration(
              label: Text("Author"),
              hint: Text(
                "Type your name",
                style: TextStyle(color: Colors.grey),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          SizedBox(height: Sizes.m.value),
          //Ingridients
          TextField(
            maxLines: 2,
            controller: _ingridientsController,
            decoration: InputDecoration(
              hint: Text(
                "Separate ingridients with coma ",
                style: TextStyle(color: Colors.grey),
              ),
              alignLabelWithHint: true,
              label: Text("Recipe ingridients"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          SizedBox(height: Sizes.m.value),
          //Description
          TextField(
            maxLines: 3,
            controller: _descriptionController,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              label: Text("Description"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          SizedBox(height: Sizes.m.value),
          _pickedImages.isEmpty
              ? pickImagesButton("Select images")
              : Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverGrid.builder(
                        itemCount: _pickedImages.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemBuilder: (context, idx) {
                          File? currentImage = _pickedImages[idx];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.file(
                                    currentImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: AlignmentGeometry.topCenter,
                                        end: AlignmentGeometry.bottomCenter,
                                        colors: [
                                          Colors.black.withAlpha(50),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _pickedImages.remove(currentImage);
                                      });
                                    },
                                    icon: Icon(Icons.delete_rounded),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: Sizes.m.value),
                      ),
                      SliverToBoxAdapter(
                        child: pickImagesButton("Add another images"),
                      ),
                    ],
                  ),
                ),
          SizedBox(height: Sizes.l.value),
          FilledButton(
            onPressed: () {
              final RecipeModel recipe = RecipeModel(
                author: _authorNameController.text,
                title: _recipeTitleController.text,
                ingredients: _ingridientsController.text.split(", "),
                description: _descriptionController.text,
                images: _pickedImages.isNotEmpty
                    ? _pickedImages.map((e) => e!.path).toList()
                    : ["assets/default_dish.png"],
              );
              Navigator.pop(context, recipe);
            },
            style: FilledButton.styleFrom(minimumSize: Size(400, 50)),
            child: Text("SUBMIT"),
          ),
        ],
      ),
    );
  }
}
