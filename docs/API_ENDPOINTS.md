# 📚 Dokumentasi API Endpoints Seven Caffee Staff Mobile

Dokumen ini berisi spesifikasi lengkap semua API endpoints yang diperlukan oleh aplikasi mobile Seven Caffee Staff agar dapat berkomunikasi dengan backend Laravel.

**Status**: ✅ Siap untuk implementasi di backend  
**Versi Dokumentasi**: 1.0.0  
**Last Updated**: May 16, 2026

---

## 📑 Daftar Isi

- [Base URL & Authentication](#-base-url--authentication)
- [Standard Response Format](#-standard-response-format)
- [1. Authentication Endpoints](#1-authentication-endpoints)
- [2. Staff Profile Endpoints](#2-staff-profile-endpoints)
- [3. Attendance Endpoints](#3-attendance-endpoints)
- [4. Tables Endpoints](#4-tables-endpoints)
- [5. Orders Endpoints](#5-orders-endpoints)
- [6. Notifications Endpoints](#6-notifications-endpoints)
- [7. Error Codes & Status](#7-error-codes--status)

---

## 🔗 Base URL & Authentication

### Base URL

```
Development:  http://192.168.x.x:8000/api
Production:   https://yourdomain.com/api
```

### Headers (Semua Request Kecuali Login)

```http
Authorization: Bearer {access_token}
Content-Type: application/json
Accept: application/json
```

### Authentication Method

- **Type**: Bearer Token (JWT atau Laravel Sanctum)
- **Location**: `Authorization` header
- **Example**: `Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

---

## 📋 Standard Response Format

### Success Response (2xx)

```json
{
  "success": true,
  "message": "Deskripsi operasi berhasil",
  "data": {
    // Response data sesuai endpoint
  }
}
```

### Error Response (4xx, 5xx)

```json
{
  "success": false,
  "message": "Deskripsi error",
  "error_code": "ERROR_CODE",
  "data": null
}
```

### Pagination Response

```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [
    // array of items
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 15,
    "total": 100,
    "last_page": 7,
    "from": 1,
    "to": 15
  }
}
```

---

## 1. Authentication Endpoints

### 1.1 Login Staff

**Endpoint**: `POST /auth/login`

**Description**: Autentikasi staff dengan email dan password

**Request Body**:

```json
{
  "email": "staff@sevencaffee.com",
  "password": "password123"
}
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 86400,
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "staff@sevencaffee.com",
      "role": "staff",
      "position": "Barista",
      "department": "Kitchen"
    }
  }
}
```

**Error Response (401)**:

```json
{
  "success": false,
  "message": "Email atau password salah",
  "error_code": "INVALID_CREDENTIALS"
}
```

---

### 1.2 Forgot Password

**Endpoint**: `POST /auth/forgot-password`

**Description**: Request reset password link via email

**Request Body**:

```json
{
  "email": "staff@sevencaffee.com"
}
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Link reset password telah dikirim ke email Anda"
}
```

**Error Response (404)**:

```json
{
  "success": false,
  "message": "Email tidak ditemukan",
  "error_code": "EMAIL_NOT_FOUND"
}
```

---

### 1.3 Reset Password

**Endpoint**: `POST /auth/reset-password`

**Description**: Reset password dengan token dari email

**Request Body**:

```json
{
  "email": "staff@sevencaffee.com",
  "token": "reset_token_from_email",
  "password": "password_baru",
  "password_confirmation": "password_baru"
}
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Password berhasil direset"
}
```

**Error Response (400)**:

```json
{
  "success": false,
  "message": "Token tidak valid atau sudah expired",
  "error_code": "INVALID_TOKEN"
}
```

---

### 1.4 Logout

**Endpoint**: `POST /auth/logout`

**Description**: Logout dan invalidate token

**Headers**: `Authorization: Bearer {token}`

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Logout berhasil"
}
```

---

### 1.5 Refresh Token

**Endpoint**: `POST /auth/refresh-token`

**Description**: Refresh access token untuk memperpanjang session

**Headers**: `Authorization: Bearer {token}`

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Token berhasil direfresh",
  "data": {
    "token": "new_token_here",
    "token_type": "Bearer",
    "expires_in": 86400
  }
}
```

---

## 2. Staff Profile Endpoints

### 2.1 Get Profile

**Endpoint**: `GET /profile`

**Description**: Ambil data profil staff yang sedang login

**Headers**: `Authorization: Bearer {token}`

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "staff@sevencaffee.com",
    "phone": "08123456789",
    "position": "Barista",
    "department": "Kitchen",
    "hire_date": "2023-01-15",
    "avatar": "https://api.example.com/storage/avatars/user_1.jpg",
    "status": "active"
  }
}
```

---

### 2.2 Update Profile

**Endpoint**: `PUT /profile/update`

**Description**: Update data profil staff

**Headers**: `Authorization: Bearer {token}`

**Request Body**:

```json
{
  "name": "John Doe Updated",
  "phone": "08987654321"
}
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Profil berhasil diupdate",
  "data": {
    "id": 1,
    "name": "John Doe Updated",
    "email": "staff@sevencaffee.com",
    "phone": "08987654321",
    "position": "Barista",
    "department": "Kitchen"
  }
}
```

---

### 2.3 Change Password

**Endpoint**: `PUT /profile/change-password`

**Description**: Ubah password staff

**Headers**: `Authorization: Bearer {token}`

**Request Body**:

```json
{
  "current_password": "password_lama",
  "new_password": "password_baru",
  "password_confirmation": "password_baru"
}
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Password berhasil diubah"
}
```

**Error Response (400)**:

```json
{
  "success": false,
  "message": "Password lama tidak sesuai",
  "error_code": "INVALID_CURRENT_PASSWORD"
}
```

---

## 3. Attendance Endpoints

### 3.1 Clock In

**Endpoint**: `POST /staff/clock-in`

**Description**: Pencatatan waktu masuk kerja

**Headers**: `Authorization: Bearer {token}`

**Request Body**:

```json
{
  "latitude": -6.1751,
  "longitude": 106.865
}
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Clock in berhasil",
  "data": {
    "id": 1,
    "staff_id": 1,
    "date": "2026-05-16",
    "clock_in_time": "2026-05-16 08:00:00",
    "clock_out_time": null,
    "status": "present",
    "location_in": {
      "latitude": -6.1751,
      "longitude": 106.865
    }
  }
}
```

**Error Response (400)**:

```json
{
  "success": false,
  "message": "Anda sudah clock in hari ini",
  "error_code": "ALREADY_CLOCKED_IN"
}
```

---

### 3.2 Clock Out

**Endpoint**: `POST /staff/clock-out`

**Description**: Pencatatan waktu keluar kerja

**Headers**: `Authorization: Bearer {token}`

**Request Body**:

```json
{
  "latitude": -6.1751,
  "longitude": 106.865
}
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Clock out berhasil",
  "data": {
    "id": 1,
    "staff_id": 1,
    "date": "2026-05-16",
    "clock_in_time": "2026-05-16 08:00:00",
    "clock_out_time": "2026-05-16 17:00:00",
    "work_hours": 9,
    "status": "present",
    "location_out": {
      "latitude": -6.1751,
      "longitude": 106.865
    }
  }
}
```

---

### 3.3 Get Attendance History

**Endpoint**: `GET /staff/attendance`

**Description**: Riwayat kehadiran bulan berjalan

**Headers**: `Authorization: Bearer {token}`

**Query Parameters**:

```
?page=1&per_page=15&month=5&year=2026
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Attendance history retrieved",
  "data": [
    {
      "id": 1,
      "staff_id": 1,
      "date": "2026-05-16",
      "clock_in": "08:00:00",
      "clock_out": "17:00:00",
      "work_hours": 9,
      "status": "present"
    },
    {
      "id": 2,
      "staff_id": 1,
      "date": "2026-05-15",
      "clock_in": "08:30:00",
      "clock_out": "17:15:00",
      "work_hours": 8.75,
      "status": "present"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 15,
    "total": 20,
    "last_page": 2
  }
}
```

---

### 3.4 Get Attendance by Date

**Endpoint**: `GET /staff/attendance/{date}`

**Description**: Riwayat kehadiran tanggal spesifik

**Headers**: `Authorization: Bearer {token}`

**URL Parameters**:

- `date`: Format `YYYY-MM-DD` (contoh: `2026-05-16`)

**Response (200 OK)**:

```json
{
  "success": true,
  "data": {
    "id": 1,
    "date": "2026-05-16",
    "clock_in": "08:00:00",
    "clock_out": "17:00:00",
    "work_hours": 9,
    "status": "present",
    "location_in": {"latitude": -6.1751, "longitude": 106.865},
    "location_out": {"latitude": -6.1751, "longitude": 106.865}
  }
}
```

---

### 3.5 Get Attendance Summary

**Endpoint**: `GET /staff/attendance/summary`

**Description**: Summary kehadiran (total jam kerja, dll)

**Headers**: `Authorization: Bearer {token}`

**Query Parameters**:

```
?month=5&year=2026
```

**Response (200 OK)**:

```json
{
  "success": true,
  "data": {
    "month": 5,
    "year": 2026,
    "total_days": 22,
    "present_days": 20,
    "absent_days": 1,
    "leave_days": 1,
    "total_hours": 176.5,
    "average_hours_per_day": 8.825,
    "overtime_hours": 2.5
  }
}
```

---

## 4. Tables Endpoints

### 4.1 Get All Tables

**Endpoint**: `GET /staff/tables`

**Description**: Daftar semua meja dengan status

**Headers**: `Authorization: Bearer {token}`

**Query Parameters**:

```
?page=1&per_page=20&status=empty&location=outdoor
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Tables retrieved successfully",
  "data": [
    {
      "id": 1,
      "number": "T01",
      "capacity": 4,
      "location": "outdoor",
      "status": "empty",
      "coordinates": {"x": 100, "y": 150},
      "last_updated": "2026-05-16 10:30:00",
      "notes": null
    },
    {
      "id": 2,
      "number": "T02",
      "capacity": 6,
      "location": "indoor",
      "status": "occupied",
      "coordinates": {"x": 200, "y": 150},
      "last_updated": "2026-05-16 10:25:00",
      "notes": "Sedang makan"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total": 35
  }
}
```

---

### 4.2 Get Table Detail

**Endpoint**: `GET /staff/tables/{id}`

**Description**: Detail meja tertentu

**Headers**: `Authorization: Bearer {token}`

**URL Parameters**:

- `id`: Table ID (contoh: `1`)

**Response (200 OK)**:

```json
{
  "success": true,
  "data": {
    "id": 1,
    "number": "T01",
    "capacity": 4,
    "location": "outdoor",
    "status": "empty",
    "coordinates": {"x": 100, "y": 150},
    "created_at": "2026-01-01",
    "last_updated": "2026-05-16 10:30:00",
    "current_order": null,
    "notes": null
  }
}
```

---

### 4.3 Update Table Status

**Endpoint**: `PUT /staff/tables/{id}`

**Description**: Update status meja

**Headers**: `Authorization: Bearer {token}`

**URL Parameters**:

- `id`: Table ID

**Request Body**:

```json
{
  "status": "empty",
  "notes": "Meja sudah dibersihkan"
}
```

**Status Values**:

- `empty`: Meja kosong/siap digunakan
- `occupied`: Meja sedang digunakan
- `reserved`: Meja direservasi
- `maintenance`: Meja sedang diperbaiki/dibersihkan

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Status meja berhasil diupdate",
  "data": {
    "id": 1,
    "number": "T01",
    "status": "empty",
    "last_updated": "2026-05-16 10:35:00"
  }
}
```

---

### 4.4 Scan Table via QR Code

**Endpoint**: `POST /staff/scan-table`

**Description**: Scanning meja via QR code

**Headers**: `Authorization: Bearer {token}`

**Request Body**:

```json
{
  "qr_code": "TABLE_001_QR"
}
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Scanning berhasil",
  "data": {
    "table_id": 1,
    "table_number": "T01",
    "status": "empty",
    "capacity": 4,
    "location": "outdoor"
  }
}
```

**Error Response (404)**:

```json
{
  "success": false,
  "message": "QR Code tidak valid atau meja tidak ditemukan",
  "error_code": "INVALID_QR_CODE"
}
```

---

### 4.5 Get Tables Layout (Denah)

**Endpoint**: `GET /staff/tables/layout`

**Description**: Denah layout meja untuk visualisasi

**Headers**: `Authorization: Bearer {token}`

**Response (200 OK)**:

```json
{
  "success": true,
  "data": {
    "layout": {
      "width": 800,
      "height": 600,
      "tables": [
        {
          "id": 1,
          "number": "T01",
          "x": 100,
          "y": 150,
          "width": 80,
          "height": 60,
          "capacity": 4,
          "status": "empty",
          "location": "outdoor"
        }
      ]
    }
  }
}
```

---

## 5. Orders Endpoints

### 5.1 Get All Orders

**Endpoint**: `GET /staff/orders`

**Description**: List semua pesanan

**Headers**: `Authorization: Bearer {token}`

**Query Parameters**:

```
?page=1&per_page=15&status=pending&sort=created_at&order=desc
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Orders retrieved successfully",
  "data": [
    {
      "id": 1,
      "order_number": "ORD-2026-0001",
      "table_id": 1,
      "table_number": "T01",
      "customer_name": "Budi",
      "items": [
        {
          "id": 1,
          "product_id": 5,
          "product_name": "Cappuccino",
          "quantity": 2,
          "price": 25000,
          "subtotal": 50000,
          "notes": "Less sugar"
        }
      ],
      "status": "pending",
      "payment_status": "unpaid",
      "created_at": "2026-05-16 10:00:00",
      "updated_at": "2026-05-16 10:00:00",
      "total_price": 50000,
      "queue_number": 1
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 15,
    "total": 45
  }
}
```

---

### 5.2 Get Order Detail

**Endpoint**: `GET /staff/orders/{id}`

**Description**: Detail pesanan tertentu

**Headers**: `Authorization: Bearer {token}`

**URL Parameters**:

- `id`: Order ID

**Response (200 OK)**:

```json
{
  "success": true,
  "data": {
    "id": 1,
    "order_number": "ORD-2026-0001",
    "table_id": 1,
    "table_number": "T01",
    "customer_name": "Budi",
    "items": [
      {
        "id": 1,
        "product_id": 5,
        "product_name": "Cappuccino",
        "quantity": 2,
        "price": 25000,
        "subtotal": 50000,
        "notes": "Less sugar",
        "status": "pending"
      }
    ],
    "status": "pending",
    "payment_status": "unpaid",
    "created_at": "2026-05-16 10:00:00",
    "total_price": 50000,
    "queue_number": 1
  }
}
```

---

### 5.3 Update Order Status

**Endpoint**: `PUT /staff/orders/{id}`

**Description**: Update status pesanan

**Headers**: `Authorization: Bearer {token}`

**URL Parameters**:

- `id`: Order ID

**Request Body**:

```json
{
  "status": "preparing"
}
```

**Status Values**:

- `pending`: Pesanan baru/dalam antrian
- `preparing`: Sedang disiapkan
- `ready`: Siap disajikan
- `served`: Sudah disajikan
- `completed`: Selesai
- `cancelled`: Dibatalkan

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Status pesanan diupdate ke preparing",
  "data": {
    "id": 1,
    "order_number": "ORD-2026-0001",
    "status": "preparing",
    "updated_at": "2026-05-16 10:05:00"
  }
}
```

