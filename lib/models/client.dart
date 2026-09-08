class Client {
  final int? id;
  final String name;
  final String phone;
  final String createdAt;

  Client({
    this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'created_at': createdAt,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      createdAt: map['created_at'],
    );
  }

  Client copyWith({int? id, String? name, String? phone}) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }
}
