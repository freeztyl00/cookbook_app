import 'package:cookbook_app/data/models/category_model.dart';
import 'package:cookbook_app/data/models/recipe_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DbHelper {
  static final instance = DbHelper._();

  DbHelper._();

  final String _createTableCategories =
      '''CREATE TABLE $tableCategories (
  $tblCategoriesColId TEXT PRIMARY KEY,
  $tblCategoriesColName TEXT,
  $tblCategoriesColIsCustom INTEGER DEFAULT 0
  )''';

  final String _createTableRecipes =
      '''CREATE TABLE $tableRecipes (
  $tblRecipesColId TEXT PRIMARY KEY,
  $tblRecipesColAuthor TEXT,
  $tblRecipesColTitle TEXT,
  $tblRecipesColIngredients TEXT,
  $tblRecipesColDescription TEXT,
  $tblRecipesColImages TEXT,
  $tblRecipesColCategoryId TEXT,
  $tblRecipesColIsFavourite INTEGER,
  FOREIGN KEY ($tblRecipesColCategoryId) REFERENCES $tableCategories ($tblCategoriesColId) ON DELETE SET NULL
  )''';

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    final dbPath = path.join(root, 'recipes.db');
    return openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute(_createTableCategories);
        await db.execute(_createTableRecipes);
      },
    );
  }

  Future<int> insertRecipe(RecipeModel recipe) async {
    final db = await _open();
    return db.insert(
      tableRecipes,
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMultipleRecipes(List<RecipeModel> list) async {
    final db = await _open();
    final batch = db.batch();

    for (final item in list) {
      batch.insert(
        tableRecipes,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<int> deleteRecipe(String id) async {
    final db = await _open();
    return db.delete(
      tableRecipes,
      where: '$tblRecipesColId = ?',
      whereArgs: [id],
    );
  }

  Future<RecipeModel> getRecipeById(String id) async {
    final db = await _open();
    final map = await db.query(
      tableRecipes,
      where: '$tblRecipesColId = ?',
      whereArgs: [id],
    );

    return RecipeModel.fromMap(map.first);
  }

  Future<List<RecipeModel>> getAllRecipes() async {
    final db = await _open();
    final String query =
        '''
    SELECT r.*, c.$tblCategoriesColName as $tblRecipesColCategoryName
    FROM $tableRecipes r
    LEFT JOIN $tableCategories c ON r.$tblRecipesColCategoryId = c.$tblCategoriesColId
    ORDER BY $tblRecipesColTitle ASC
    ''';

    final mapList = await db.rawQuery(query);
    return mapList.map((map) => RecipeModel.fromMap(map)).toList();
  }

  Future<List<RecipeModel>> getAllRecipesByCategoryId(String id) async {
    final db = await _open();
    final String query =
        '''
    SELECT r.*, c.$tblCategoriesColName AS $tblRecipesColCategoryName
    FROM $tableRecipes r
    LEFT JOIN $tableCategories c ON r.$tblRecipesColCategoryId = c.$tblCategoriesColId
    WHERE r.$tblRecipesColCategoryId = ?
    ORDER BY r.$tblRecipesColTitle ASC
    ''';
    final mapList = await db.rawQuery(query, [id]);
    return mapList.map((map) => RecipeModel.fromMap(map)).toList();
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await _open();
    final mapList = await db.query(
      tableCategories,
      orderBy: '$tblCategoriesColName ASC',
    );
    return mapList.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<int> updateFavourite(RecipeModel recipe) async {
    final db = await _open();
    final count = await db.update(
      tableRecipes,
      {tblRecipesColIsFavourite: recipe.isFavourite ? 1 : 0},
      where: '$tblRecipesColId = ?',
      whereArgs: [recipe.id],
    );
    return count;
  }

  Future<List<RecipeModel>> getAllFavourites() async {
    final db = await _open();
    final mapList = await db.query(
      tableRecipes,
      where: '$tblRecipesColIsFavourite = ?',
      whereArgs: [1],
    );
    return mapList.map((map) => RecipeModel.fromMap(map)).toList();
  }

  Future<int> insertCategory(CategoryModel category) async {
    final db = await _open();
    final insert =
        '''
    INSERT INTO $tableCategories ($tblCategoriesColId, $tblCategoriesColName, $tblCategoriesColIsCustom) 
    VALUES (?, ?, ?)
    ''';
    return db.rawInsert(insert, [
      category.id,
      category.name,
      category.isCustom,
    ]);
  }

  Future<void> insertMultipleCategories(List<CategoryModel> list) async {
    final db = await _open();
    final batch = db.batch();

    for (final item in list) {
      batch.insert(
        tableCategories,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }
}