---

### 5.4 Filter Orders by Status

**Endpoint**: `GET /staff/orders/status/{status}`

**Description**: Filter pesanan berdasarkan status

**Headers**: `Authorization: Bearer {token}`

**URL Parameters**:

- `status`: `pending`, `preparing`, `ready`, `served`, `completed`, `cancelled`

**Query Parameters**:

```
?page=1&per_page=15
```

**Response (200 OK)**:

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "order_number": "ORD-2026-0001",
      "table_number": "T01",
      "customer_name": "Budi",
      "status": "pending",
      "created_at": "2026-05-16 10:00:00",
      "total_price": 50000
    }
  ]
}
```

---

### 5.5 Get Orders by Table

**Endpoint**: `GET /staff/orders/table/{table_id}`

**Description**: Pesanan untuk meja tertentu

**Headers**: `Authorization: Bearer {token}`

**URL Parameters**:

- `table_id`: Table ID

**Response (200 OK)**:

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "order_number": "ORD-2026-0001",
      "table_id": 1,
      "status": "pending",
      "created_at": "2026-05-16 10:00:00",
      "items": [...]
    }
  ]
}
```

---

### 5.6 Mark Order as Ready

**Endpoint**: `POST /staff/orders/{id}/ready`

**Description**: Mark pesanan sebagai ready

**Headers**: `Authorization: Bearer {token}`

**URL Parameters**:

- `id`: Order ID

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Pesanan ORD-2026-0001 siap disajikan",
  "data": {
    "id": 1,
    "status": "ready",
    "updated_at": "2026-05-16 10:10:00"
  }
}
```

---

### 5.7 Mark Order as Served

**Endpoint**: `POST /staff/orders/{id}/served`

**Description**: Mark pesanan sebagai served

**Headers**: `Authorization: Bearer {token}`

**URL Parameters**:

- `id`: Order ID

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Pesanan ORD-2026-0001 sudah disajikan",
  "data": {
    "id": 1,
    "status": "served",
    "updated_at": "2026-05-16 10:15:00"
  }
}
```

---

## 6. Notifications Endpoints

### 6.1 Get Notifications

**Endpoint**: `GET /notifications`

**Description**: List notifikasi untuk staff

**Headers**: `Authorization: Bearer {token}`

**Query Parameters**:

```
?page=1&per_page=15&is_read=false
```

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Notifications retrieved",
  "data": [
    {
      "id": 1,
      "title": "Pesanan Baru",
      "message": "Pesanan ORD-2026-0001 untuk meja T01",
      "type": "order",
      "related_id": 1,
      "is_read": false,
      "created_at": "2026-05-16 10:15:00"
    },
    {
      "id": 2,
      "title": "Pesanan Siap",
      "message": "Pesanan ORD-2026-0002 siap disajikan",
      "type": "order",
      "related_id": 2,
      "is_read": true,
      "created_at": "2026-05-16 10:10:00"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 15,
    "total": 50,
    "unread_count": 5
  }
}
```

---

### 6.2 Get Unread Notifications

**Endpoint**: `GET /notifications/unread`

**Description**: Notifikasi yang belum dibaca

**Headers**: `Authorization: Bearer {token}`

**Response (200 OK)**:

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Pesanan Baru",
      "message": "Pesanan ORD-2026-0001 untuk meja T01",
      "type": "order",
      "created_at": "2026-05-16 10:15:00"
    }
  ],
  "unread_count": 5
}
```

