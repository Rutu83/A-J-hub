# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# OkHttp / Retrofit (used internally by Dio)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Airpay SDK
-keep class com.airpay.** { *; }
-dontwarn com.airpay.**

# Encryption / Crypto
-keep class javax.crypto.** { *; }
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Keep model classes (adjust package as needed)
-keep class com.ajhubdesignapp.ajhub_app.** { *; }

# Prevent stripping of annotations used by MobX
-keep @interface mobx.** { *; }
-keepattributes *Annotation*

# General
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
