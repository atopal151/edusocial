# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# OneSignal
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# Socket.IO rules
-keep class io.socket.** { *; }
-keep class io.socket.client.** { *; }

# HTTP client rules
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# JSON parsing rules
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep model classes
-keep class com.social.edusocial.models.** { *; }

# Suppress warnings
-dontwarn okhttp3.**
-dontwarn io.socket.**
-dontwarn com.google.gson.**

# General rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception 