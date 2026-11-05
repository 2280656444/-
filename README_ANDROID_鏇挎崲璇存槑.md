# android 目录替换说明

1. 在仓库根目录删除原来的 android 文件夹
2. 把这个压缩包里的 android 文件夹整个放到仓库根目录（与 pubspec.yaml 同级）
3. 把 .github/workflows/build.yml 覆盖到仓库里
4. 提交推送即可触发构建

已做的事：
- 包名统一为 com.yourname.rili（namespace / applicationId / MainActivity 路径三处一致）
- styles.xml 含 LaunchTheme 和 NormalTheme，启动屏引用 @drawable/launch_background
- 桌面显示名为“日历”，已生成红色“日”字图标
- JDK 17 + Gradle 8.7 + AGP 8.1.4 + Kotlin 1.9.22（Flutter 3.24.5 兼容组合）
- 有签名密钥时把 key.properties 放到 android/app/ 下即自动用正式签名，没有则用 debug 签名

仍需你确认：
- pubspec.yaml 里用到通知插件时，android:label 等无需再改
- 若 pubspec 中的包名/插件需要额外权限，在 AndroidManifest.xml 的 <uses-permission> 处补
