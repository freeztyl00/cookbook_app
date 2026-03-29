import 'package:uuid/uuid.dart';

const tableCategories = 'tbl_categories';
const tblCategoriesColId = 'id';
const tblCategoriesColName = 'name';
const tblCategoriesColIsCustom = 'isCustom';

class CategoryModel {
  final String id;
  final String name;
  final bool isCustom;

  CategoryModel({required this.name, this.isCustom = false, String? id})
    : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'isCustom': isCustom ? 1 : 0};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[tblCategoriesColId] as String,
      name: map[tblCategoriesColName] as String,
      isCustom: map[tblCategoriesColIsCustom] == 1 ? true : false,
    );
  }
}
