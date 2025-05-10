import '../utils/constants.dart';

String getFullAvatarUrl(String? avatar) {
  if (avatar == null || avatar.isEmpty) {
    return 'images/user1.png'; // varsayılan yerel görselin yolu
  }

  // Eğer avatar URL'si zaten tam URL değilse baseUrl ekle
  if (!avatar.startsWith("http")) {
    return '${AppConstants.baseUrl}/$avatar';
  }

  return avatar;
}
