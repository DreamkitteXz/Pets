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
      'password': password,
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
}
