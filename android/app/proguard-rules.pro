# Keep PyTorch related classes from being stripped or obfuscated
-keep class org.pytorch.** { *; }
-keep class com.facebook.jni.** { *; }
-dontwarn org.pytorch.**
-dontwarn com.facebook.jni.**

# Flutter Pytorch Lite Plugin classes
-keep class io.github.winfordguo.flutter_pytorch_lite.** { *; }

# Keep standard JNI classes
-keep class com.facebook.soloader.** { *; }
-dontwarn com.facebook.soloader.**
