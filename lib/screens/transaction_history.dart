import 'package:allinone_app/model/transaction_model.dart';
import 'package:allinone_app/network/rest_apis.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
   TransactionHistoryState createState() =>  TransactionHistoryState();
}

class  TransactionHistoryState extends State<TransactionHistory> {
  bool _isLoading = true;
  List<Transaction> transactions = [];
  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    fetchBusinessData();
  }

  Future<void> fetchBusinessData() async {
    try {
      // Directly fetch the parsed transaction data
      final List<TransactionResponse> response = await getTransactionData(transactionmodal: []);

      if (kDebugMode) {
        print(response);
      }

      setState(() {
        transactions = response.map((e) => e.transactions).expand((e) => e).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching business data: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    // Filter transactions based on search query and selected filter
    List<Transaction> filteredTransactions = transactions.where((tx) {
      final matchesFilter =
          selectedFilter == 'All' || tx.transactionStatus == selectedFilter;
      final matchesSearchQuery =
      tx.userName.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearchQuery;
    }).toList();

    // Calculate total balance based on filtered transactions
    double totalBalance = filteredTransactions.fold(
      0.0,
          (sum, tx) {
        if (tx.transactionStatus != 'Credit' && tx.transactionStatus != 'Debit') {
          if (kDebugMode) {
            print('Skipping transaction with invalid status: ${tx.transactionStatus}');
          }
          return sum;
        }

        try {
          final double amount = double.parse(tx.amount);
          double updatedSum = tx.transactionStatus == 'Credit' ? sum + amount : sum - amount;
          return updatedSum < 0 ? 0 : updatedSum; // Ensure balance doesn't go below 0
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing amount for transaction: ${tx.amount}');
          }
          return sum;
        }
      },
    );



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Transaction History',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          // Refresh Icon
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              fetchBusinessData();
            },
          ),
          // Filter Icon
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search transactions by name',
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.black,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12)),
                        borderSide:
                        BorderSide(color: Colors.black, width: 2.0),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12)),
                        borderSide:
                        BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Filter Chips
            Row(
              children: [
                FilterChip(
                  label: Text(
                    'All',
                    style: GoogleFonts.poppins(
                      color: selectedFilter == 'All'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: selectedFilter == 'All',
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue,
                  onSelected: (selected) {
                    setState(() {
                      selectedFilter = 'All';
                    });
                  },
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: Text(
                    'Credit',
                    style: GoogleFonts.poppins(
                      color: selectedFilter == 'Credit'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: selectedFilter == 'Credit',
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue,
                  onSelected: (selected) {
                    setState(() {
                      selectedFilter = 'Credit';
                    });
                  },
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: Text(
                    'Debit',
                    style: GoogleFonts.poppins(
                      color: selectedFilter == 'Debit'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: selectedFilter == 'Debit',
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue,
                  onSelected: (selected) {
                    setState(() {
                      selectedFilter = 'Debit';
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Total Balance
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Balance',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${totalBalance < 0 ? '0.00' : totalBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: totalBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 10),

            // Transaction List
            Expanded(
              child: ListView.builder(
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = filteredTransactions[index];
                  final isCredit = transaction.transactionStatus == 'Credit';

                  for (var tx in filteredTransactions) {
                    if (kDebugMode) {
                      print('Transaction: ${tx.userName}, Amount: ${tx.amount}, Status: ${tx.transactionStatus}');
                    }
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCredit
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      child: Text(
                        transaction.userName[0],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: isCredit ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    title: Text(
                      transaction.userName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show remark first



                        // Show timestamp next
                        Text(
                          transaction.createdAt.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4), // Add spacing after the remark
                        Text(
                          transaction.paymentPurpose?.toString() ?? 'No purpose provided', // Null-safe access and default value
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${isCredit ? '+' : '-'} ₹${transaction.amount}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isCredit ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),


          ],
        ),
      ),
    );
  }





// Filter Dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter Options',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.green),
              title: const Text('Credit Transactions'),
              onTap: () {
                setState(() {
                  selectedFilter = 'Credit';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off, color: Colors.red),
              title: const Text('Debit Transactions'),
              onTap: () {
                setState(() {
                  selectedFilter = 'Debit';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.all_inbox, color: Colors.blue),
              title: const Text('All Transactions'),
              onTap: () {
                setState(() {
                  selectedFilter = 'All';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
