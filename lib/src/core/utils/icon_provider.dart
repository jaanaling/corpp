enum IconProvider {
    back(imageName: 'back.webp'),
  bblue(imageName: 'bblue.webp'),
  bgreen(imageName: 'bgreen.webp'),

  button(imageName: 'button.webp'),

  logo(imageName: 'logo.webp'),
  menu(imageName: 'menu.webp'),
  splash(imageName: 'splash.webp'),
 

  unknown(imageName: '');

  const IconProvider({required this.imageName});

  final String imageName;
  static const _imageFolderPath = 'assets/images';

  String buildImageUrl() => '$_imageFolderPath/$imageName';
  static String buildImageByName(String name) => '$_imageFolderPath/$name';
}
