# Admin JobFinding — Tài liệu kỹ thuật

Ứng dụng **Admin Dashboard** cho hệ thống tìm việc bán thời gian, được xây dựng bằng **Flutter Web** với kiến trúc **MVVM**, sử dụng **Riverpod** cho State Management và **Dio** cho HTTP client.

---

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart                          # Entry point, khởi tạo ProviderScope
├── core/
│   ├── network/
│   │   ├── api_client.dart            # HTTP client (Dio) với interceptors
│   │   ├── exceptions/
│   │   │   └── api_exception.dart     # Custom exception class
│   │   └── models/
│   │       └── paginated_list_dto.dart# Generic DTO phân trang
│   └── utils/
│       ├── colors.dart                # Design system màu sắc
│       └── constants.dart             # Cấu hình URL và hằng số
└── features/
    ├── auth/                          # Đăng nhập, xác thực Admin
    ├── dashboard/                     # Màn hình tổng quan thống kê
    ├── users/                         # Quản lý người dùng
    ├── companies/                     # Danh sách công ty đã phê duyệt
    ├── company_requests/              # Yêu cầu phê duyệt công ty
    ├── logs/                          # Nhật ký hoạt động hệ thống
    └── main/
        └── views/admin_main_screen.dart  # Shell chính (Sidebar + NavigationRail)
```

Mỗi **feature** tuân theo cùng một cấu trúc nội bộ:
```
features/<tên_module>/
├── models/          # DTO — Ánh xạ JSON ↔ Dart object
├── services/        # Service — Gọi ApiClient, trả về DTO
├── viewmodels/      # ViewModel (Notifier) — Quản lý State
└── views/           # Widget — Render UI
```

---

## 🏛️ Kiến trúc MVVM

### Sơ đồ luồng dữ liệu

```
┌─────────────────────────────────────────────────────────────┐
│                          VIEW                               │
│    (Widget, không chứa business logic)                      │
│    VD: UserManagementView, ApprovedCompanyListView          │
└───────────────────────┬─────────────────────────────────────┘
                        │ watch() / read()  — Riverpod
┌───────────────────────▼─────────────────────────────────────┐
│                       VIEWMODEL                             │
│    (Notifier, quản lý State bất biến — Immutable)           │
│    VD: UserViewModel, CompanyViewModel, AuthViewModel       │
└───────────────────────┬─────────────────────────────────────┘
                        │ gọi method của Service
┌───────────────────────▼─────────────────────────────────────┐
│                       SERVICE                               │
│    (Data layer, gọi ApiClient, trả về DTO)                  │
│    VD: UserService, CompanyService, AuthService             │
└───────────────────────┬─────────────────────────────────────┘
                        │ HTTP GET / POST / PUT / DELETE
┌───────────────────────▼─────────────────────────────────────┐
│                    API CLIENT (Dio)                         │
│    core/network/api_client.dart                             │
│    - Tự động gắn JWT Bearer token (Interceptor)             │
│    - Tự động Refresh Token khi gặp lỗi 401                  │
│    - Unwrap response { success, data, message }             │
│    - Ném ApiException khi có lỗi                            │
└─────────────────────────────────────────────────────────────┘
```

### Quy tắc phân tách trách nhiệm

| Layer | Trách nhiệm | Không được làm |
|-------|-------------|----------------|
| **View** | Render UI, lắng nghe state, gọi action từ ViewModel | Gọi API trực tiếp, chứa logic nghiệp vụ |
| **ViewModel** | Quản lý State, điều phối logic | Gọi Dio/HTTP trực tiếp, render UI |
| **Service** | Giao tiếp với API, parse JSON | Quản lý state của UI |
| **Model (DTO)** | Định nghĩa cấu trúc dữ liệu, `fromJson` | Chứa logic nghiệp vụ |

---

## 🌐 Cách gọi API

### 1. Cấu hình Base URL

```dart
// lib/core/utils/constants.dart
class Constants {
  static const String baseUrl    = 'http://localhost:5000';
  static const String apiBaseUrl = '$baseUrl/api';  // Prefix cho mọi request
}
```

> **Khi test trên thiết bị thật (LAN):** thay `localhost` bằng IP của máy chạy backend.  
> VD: `'http://192.168.1.100:5000'`

---

### 2. Các method HTTP có sẵn

`ApiClient` cung cấp 4 method tương ứng với 4 HTTP verb:

```dart
// GET — Lấy dữ liệu (có thể kèm query params)
final data = await _apiClient.get(
  '/admin/users',
  queryParameters: {
    'pageNumber': 1,
    'pageSize': 10,
    'search': 'keyword',
  },
);

