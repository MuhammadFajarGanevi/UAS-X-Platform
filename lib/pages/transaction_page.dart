import 'package:aplikasi_simpanuang/models/database.dart';
import 'package:aplikasi_simpanuang/models/transaction_with_category.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TracnsactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory;
  const TracnsactionPage({Key? key, required this.transactionWithCategory})
      : super(key: key);

  @override
  State<TracnsactionPage> createState() => _TracnsactionPageState();
}

class _TracnsactionPageState extends State<TracnsactionPage> {
  final AppDb database = AppDb();
  bool isExpense = true;
  TextEditingController dateController = TextEditingController();
  TextEditingController ammountController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  Category? selectedCategory;
  late String type;

  Future insert(
      int Ammount, DateTime date, String nameDetail, int categoryId) async {
    // Ada insert database.
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(
        TransactionsCompanion.insert(
            name: nameDetail,
            category_id: categoryId,
            transaction_date: date,
            amount: Ammount,
            createdAt: now,
            updatedAt: now));
    print(row);
  }

  Future update(int transactionId, int amount, int categoryId,
      DateTime transactionDate, String nameDetail) async {
    return await database.updateTransactionRepo(
        transactionId, amount, categoryId, transactionDate, nameDetail);
  }

  void updateTransactionsView(TransactionWithCategory transactionwithcategory) {
    ammountController.text =
        transactionwithcategory.transaction.amount.toString();
    detailController.text = transactionwithcategory.transaction.name;
    dateController.text = DateFormat('yyyy-MM-dd')
        .format(transactionwithcategory.transaction.transaction_date);
    type = transactionwithcategory.category.type;
    (type == "Expense") ? isExpense = true : isExpense = false;
    selectedCategory = transactionwithcategory.category;
  }

  Future<List<Category>> getAllCategory(String type) async {
    return await database.getAllCategoryRepo(type);
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.transactionWithCategory != null) {
      updateTransactionsView(widget.transactionWithCategory!);
    } else {
      type = "Expense";
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Transaction"),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch(
                  value: isExpense,
                  onChanged: (bool value) {
                    setState(() {
                      isExpense = value;
                      type = (isExpense) ? "Expense" : "Income";
                      selectedCategory = null;
                    });
                  },
                  inactiveTrackColor: Colors.green[200],
                  inactiveThumbColor: Colors.green,
                  activeColor: Colors.red,
                ),
                Text(
                  (isExpense == true) ? "Expense" : "Income",
                  style: GoogleFonts.montserrat(fontSize: 14),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: ammountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Ammount",
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Category",
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ),
            FutureBuilder<List<Category>>(
                future: getAllCategory(type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data!.length > 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButton<Category>(
                              value: (selectedCategory == null)
                                  ? selectedCategory = snapshot.data!.first
                                  : selectedCategory,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_downward),
                              items: snapshot.data!.map((Category item) {
                                return DropdownMenuItem<Category>(
                                  value: item,
                                  child: Text(item.name),
                                );
                              }).toList(),
                              onChanged: (Category? value) {
                                selectedCategory = value;
                                setState(() {});
                              }),
                        );
                      } else {
                        return Center(child: Text("Data Not Found"));
                      }
                    } else {
                      return Center(child: Text("Data Not Found"));
                    }
                  }
                }),
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                readOnly: true,
                controller: dateController,
                decoration: InputDecoration(labelText: "Enter Date"),
                onTap: () async {
                  DateTime? pickDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2099));

                  if (pickDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickDate);

                    dateController.text = formattedDate;
                  }
                },
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: detailController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Detail",
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Center(
                child: ElevatedButton(
              onPressed: () async {
                (widget.transactionWithCategory == null)
                    ? insert(
                        int.parse(ammountController.text),
                        DateTime.parse(dateController.text),
                        detailController.text,
                        selectedCategory!.id)
                    : await update(
                        widget.transactionWithCategory!.transaction.id,
                        int.parse(ammountController.text),
                        selectedCategory!.id,
                        DateTime.parse(dateController.text),
                        detailController.text);

                Navigator.pop(context, true);
                // setState(() {});
              },
              child: Text("Save"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.black),
            )),
          ],
        )),
      ),
    );
  }
}
