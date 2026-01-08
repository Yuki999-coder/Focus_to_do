# Focus To-Do

**Focus To-Do** là một ứng dụng quản lý năng suất được xây dựng bằng **Flutter**. Ứng dụng kết hợp giữa bộ đếm thời gian tập trung (Pomodoro Timer) và quản lý danh sách công việc (Task Management), giúp người dùng duy trì sự tập trung và theo dõi hiệu suất làm việc hiệu quả.

## 🚀 Giới thiệu

Dự án này được thiết kế để giúp bạn quản lý thời gian và công việc hàng ngày một cách khoa học. Bạn có thể đặt mục tiêu thời gian để tập trung làm việc, nghỉ ngơi hợp lý, và theo dõi tiến độ hoàn thành các đầu việc quan trọng.

## ✨ Tính năng chính

### 1. ⏱️ Focus Timer (Đồng hồ tập trung)

- **Chế độ Pomodoro:** Đặt thời gian tập trung (Focus) và nghỉ ngơi (Break) tùy chỉnh.
- **Stopwatch Mode:** Chế độ bấm giờ đếm ngược.
- **Tùy chỉnh giao diện:** Thay đổi hình nền (Đen, Trắng, Hình ảnh vũ trụ...) để tạo cảm hứng.
- **Âm thanh:** Tùy chọn âm thanh nền và âm thanh hoàn thành (Clock Tick, Vine Boom...).
- **Chế độ toàn màn hình (Full Screen):** Giúp giảm xao nhãng.
- **Strict Mode:** Chế độ nghiêm ngặt (khóa các thao tác khác để tập trung tối đa).

### 2. ✅ Task Management (Quản lý công việc)

- **Tạo & Chỉnh sửa:** Thêm công việc mới với tên, ngày hết hạn (Due Date) và giờ nhắc nhở (Reminder).
- **Bộ lọc thông minh:** Xem công việc theo "Hôm nay", "Ngày mai", hoặc "Tuần này".
- **Liên kết Timer:** Chọn một công việc cụ thể để bắt đầu đếm giờ tập trung cho công việc đó.
- **Trạng thái:** Đánh dấu hoàn thành hoặc chưa hoàn thành, ẩn/hiện các việc đã xong.

### 3. 📊 Thống kê & Lịch sử

- **Stats (Thống kê):** Biểu đồ trực quan (sử dụng `fl_chart`) để theo dõi thời gian tập trung và năng suất.
- **Timeline:** Xem lại lịch sử hoạt động và các phiên làm việc đã hoàn thành.

### 4. ⚙️ Cài đặt & Hồ sơ

- Quản lý thông tin cá nhân và các cài đặt chung của ứng dụng.

## 📱 Cấu trúc màn hình

Ứng dụng bao gồm 5 màn hình chính được điều hướng qua thanh Bottom Navigation:

1.  **Focus:** Màn hình chính với đồng hồ đếm giờ.
2.  **Tasks:** Danh sách các công việc cần làm.
3.  **Stats:** Biểu đồ thống kê năng suất.
4.  **Timeline:** Dòng thời gian hoạt động.
5.  **Profile:** Thông tin người dùng và cài đặt.

## 🛠️ Công nghệ sử dụng

- **Framework:** Flutter (Dart)
- **Quản lý trạng thái:** `ListenableBuilder`, `StatefulWidget`
- **Lưu trữ cục bộ:** `shared_preferences`
- **Biểu đồ:** `fl_chart`
- **Âm thanh:** `audioplayers`
- **Định dạng ngày tháng:** `intl`

## 📦 Cài đặt và Chạy ứng dụng

Để chạy dự án này trên máy cục bộ của bạn:

1.  **Yêu cầu:** Đảm bảo bạn đã cài đặt Flutter SDK.

2.  **Clone dự án (hoặc tải về):**

    ```bash
    git clone <repository-url>
    cd focus_to_do
    ```

3.  **Cài đặt các thư viện phụ thuộc:**

    ```bash
    flutter pub get
    ```

4.  **Chạy ứng dụng:**
    Kết nối thiết bị thật hoặc mở máy ảo (Android Emulator / iOS Simulator), sau đó chạy:
    ```bash
    flutter run
    ```

## 📂 Cấu trúc thư mục

- `lib/screens/`: Chứa giao diện các màn hình (Focus, Tasks, Stats, Timeline, Profile).
- `lib/widgets/`: Các widget tái sử dụng (như TaskItem).
- `lib/models/`: Các mô hình dữ liệu (Task, ClockTheme).
- `lib/services/`: Xử lý logic nghiệp vụ (TimerService).
- `assets/`: Chứa hình ảnh và âm thanh.