// POST — Tạo mới hoặc thực hiện action
final result = await _apiClient.post(
  '/auth/login',
  data: {'email': 'admin@admin.com', 'password': '123456'},
);

// PUT — Cập nhật dữ liệu
await _apiClient.put(
  '/admin/jobs/3/status',
  data: {'status': 'Active'},
);

// DELETE — Xóa
await _apiClient.delete('/admin/jobs/3');
```

---

### 3. JWT Interceptor — Tự động gắn Token

`ApiClient` tích hợp một **Interceptor** tự động đọc `accessToken` từ `SharedPreferences` và gắn vào Header của **mọi** request — bạn không cần làm gì thêm:

```dart
// Tự động xảy ra TRƯỚC mỗi request
onRequest: (options, handler) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token != null && token.isNotEmpty) {
    options.headers['Authorization'] = 'Bearer $token'; // ← Tự động inject
  }
  return handler.next(options);
},
```

---

### 4. Tự động Refresh Token

Khi API trả về **HTTP 401 Unauthorized**, `ApiClient` sẽ tự xử lý theo quy trình sau:

```
Nhận lỗi 401
    │
    ├─ Lấy refreshToken từ SharedPreferences
    │
    ├─ POST /api/auth/refresh { refreshToken }
    │      ├─ Thành công → Lưu accessToken + refreshToken mới
    │      │              → Retry lại request ban đầu tự động ✅
    │      └─ Thất bại   → Xóa cả 2 token khỏi storage
    │                     → Buộc người dùng đăng nhập lại
    └─ (Chỉ refresh 1 lần — cờ _isRefreshing tránh race condition)
```

---

## 📦 Chuẩn hóa Response

### Cấu trúc JSON chuẩn của Backend

Backend **luôn** trả về theo wrapper thống nhất:

```json
// ✅ Thành công — success = true
{
  "success": true,
  "message": "OK",
  "data": {
    "id": 1,
    "name": "Công ty ABC"
  }
}

// ❌ Thất bại — success = false
{
  "success": false,
  "message": "Không tìm thấy người dùng",
  "data": null
}
```

### ApiClient tự động unwrap

Hàm `_handleResponse()` trong `ApiClient` sẽ tự động:
- Nếu `success == true` → trả về **chỉ phần `data`**
- Nếu `success == false` → ném `ApiException` với message từ server

```dart
// Bên trong ApiClient — Service KHÔNG cần xử lý wrapper
dynamic _handleResponse(Response response) {
  if (response.data is Map<String, dynamic>) {
    final success = response.data['success'];
    if (success == true) {
      return response.data['data']; // ← Service chỉ thấy phần này
    } else {
      throw ApiException(
        response.data['message'] ?? 'Lỗi không xác định',
        response.statusCode,
      );
    }
  }
  return response.data;
}
```

**Kết quả:** Service code cực kỳ gọn — không cần check `success` thủ công:

```dart
// ✅ Trong Service — Chỉ cần parse data, không cần check success
Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await _apiClient.post('/auth/login', data: {...});
  return response as Map<String, dynamic>; // data đã được unwrap sẵn
}
```

---

### PaginatedListDto — Kiểu Generic cho danh sách phân trang

Dùng cho mọi API trả về danh sách có phân trang:

```dart
class PaginatedListDto<T> {
  final List<T> items;        // Danh sách item của trang hiện tại
  final int totalCount;       // Tổng số records trong DB
  final int pageNumber;       // Trang hiện tại (bắt đầu từ 1)
  final int totalPages;       // Tổng số trang
  final bool hasPreviousPage; // Có trang trước không?
  final bool hasNextPage;     // Có trang tiếp theo không?
}
```

**Cách dùng trong Service:**

```dart
Future<PaginatedListDto<UserDto>> getUsers({int pageNumber = 1}) async {
  final response = await _apiClient.get(
    '/admin/users',
    queryParameters: {'pageNumber': pageNumber, 'pageSize': 10},
  );
  return PaginatedListDto.fromJson(
    response,                                           // ← JSON đã unwrap
    (json) => UserDto.fromJson(json as Map<String, dynamic>), // ← Factory của Model
  );
}
```

---

### ApiException — Xử lý lỗi nhất quán

Mọi lỗi từ mạng hoặc backend đều bị bắt và ném dưới dạng `ApiException`:

```dart
class ApiException implements Exception {
  final String message;    // Thông điệp lỗi từ backend hoặc hệ thống
  final int? statusCode;   // HTTP code: 400, 401, 403, 404, 500...
}
```

**Cách bắt lỗi trong ViewModel:**

```dart
try {
  final result = await _service.getUsers();
  state = state.copyWith(isLoading: false, data: result);
} catch (e) {
  // ApiException.toString() trả về: "Lỗi [404]: Không tìm thấy"
  state = state.copyWith(isLoading: false, error: e.toString());
}
```

---

## 🔩 Cách sử dụng Riverpod

### 1. Khởi tạo (bắt buộc)

```dart
// lib/main.dart
void main() {
  runApp(
    const ProviderScope( // ← Phải bọc toàn bộ app
      child: MyApp(),
    ),
  );
}
```

---

### 2. Ba loại Provider được dùng trong dự án

#### `Provider<T>` — Dependency tĩnh (không có state)

```dart
// Singleton — tạo một lần, dùng lại nhiều nơi
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final userServiceProvider = Provider<UserService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return UserService(apiClient); // Inject ApiClient vào Service
});
```

#### `NotifierProvider<Notifier, State>` — State phức tạp với actions

```dart
// Dùng khi cần: cập nhật state + gọi nhiều action (load, search, pagination...)
final userViewModelProvider = NotifierProvider<UserViewModel, UserState>(
  () => UserViewModel(),
);