---

### 6.3 Mark Notification as Read

**Endpoint**: `PUT /notifications/{id}/read`

**Description**: Mark notifikasi sebagai dibaca

**Headers**: `Authorization: Bearer {token}`

**URL Parameters**:

- `id`: Notification ID

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Notifikasi berhasil ditandai sebagai dibaca"
}
```

---

### 6.4 Delete Notification

**Endpoint**: `DELETE /notifications/{id}`

**Description**: Hapus notifikasi

**Headers**: `Authorization: Bearer {token}`

**URL Parameters**:

- `id`: Notification ID

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Notifikasi berhasil dihapus"
}
```

---

### 6.5 Register Device for Push Notifications

**Endpoint**: `POST /notifications/register-device`

**Description**: Register device untuk push notification

**Headers**: `Authorization: Bearer {token}`

**Request Body**:

```json
{
  "device_token": "fcm_token_here",
  "device_type": "android",
  "device_name": "Redmi Note 10"
}
```

**Device Type Values**:

- `android`: Android device
- `ios`: iOS device

**Response (200 OK)**:

```json
{
  "success": true,
  "message": "Device berhasil didaftarkan untuk push notification"
}
```

---

## 7. Error Codes & Status

### HTTP Status Codes

| Code | Meaning              | Example                                    |
| ---- | -------------------- | ------------------------------------------ |
| 200  | OK                   | Request berhasil                           |
| 201  | Created              | Resource berhasil dibuat                   |
| 400  | Bad Request          | Data tidak valid / missing required fields |
| 401  | Unauthorized         | Token tidak valid / expired                |
| 403  | Forbidden            | User tidak punya akses ke resource         |
| 404  | Not Found            | Resource tidak ditemukan                   |
| 409  | Conflict             | Data conflict (misal: sudah clock in)      |
| 422  | Unprocessable Entity | Validasi error                             |
| 500  | Server Error         | Internal server error                      |

