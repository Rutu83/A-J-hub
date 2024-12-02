class TransactionResponse {
  final bool success;
  final User user;
  final List<Transaction> transactions;

  TransactionResponse({
    required this.success,
    required this.user,
    required this.transactions,
  });

  // Factory method to parse JSON into TransactionResponse object
  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'] as bool,
      user: User.fromJson(json['user']),
      transactions: (json['data'] as List)
          .map((transaction) => Transaction.fromJson(transaction))
          .toList(),
    );
  }
}

class User {
  final int id;
  final String name;

  User({
    required this.id,
    required this.name,
  });

  // Factory method to parse JSON into User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}




class Transaction {
  final int id;
  final int userId;
  final String userName;
  final String? paymentPurpose; // Nullable field
  final int? byParentUser; // Nullable field
  final String? transactionUniqueId; // Nullable field
  final String transactionStatus;
  final String amount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.userName,
    this.paymentPurpose, // Nullable
    this.byParentUser, // Nullable
    this.transactionUniqueId, // Nullable
    required this.transactionStatus,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to parse JSON into Transaction object
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      paymentPurpose: json['payment_purpose'] as String?, // Handle null
      byParentUser: json['by_parant_user'] as int?, // Handle null
      transactionUniqueId: json['transaction_unique_id'] as String?, // Handle null
      transactionStatus: json['tr_status'] as String,
      amount: json['amount'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

