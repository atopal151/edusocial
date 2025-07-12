class AppConstants {
  static const String baseUrl = "https://stageapi.edusocial.pl/mobile";
  
  /// Avatar URL'ini düzeltir
  static String fixAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return 'https://i.pravatar.cc/150?img=1'; // Default avatar
    }
    
    // Eğer zaten tam URL ise olduğu gibi döndür
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return avatarUrl;
    }
    
    // Eğer file:/// ile başlıyorsa düzelt
    if (avatarUrl.startsWith('file:///')) {
      final path = avatarUrl.replaceFirst('file:///', '');
      return '$baseUrl/$path';
    }
    
    // Eğer / ile başlıyorsa base URL ekle
    if (avatarUrl.startsWith('/')) {
      return '$baseUrl$avatarUrl';
    }
    
    // Diğer durumlarda base URL + / + avatarUrl
    return '$baseUrl/$avatarUrl';
  }
}
