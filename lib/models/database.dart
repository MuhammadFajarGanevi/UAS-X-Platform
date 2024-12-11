import 'dart:io';

import 'package:aplikasi_simpanuang/models/category.dart';
import 'package:aplikasi_simpanuang/models/transaction.dart';
import 'package:aplikasi_simpanuang/models/transaction_with_category.dart';
import 'package:drift/drift.dart';
// These imports are only needed to open the database
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(
    // relative import for the drift file. Drift also supports `package:`
    // imports
    tables: [Categories, Transactions])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Crud Category
  Future<List<Category>> getAllCategoryRepo(String type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
        .get();
  }

  Future updateCategoryRepo(int id, String name) async {
    return (update(categories)..where((tbl) => tbl.id.equals(id)))
        .write(CategoriesCompanion(name: Value(name)));
  }

  Future deleteCategoryRepo(int id) async {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }
  // End CRUD Category

  // Join Table
  Stream<List<TransactionWithCategory>> getTransactionWithByDateRepo(
      DateTime date) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ]))
      ..where(transactions.transaction_date.equals(date));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }

  // Update Transaction
  Future updateTransactionRepo(int id, int amount, int category_id,
      DateTime transactionDate, String nameDetail) async {
    final now = DateTime.now();
    return await (update(transactions)..where((tbl) => tbl.id.equals(id)))
        .write(TransactionsCompanion(
            name: Value(nameDetail),
            amount: Value(amount),
            transaction_date: Value(transactionDate),
            category_id: Value(category_id),
            updatedAt: Value(now)));
  }

  Future deleteTransactionRepo(int id) async {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Future deleteAllTransactionRepo() async {
  //   try {
  //     await delete(transactions).go();
  //     print("Semua data di tabel transactions telah dihapus.");
  //   } catch (e) {
  //     print("Terjadi kesalahan saat menghapus data: $e");
  //   }
  // }

  Future<int> getAmountSumRepo(String type, int year, int month) async {
    // Ambil hasil sum berdasarkan type dan bulan di tabel Categories
    final query = (select(transactions).join([
      innerJoin(
        categories,
        categories.id.equalsExp(transactions.category_id),
      )
    ])
          ..where(categories.type.equals(type))
          ..where(transactions.transaction_date.year.equals(year))
          ..where(transactions.transaction_date.month.equals(month)))
        .map((row) => row.readTable(transactions).amount);

    // Ambil semua amount dan hitung total
    final result = await query.get();
    final total = result.fold(0, (sum, amount) => sum + (amount));
    return total;
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
