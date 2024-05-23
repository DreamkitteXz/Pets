class SlideInfo {
  final String title;
  final String description;
  final String imageUrl;

  SlideInfo({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

List<SlideInfo> slides = [
  SlideInfo(
    title: 'Boas Vindas ao Pets!',
    description:
        'Seja bem-vindo(a)  ao nosso sistema de controle da saúde do seu pet!',
    imageUrl: 'lib/mvc_implementation/screens/assets/dog1.svg',
  ),
  SlideInfo(
    title: 'Carteira de vacinação do seu Pet!',
    description:
        'Tenha a carteira de vacinação do seu pet na palma da sua mão!',
    imageUrl: 'lib/mvc_implementation/screens/assets/cat1.svg',
  ),
  SlideInfo(
    title: 'Validação pelo veterinário!',
    description:
        'O veterinário terá acesso a todas as vacinas do seu pet para valida-las',
    imageUrl: 'lib/mvc_implementation/screens/assets/cat2.svg',
  ),
  // Adicione mais objetos SlideInfo conforme necessário
];
