# 📱 iOS Todo & Reminders App (Flutter)

Ứng dụng quản lý công việc và nhắc nhở theo phong cách **Apple iOS (Apple Human Interface Guidelines)** được xây dựng bằng **Flutter**.

---

## ✨ Tính năng nổi bật

- 🔔 **Hẹn giờ thông báo đẩy (Local Push Notifications)**: Tích hợp `flutter_local_notifications` với timezone, lên lịch chính xác theo ngày/giờ và tự động hủy khi task hoàn thành.
- 🎨 **Giao diện chuẩn iOS 17/18**:
  - Thẻ thống kê thông minh dạng 2x2 (*Hôm nay, Đã lên lịch, Tất cả, Khẩn cấp*).
  - Hỗ trợ đầy đủ **Light Mode** và **Dark Mode** tự động.
  - Phím chọn ngày & giờ dạng bánh xe trượt đặc trưng của Apple (`CupertinoDatePicker`).
- ⚡ **Thao tác cử chỉ mượt mà (Gestures)**:
  - Vuốt sang phải để **Chỉnh sửa (Edit)**.
  - Vuốt sang trái để **Xóa (Delete)** có hộp thoại xác nhận iOS.
- 🗂️ **Quản lý danh mục & Mức độ ưu tiên**:
  - Phân loại: *Cá nhân, Công việc, Học tập, Mua sắm, Sức khỏe* hoặc tạo danh mục mới tùy chỉnh.
  - 4 mức độ ưu tiên: *Thấp, Trung bình, Cao, Khẩn cấp*.
  - Hỗ trợ công việc con (Subtasks) với checklist mở rộng.
- 💾 **Lưu trữ ngoại tuyến (Offline Storage)**: Tự động lưu trữ an toàn trên thiết bị qua `SharedPreferences`.

---

## 📂 Cấu trúc thư mục mã nguồn

```
lib/
├── main.dart                       # Entrypoint & khởi tạo NotificationService
├── theme/
│   └── ios_theme.dart              # Bảng màu Apple HIG & cấu hình Dark/Light theme
├── models/
│   ├── todo_item.dart              # Model Todo, Subtask & PriorityLevel
│   └── category.dart               # Model Danh mục (Icon & Màu sắc)
├── services/
│   ├── storage_service.dart        # Lưu trữ offline & đọc dữ liệu
│   └── notification_service.dart   # Quản lý lên lịch & kích hoạt thông báo iOS
├── providers/
│   └── todo_provider.dart          # State Management tập trung
├── widgets/
│   ├── todo_tile.dart              # Thẻ công việc kèm animation checkbox & swipe actions
│   ├── category_card.dart          # Thẻ danh mục dashboard
│   ├── ios_search_bar.dart         # Thanh tìm kiếm bo góc iOS
│   └── priority_badge.dart         # Huy hiệu mức độ ưu tiên
└── screens/
    ├── home_screen.dart            # Màn hình chính (Dashboard Apple Reminders)
    ├── add_edit_todo_screen.dart   # Form thêm/sửa tác vụ với Cupertino Pickers
    ├── category_detail_screen.dart # Chi tiết danh mục & thanh tiến độ hoàn thành
    └── settings_screen.dart        # Cài đặt giao diện & thử nghiệm thông báo
```

---

## 🚀 Hướng dẫn cài đặt & Chạy ứng dụng

### 1. Yêu cầu môi trường
- Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản $\ge$ 3.0.0).
- **Để build trực tiếp lên iPhone**: Cần máy tính Mac có cài **Xcode** và kết nối iPhone qua cáp.
- Hoặc bạn có thể chạy thử nghiệm trên **Flutter Web / Android / Windows** ngay trên máy tính Windows.

### 2. Tải dependencies
Mở Terminal tại thư mục `d:\Users\IphoneApp` và chạy:
```bash
flutter pub get
```

### 3. Chạy ứng dụng

- **Chạy trên iPhone thật / iOS Simulator (trên máy Mac)**:
  ```bash
  flutter run -d ios
  ```

- **Chạy thử nghiệm trên Trình duyệt Web (Chrome) ngay trên Windows**:
  ```bash
  flutter run -d chrome
  ```

- **Chạy trên thiết bị Android**:
  ```bash
  flutter run -d android
  ```

---

## 🔔 Kiểm tra tính năng Thông báo (Push Notifications)
1. Mở ứng dụng $\rightarrow$ Nhấn vào biểu tượng **Bánh răng (Cài đặt)** ở góc trên bên phải.
2. Nhấn **"Kiểm tra quyền thông báo iOS"** để cấp quyền.
3. Nhấn **"Gửi thông báo thử nghiệm ngay"** để kiểm tra âm thanh và banner thông báo.
4. Khi thêm nhắc nhở mới, bật nút **"Hẹn giờ thông báo"** và chọn giờ nhắc để hệ thống tự động bắn notification khi tới giờ!
