class TransactionResponse {
  final bool success;
  final User user;
  final List<Transaction> transactions;

  TransactionResponse({
    required this.success,
    required this.user,
    required this.transactions,
  });
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
  final String? paymentPurpose;
  final int? byParentUser;
  final String? transactionUniqueId;
  final String transactionStatus;
  final String amount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.userName,
    this.paymentPurpose,
    this.byParentUser,
    this.transactionUniqueId,
    required this.transactionStatus,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      paymentPurpose: json['payment_purpose'] as String?,
      byParentUser: json['by_parant_user'] as int?,
      transactionUniqueId: json['transaction_unique_id'] as String?,
      transactionStatus: json['tr_status'] as String,
      amount: json['amount'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
