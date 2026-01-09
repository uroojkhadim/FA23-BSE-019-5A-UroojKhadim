class AccountingEntry {
  final String id;
  final String transactionId;
  final String accountId;
  final String accountName;
  final double debit;
  final double credit;
  final DateTime date;
  final String description;

  AccountingEntry({
    required this.id,
    required this.transactionId,
    required this.accountId,
    required this.accountName,
    required this.debit,
    required this.credit,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'accountId': accountId,
      'accountName': accountName,
      'debit': debit,
      'credit': credit,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory AccountingEntry.fromMap(Map<String, dynamic> map) {
    return AccountingEntry(
      id: map['id'] ?? '',
      transactionId: map['transactionId'] ?? '',
      accountId: map['accountId'] ?? '',
      accountName: map['accountName'] ?? '',
      debit: map['debit']?.toDouble() ?? 0.0,
      credit: map['credit']?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date']),
      description: map['description'] ?? '',
    );
  }
}

class Account {
  final String id;
  final String name;
  final String type; // 'asset', 'liability', 'equity', 'revenue', 'expense'
  final double balance;
  final String description;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'description': description,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      balance: map['balance']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
    );
  }
}
