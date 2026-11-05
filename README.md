# 日厤 · 黄历日历与岁时记录

## 功能
- 月历：农历、干支、节气、节日、法定假/调休（休/班角标）
- 黄历详情：宜忌、冲煞、值神、星宿、胎神、吉神凶煞（[lunar](https://pub.dev/packages/lunar) 包计算，1900-2100）
- 历史上的今天：维基百科中文 REST API，本地 366 天 JSON 兜底（CC BY-SA 3.0）
- 日程 / 纪念日（sqflite）、定时提醒（flutter_local_notifications）

## 上传前必做
1. 改包名：`android/app/build.gradle.kts` 的 `namespace` / `applicationId`（`com.yourname.rili`），把
   `android/app/src/main/kotlin/com/yourname/rili/` 目录改成对应路径
2. 生成本地 gradle wrapper：本机装有 JDK 17 后执行
   `cd android && gradle wrapper --gradle-version 8.7`
3. 生成签名：
   ```bash
   keytool -genkeypair -v -keystore android/app/rili-key.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias rili \
     -storepass 密码 -keypass 密码 \
     -dname "CN=你, OU=Rili, O=Rili, L=Qingdao, S=Shandong, C=CN"
   ```
4. GitHub 仓库 Settings → Secrets and variables → Actions 添加：
   `KEYSTORE_BASE64`（`base64 -i android/app/rili-key.jks` 的输出）、`STORE_PASSWORD`、`KEY_PASSWORD`、`KEY_ALIAS=rili`

## 本地运行
```bash
flutter pub get
flutter run
```

## 历史数据
```bash
python3 tools/gen_history.py      # 抓中文维基，生成 366 天 JSON
```
GitHub Actions 每次构建前自动抓取；每月 1 号自动刷新并提交。

## 已知待办
- [ ] 2026 年法定假日为内置估算值，国务院公布后以云端源为准或更新 `holidays_2026.json`
- [ ] 启动时动态申请通知权限（Android 13+）
