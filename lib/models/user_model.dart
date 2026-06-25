class Users {
  String? name;
  String password;
  String email;
  String? cpf;
  String? id;
  String? phone;
  String? state;
  String? cep;
  String? street;
  String? number;
  String? neighbourhood;
  String? addressDetails;
  String? role;
  String? status;
  bool? profileCompleted;
  Map<String, String?>? emergencyContact;

  Users({
    required this.email,
    required this.password,
    this.name,
    this.cpf,
    this.id,
    this.phone,
    this.state,
    this.cep,
    this.street,
    this.number,
    this.neighbourhood,
    this.addressDetails,
    this.role,
    this.status,
    this.profileCompleted,
    this.emergencyContact,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      // 'password' NÃO é persistido no Firestore: a senha vai só para o
      // Firebase Auth (createUserWithEmailAndPassword). Ver F0.1/§2.1.
      'email': email,
      'cpf': cpf,
      'id': id,
      'phone': phone,
      'address': {
        'street': street,
        'number': number,
        'neighborhood': neighbourhood,
        'complement': addressDetails,
        'state': state,
        'zipCode': cep,
      },
      'role': role ?? 'tutor',
      'status': status ?? 'active',
      'profileCompleted': profileCompleted ?? false,
      'emergencyContact': emergencyContact ??
          {
            'name': null,
            'phone': null,
            'relationship': null,
          },
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
      'pets': [], // Initialize empty pets array for tutors
    };
  }

  static Users fromMap(Map<String, dynamic> map) {
    final address = map['address'] as Map<String, dynamic>?;
    final emergencyContact = map['emergencyContact'] != null
        ? Map<String, String?>.from(map['emergencyContact'])
        : null;
    return Users(
      name: map['name'],
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'],
      id: map['id'],
      phone: map['phone'],
      state: address != null ? address['state'] : null,
      cep: address != null ? address['zipCode'] : null,
      street: address != null ? address['street'] : null,
      number: address != null ? address['number'] : null,
      neighbourhood: address != null ? address['neighborhood'] : null,
      addressDetails: address != null ? address['complement'] : null,
      role: map['role'],
      status: map['status'],
      profileCompleted: map['profileCompleted'],
      emergencyContact: emergencyContact,
    );
  }
}