class UserViewModel extends Notifier<UserState> {
  @override
  UserState build() {
    // Được gọi khi Provider được tạo
    Future.microtask(() => loadUsers()); // Tự động load khi khởi tạo
    return UserState(isLoading: true);
  }

  Future<void> loadUsers({String? search, int? page}) async { ... }
  Future<void> toggleLockUser(int userId, bool isLocked) async { ... }
}
```

#### `FutureProvider<T>` — Async đơn giản (không cần action)

```dart
// Dùng khi chỉ cần load dữ liệu 1 lần, không cần reload hay update
final dashboardViewModelProvider = FutureProvider<AdminStatsDto>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.getStats();
});

// Dùng trong View với .when():
statsAsync.when(
  loading: () => const CircularProgressIndicator(),
  error: (err, _) => Text('Lỗi: $err'),
  data: (stats) => _buildStatsGrid(stats),
)
```

---

### 3. Dùng trong View — `watch` vs `read`

```dart
class UserManagementView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ watch() — Dùng trong build()
    // App TỰ ĐỘNG rebuild khi state thay đổi
    final state = ref.watch(userViewModelProvider);

    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // ✅ read() — Dùng trong event handler (onPressed, onTap...)
            // KHÔNG rebuild, chỉ thực thi action một lần
            ref.read(userViewModelProvider.notifier).loadUsers(page: 2);
          },
          child: const Text('Tải trang 2'),
        ),
        DataTable(rows: state.data?.items.map(...).toList() ?? []),
      ],
    );
  }
}
```

| Hàm | Khi nào dùng | Có rebuild không? |
|-----|-------------|-------------------|
| `ref.watch(provider)` | Trong `build()` | ✅ Có — rebuild khi state thay đổi |
| `ref.read(provider)` | Trong callback, event handler | ❌ Không |
| `ref.read(provider.notifier)` | Gọi method của ViewModel | ❌ Không |

---

### 4. Immutable State với `copyWith`

State luôn được cập nhật bất biến — không bao giờ mutate trực tiếp:

```dart
// ❌ SAI — Mutate trực tiếp
state.isLoading = true;

// ✅ ĐÚNG — Tạo State mới với copyWith
state = state.copyWith(isLoading: true, error: null);
```

Pattern `copyWith` giúp Riverpod phát hiện thay đổi và trigger rebuild đúng cách.

---

## 🔐 Luồng xác thực Admin

```
LoginScreen (View)
    │ Người dùng nhập email + password → bấm Sign In
    ▼
