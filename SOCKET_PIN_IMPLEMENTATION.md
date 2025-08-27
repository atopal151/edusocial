# Socket Pin/Unpin Message Implementation

Bu dokümantasyon, conversation ve group chat'lerde mesaj pin/unpin işlemlerinin gerçek zamanlı socket bağlantısı ile nasıl çalıştığını açıklar.

## Genel Bakış

Sistem, mesajların pin/unpin durumlarını gerçek zamanlı olarak güncellemek için WebSocket bağlantısı kullanır. Hem private conversation'lar hem de group chat'ler için desteklenir.

## Implementasyon Detayları

### 1. Socket Service Güncellemeleri

**Dosya:** `lib/services/socket_services.dart`

#### Yeni Stream Controller
```dart
final _pinMessageController = StreamController<dynamic>.broadcast();
Stream<dynamic> get onPinMessage => _pinMessageController.stream;
```

#### Dinlenen Event'ler
- `conversation:message_pinned` - Private mesaj pin
- `conversation:message_unpinned` - Private mesaj unpin
- `group:message_pinned` - Group mesaj pin
- `group:message_unpinned` - Group mesaj unpin
- `message:pinned` - Alternatif event ismi
- `message:unpinned` - Alternatif event ismi

### 2. Chat Controllers Güncellemeleri

#### ChatDetailController
**Dosya:** `lib/controllers/chat_controllers/chat_detail_controller.dart`

- Yeni `_pinMessageSubscription` eklendi
- `_onPinMessageUpdate()` metodu eklendi
- Socket listener'da pin event'leri dinleniyor

#### GroupChatDetailController
**Dosya:** `lib/controllers/chat_controllers/group_chat_detail_controller.dart`

- Yeni `_pinMessageSubscription` eklendi
- `_onPinMessageUpdate()` metodu eklendi
- Socket listener'da pin event'leri dinleniyor

### 3. Pin Message Service Güncellemeleri

**Dosya:** `lib/services/pin_message_service.dart`

#### Yeni Metodlar
- `pinGroupMessage(int messageId, String groupId)` - Group mesajları için
- Socket event gönderme özelliği eklendi

#### Socket Event Gönderme
```dart
// Private mesaj için
_socketService.sendMessage('conversation:pin_message', {
  'message_id': messageId,
  'action': 'pin',
});

// Group mesaj için
_socketService.sendMessage('group:pin_message', {
  'message_id': messageId,
  'group_id': groupId,
  'action': 'pin',
});
```

### 4. Pinned Messages Widget Güncellemeleri

**Dosya:** `lib/components/widgets/pinned_messages_widget.dart`

- Real-time güncellemeler için `controller.update()` eklendi
- Hem private hem group chat için destek

## Kullanım

### Private Chat'te Pin/Unpin
1. Kullanıcı bir mesajı pin/unpin yapar
2. `PinMessageService.pinMessage()` çağrılır
3. API'ye istek gönderilir
4. Başarılı olursa socket event gönderilir
5. Tüm bağlı client'lar gerçek zamanlı güncelleme alır

### Group Chat'te Pin/Unpin
1. Kullanıcı bir group mesajını pin/unpin yapar
2. `PinMessageService.pinGroupMessage()` çağrılır
3. API'ye istek gönderilir
4. Başarılı olursa socket event gönderilir
5. Tüm bağlı client'lar gerçek zamanlı güncelleme alır

## Event Formatları

### Gelen Event Formatları

#### Private Chat
```json
{
  "message_id": 123,
  "is_pinned": true,
  "conversation_id": "456"
}
```

#### Group Chat
```json
{
  "message_id": 123,
  "is_pinned": true,
  "group_id": "789"
}
```

### Gönderilen Event Formatları

#### Private Chat
```json
{
  "message_id": 123,
  "action": "pin"
}
```

#### Group Chat
```json
{
  "message_id": 123,
  "group_id": "789",
  "action": "pin"
}
```

## Test

Test için `lib/test_socket_pin.dart` dosyası oluşturuldu. Bu dosya:
- Socket bağlantı durumunu gösterir
- Pin/unpin işlemlerini test eder
- Dinlenen event'leri listeler

## Hata Yönetimi

- Socket bağlantısı kesilirse otomatik yeniden bağlanma
- Event dinleyicileri için try-catch blokları
- Duplicate event kontrolü
- Conversation/Group ID kontrolü

## Performans Optimizasyonları

- Sadece ilgili conversation/group için event işleme
- UI güncellemeleri için `update()` kullanımı
- Stream subscription'ların düzgün temizlenmesi
- Memory leak önleme

## Güvenlik

- Token tabanlı authentication
- Conversation/Group ID doğrulama
- Sadece yetkili kullanıcılar için pin/unpin işlemleri

## Gelecek Geliştirmeler

1. Pin/unpin işlemleri için undo/redo özelliği
2. Pin/unpin geçmişi
3. Pin/unpin bildirimleri
4. Pin/unpin istatistikleri
5. Pin/unpin ayarları (kimler pin/unpin yapabilir)
