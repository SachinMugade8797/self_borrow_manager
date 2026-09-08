class TransactionEntry {
  final int? id;
  final int clientId;
  final String clientName;
  final double amount;
  final String type; 
  final String? note;
  final String date;
  final String? dueDate;
  final bool isSettled;

  TransactionEntry({
    this.id,
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.type,
    this.note,
    required this.date,
    this.dueDate,
    this.isSettled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'client_name': clientName,
      'amount': amount,
      'type': type,
      'note': note,
      'date': date,
      'due_date': dueDate,
      'is_settled': isSettled ? 1 : 0,
    };
  }

  factory TransactionEntry.fromMap(Map<String, dynamic> map) {
    return TransactionEntry(
      id: map['id'],
      clientId: map['client_id'],
      clientName: map['client_name'],
      amount: (map['amount'] as num).toDouble(),
      type: map['type'],
      note: map['note'],
      date: map['date'],
      dueDate: map['due_date'],
      isSettled: map['is_settled'] == 1,
    );
  }
}
