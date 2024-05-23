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
  });

  Map<String, dynamic> toMap() {
    return {
      'Nome': name,
      'Senha': password,
      'Email': email,
      'CPF': cpf,
      'Id': id,
      'Telefone': phone,
      'Estado': state,
      'CEP': cep,
      'Rua': street,
      'Numero': number,
      'Bairro': neighbourhood,
      'Complemento': addressDetails,
    };
  }
}