ref.read(authViewModelProvider.notifier).login(email, password)
    │
    ├─ POST /api/auth/login → { accessToken, refreshToken, roles: ["ADMIN"] }
    │
    ├─ Lưu token vào SharedPreferences
    │       'accessToken' = "eyJhbGci..."
    │       'refreshToken' = "eyJhbGci..."
    │
    ├─ Kiểm tra roles.contains("ADMIN")
    │       ├─ TRUE  → AuthStatus.success
    │       │         → Navigator.pushNamed('/dashboard')
    │       └─ FALSE → Xóa token
    │                 → AuthStatus.error: "Không đủ quyền truy cập"
    │
    └─ Sau đó: Mọi API request đều tự động có "Authorization: Bearer <token>"
```

---

## 📝 Hướng dẫn thêm Feature mới

Để thêm module **Job Management** (ví dụ), làm theo thứ tự:

### Bước 1 — Tạo DTO Model

```dart
// lib/features/jobs/models/job_dto.dart
class JobDto {
  final int id;
  final String title;
  final String status;

  JobDto({required this.id, required this.title, required this.status});

  factory JobDto.fromJson(Map<String, dynamic> json) {
    return JobDto(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
```

### Bước 2 — Tạo Service

```dart
// lib/features/jobs/services/job_service.dart
final jobServiceProvider = Provider<JobService>((ref) {
  return JobService(ref.read(apiClientProvider));
});

class JobService {
  final ApiClient _apiClient;
  JobService(this._apiClient);

  Future<PaginatedListDto<JobDto>> getJobs({int pageNumber = 1}) async {
    final response = await _apiClient.get(
      '/admin/jobs',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': 10},
    );
    return PaginatedListDto.fromJson(
      response,
      (json) => JobDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
```

### Bước 3 — Tạo State + ViewModel

```dart
// lib/features/jobs/viewmodels/job_viewmodel.dart
class JobState {
  final bool isLoading;
  final String? error;
  final PaginatedListDto<JobDto>? data;
  final int pageNumber;

  JobState({this.isLoading = false, this.error, this.data, this.pageNumber = 1});

  JobState copyWith({bool? isLoading, String? error, PaginatedListDto<JobDto>? data, int? pageNumber}) {
    return JobState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class JobViewModel extends Notifier<JobState> {
  @override
  JobState build() {
    Future.microtask(() => loadJobs());
    return JobState(isLoading: true);
  }

  Future<void> loadJobs({int? page}) async {
    final newPage = page ?? state.pageNumber;
    state = state.copyWith(isLoading: true, error: null, pageNumber: newPage);
    try {
      final result = await ref.read(jobServiceProvider).getJobs(pageNumber: newPage);
      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final jobViewModelProvider = NotifierProvider<JobViewModel, JobState>(() => JobViewModel());
```

### Bước 4 — Tạo View

```dart
// lib/features/jobs/views/job_management_view.dart
class JobManagementView extends ConsumerWidget {
  const JobManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobViewModelProvider);

    if (state.isLoading && state.data == null) return const Center(child: CircularProgressIndicator());
    if (state.error != null) return Center(child: Text('Lỗi: ${state.error}'));

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            rows: state.data?.items.map((job) => DataRow(cells: [
              DataCell(Text(job.id.toString())),
              DataCell(Text(job.title)),
              DataCell(Text(job.status)),
            ])).toList() ?? [],
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Tiêu đề')),
              DataColumn(label: Text('Trạng thái')),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Bước 5 — Đăng ký vào AdminMainScreen

```dart
// lib/features/main/views/admin_main_screen.dart
final pages = [
  const OverviewView(),
  const UserManagementView(),
  const CompanyMainView(),
  const JobManagementView(), // ← Thêm vào đây
  const LogsMainView(),
];
```

---

## ⚙️ Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^3.3.1    # State Management (NotifierProvider)
  dio: ^5.9.2                  # HTTP Client với Interceptor
  shared_preferences: ^2.5.5   # Lưu JWT token cục bộ
  flutter_svg: ^2.2.4          # Render SVG
```

---

## 🚀 Chạy dự án

```bash
# 1. Khởi động Backend (cần chạy trước)
cd Backend_PartTimeJobs/PTJ.API
dotnet run
# Backend sẽ chạy tại http://localhost:5000

# 2. Khởi động Admin Dashboard
cd admin_appjobfinding
flutter run -d chrome
```

> Tài khoản Admin mặc định: `Admin@admin.com` — Phải có role `ADMIN` trong database.
