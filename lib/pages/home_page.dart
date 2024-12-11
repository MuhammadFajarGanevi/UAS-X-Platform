import 'package:aplikasi_simpanuang/models/database.dart';
import 'package:aplikasi_simpanuang/models/transaction_with_category.dart';
import 'package:aplikasi_simpanuang/pages/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();
  final formatter = NumberFormat("#,##0", "id_ID");

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: SafeArea(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dashboard Income dan Expense
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<int>>(
            future: Future.wait<int>([
              database.getAmountSumRepo("Income", widget.selectedDate.year,
                  widget.selectedDate.month),
              database.getAmountSumRepo("Expense", widget.selectedDate.year,
                  widget.selectedDate.month),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                final incomeTotal = snapshot.data![0];
                final expenseTotal = snapshot.data![1];
                return Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Row Income
                      Row(
                        children: [
                          Container(
                            child: Icon(
                              Icons.download,
                              color: Colors.green,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Income",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontSize: 12)),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Rp. ${formatter.format(incomeTotal)}",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontSize: 14))
                            ],
                          )
                        ],
                      ), //Income
                      // Row Expense
                      Row(
                        children: [
                          Container(
                            child: Icon(
                              Icons.upload,
                              color: Colors.red,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Expense",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontSize: 12)),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Rp. ${formatter.format(expenseTotal)}",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontSize: 14))
                            ],
                          )
                        ],
                      ) // Outcome
                    ],
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              } else {
                return Text("Error loading data");
              }
            },
          ),
        ),

        // Text Transaksi
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Transactions",
              style: GoogleFonts.montserrat(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),

        StreamBuilder<List<TransactionWithCategory>>(
            stream: database.getTransactionWithByDateRepo(widget.selectedDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData) {
                  if (snapshot.data!.length > 0) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          await database.deleteTransactionRepo(
                                              snapshot
                                                  .data![index].transaction.id);

                                          setState(() {});
                                        },
                                        icon: Icon(Icons.delete)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () async {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TracnsactionPage(
                                                      transactionWithCategory:
                                                          snapshot.data![index],
                                                    )));
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                title: Text("Rp. " +
                                    snapshot.data![index].transaction.amount
                                        .toString()),
                                subtitle: Text(
                                    snapshot.data![index].transaction.name +
                                        " (" +
                                        snapshot.data![index].category.name +
                                        ")"),
                                leading: Container(
                                  child: (snapshot.data![index].category.type ==
                                          "Expense")
                                      ? Icon(
                                          Icons.upload,
                                          color: Colors.red,
                                        )
                                      : Icon(
                                          Icons.download,
                                          color: Colors.green,
                                        ),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0)),
                                ),
                              ),
                            ),
                          );
                        });
                  } else {
                    return Center(
                      child: Text("Data 0"),
                    );
                  }
                } else {
                  return Center(
                    child: Text("No Data"),
                  );
                }
              }
            }),
        // IconButton(
        //     onPressed: () {
        //       database.deleteAllTransactionRepo();
        //       setState(() {});
        //     },
        //     icon: Icon(Icons.delete)),
      ],
    )));
  }
}