### Standard Error Codes

| Error Code            | HTTP Code | Description                          |
| --------------------- | --------- | ------------------------------------ |
| `INVALID_CREDENTIALS` | 401       | Email atau password salah            |
| `INVALID_TOKEN`       | 401       | Token tidak valid atau sudah expired |
| `TOKEN_EXPIRED`       | 401       | Token sudah kadaluarsa               |
| `UNAUTHORIZED`        | 403       | Tidak memiliki izin akses            |
| `NOT_FOUND`           | 404       | Resource tidak ditemukan             |
| `VALIDATION_ERROR`    | 422       | Validasi data gagal                  |
| `EMAIL_NOT_FOUND`     | 404       | Email tidak terdaftar                |
| `ALREADY_CLOCKED_IN`  | 409       | Sudah clock in hari ini              |
| `NOT_CLOCKED_IN`      | 409       | Belum clock in hari ini              |
| `INVALID_QR_CODE`     | 400       | QR Code tidak valid                  |
| `SERVER_ERROR`        | 500       | Terjadi kesalahan di server          |

### Common Validation Error Response

```json
{
  "success": false,
  "message": "Validasi gagal",
  "error_code": "VALIDATION_ERROR",
  "errors": {
    "email": ["Email sudah terdaftar"],
    "password": ["Password minimal 8 karakter"]
  }
}
```

---

## 📊 Endpoint Summary

| Category       | Count   | Endpoints                                                                     |
| -------------- | ------- | ----------------------------------------------------------------------------- |
| Authentication | 5       | login, forgot-password, reset-password, logout, refresh-token                 |
| Profile        | 3       | get profile, update profile, change password                                  |
| Attendance     | 5       | clock-in, clock-out, history, by-date, summary                                |
| Tables         | 5       | get all, get detail, update status, scan, layout                              |
| Orders         | 7       | get all, get detail, update status, filter by status, by table, ready, served |
| Notifications  | 5       | get all, unread, mark read, delete, register device                           |
| **TOTAL**      | **30+** | **Siap untuk implementasi**                                                   |

---

## 🔄 Implementation Guidelines

### For Backend Developer

1. **Setup Laravel Project**
   - Install Laravel 12 dengan PHP 8.2+
   - Setup database MySQL/MariaDB
   - Configure `.env` dengan database credentials

2. **Install Required Packages**

   ```bash
   composer require laravel/sanctum
   composer require laravel/socialite
   php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
   ```

3. **Create Models & Migrations**
   - `Staff` model dengan migration
   - `Attendance` model untuk clock in/out
   - `Table` model untuk meja
   - `Order` dan `OrderItem` models
   - `Notification` model
   - `StaffDevice` model untuk push notifications

4. **Implement Controllers**
   - `AuthController` untuk authentication
   - `ProfileController` untuk staff profile
   - `AttendanceController` untuk attendance
   - `TableController` untuk manajemen meja
   - `OrderController` untuk pesanan
   - `NotificationController` untuk notifikasi

5. **Setup Routes** (`routes/api.php`)

   ```php
   Route::post('/auth/login', [AuthController::class, 'login']);
   Route::post('/auth/forgot-password', [AuthController::class, 'forgotPassword']);
   // ... etc
   ```

6. **Implement Authentication Middleware**
   - Setup Laravel Sanctum untuk token-based auth
   - Validate token pada setiap request

### For Mobile Developer

1. **Create API Service**
   - Implement `ApiService` class dengan Dio HTTP client
   - Handle token management (save, refresh, clear)
   - Implement request/response interceptors

2. **Create Repository Pattern**
   - `AuthRepository` untuk authentication
   - `ProfileRepository` untuk profile
   - `AttendanceRepository` untuk attendance
   - dst...

3. **Implement Providers** (State Management)
   - Use Provider package
   - Create providers untuk setiap domain

4. **Handle Errors**
   - Implement global error handler
   - Display user-friendly error messages
   - Handle token expiration & refresh

---

<div align="center">
  <i>Dokumentasi API Endpoints - Seven Caffee Staff Mobile</i>
  <br>
  <strong>Siap untuk diimplementasikan di backend Laravel</strong>
</div>
