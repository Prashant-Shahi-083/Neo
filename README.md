<div align="center">
  
  # 🎵 NEO Audio Experience
  
  **The Next Generation Music Streaming Architecture**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![NestJS](https://img.shields.io/badge/NestJS-10.x-E0234E?style=for-the-badge&logo=nestjs&logoColor=white)](https://nestjs.com)
  [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15.x-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://postgresql.org)
  
</div>

---

## 📖 Project Overview

NEO is a fully featured, state-of-the-art music streaming application that bridges high-performance mobile and desktop audio playback with a scalable, dynamic content-driven backend. It serves as a comprehensive ecosystem designed for both casual listeners and audiophiles.

## 🚀 Why NEO Was Built

The modern audio streaming landscape often forces a compromise between performance, architecture quality, and user experience. NEO was built from the ground up to solve these compromises by establishing a robust, modular, and deeply integrated full-stack architecture that natively supports continuous playback, scalable content delivery, and an immersive user interface.

## ✨ Key Features

- **High-Fidelity Playback Engine**: Continuous, gapless audio playback with full queue management.
- **Dynamic CMS-Driven Homepage**: Real-time personalized content delivery including heroic banners, horizontal carousels, and grid layouts.
- **Advanced Search & Discovery**: Intelligent search spanning across songs, artists, albums, and playlists.
- **Secure JWT Authentication**: Robust session persistence and user profile management.
- **Cross-Platform Excellence**: Seamlessly optimized for mobile, tablet, and desktop environments using a single Flutter codebase.

## 🏗️ Architecture Overview

NEO utilizes a strict separation of concerns, decoupling the presentation layer from business logic and data access, heavily relying on the Repository and Provider patterns in the frontend, and modular dependency injection in the backend.

### 📱 Flutter Frontend Overview
Built with Flutter, the client adheres to a strict architectural standard:
- **UI/Screens**: Pure presentation layer, zero direct API calls.
- **Providers**: State management (`ChangeNotifier`) orchestrating business logic.
- **Repositories**: Data access layer bridging the gap between APIs/local storage and providers.
- **Models**: Strongly typed Dart representations of backend DTOs.

### ⚙️ NestJS Backend Overview
The backend is a high-performance REST API powered by NestJS:
- **Controllers**: Routing and request validation.
- **Services**: Core business logic and database interactions.
- **Modules**: Highly cohesive domain boundaries (Auth, Player, Users, Homepage, Search).

### 🗄️ PostgreSQL Database Overview
Data is persisted in PostgreSQL using TypeORM. The schema is highly normalized, utilizing eager/lazy relations appropriately to ensure minimal query latency when hydrating complex entities like Playlists and Albums.

### 🔐 Authentication System
Stateless, token-based authentication using JWT. Features include:
- Access and Refresh token rotation.
- Secure token persistence using `flutter_secure_storage`.
- AuthGuards shielding protected NestJS endpoints.

### 🎧 Music Playback Engine
A fully fledged audio engine built over `just_audio`.
- Supports background audio playback.
- Handles buffering, seeking, and stream metadata.
- Prepares for lock-screen media controls.

### 📋 Queue Management
A robust queuing system enabling:
- Sequential playback.
- Shuffle and Repeat modes.
- Dynamic queue injection (Play Next, Add to Queue).

### 📝 CMS Architecture & Homepage
The homepage is 100% server-driven. The backend dictates the layout structure (Banners, Carousels, Grids) and the data payload. The Flutter client acts purely as a renderer via a `HomepageWidgetFactory`.

### 🌐 API Overview
The RESTful API provides unified access to all resources. Endpoints are versioned (`/api/v1/`) and structurally isolated (e.g., `/public-player`, `/public-search`, `/auth`, `/users`).

---

## 📁 Folder Structure

```
Neo/
├── backend/                  # NestJS API Server
│   ├── src/
│   │   ├── auth/             # JWT Authentication
│   │   ├── player/           # Playback metadata and streaming
│   │   ├── search/           # Global search service
│   │   ├── users/            # User profile management
│   │   └── homepage/         # CMS Delivery
│   └── test/                 # E2E & Unit Tests
│
├── lib/                      # Flutter Client
│   ├── api/                  # Env and Interceptors
│   ├── models/               # Domain Entities
│   ├── repositories/         # API Wrappers & Data access
│   ├── screens/              # UI Views
│   ├── services/             # State Management (Providers)
│   ├── theme/                # Design Tokens & Styles
│   └── widgets/              # Reusable UI Components
│
├── pubspec.yaml              # Flutter Dependencies
├── package.json              # Backend Dependencies
└── README.md                 # Project Documentation
```
> *Note: Certain private configurations or directories are explicitly excluded from tracking to maintain security.*

---

## 🛠️ Installation Guide

### Prerequisites
- Flutter SDK (3.x)
- Node.js (18.x or newer)
- PostgreSQL (15.x)
- Git

### Development Setup

**1. Clone the repository**
```bash
git clone https://github.com/Prashant-Shahi-083/Neo.git
cd Neo
```

**2. Setup Backend**
```bash
cd backend
npm install
npm run build
npm run start:dev
```

**3. Setup Frontend**
```bash
# From project root
flutter pub get
flutter run
```

### Environment Variables

Create a `.env` file in the `backend/` directory:

```env
# Placeholder Examples
DB_HOST=localhost
DB_PORT=5432
DB_USER=neo_user
DB_PASSWORD=secret
DB_NAME=neo_db
JWT_SECRET=super_secret_key
JWT_EXPIRES_IN=1h
```

---

## 🏗️ Build Instructions

**To build for Android:**
```bash
flutter build apk --release
```

**To build for iOS:**
```bash
flutter build ios --release
```

**To build backend for production:**
```bash
cd backend
npm run build
```

## 🚀 Deployment Overview
- **Backend**: Can be containerized via Docker and deployed to AWS ECS, Heroku, or Render.
- **Database**: Managed PostgreSQL instance (e.g., AWS RDS, Supabase).
- **Frontend**: Distributed via Google Play Store and Apple App Store.

---

## 📸 Screenshots

| Homepage | Player | Search | Profile |
| :---: | :---: | :---: | :---: |
| ![Homepage Placeholder](#) | ![Player Placeholder](#) | ![Search Placeholder](#) | ![Profile Placeholder](#) |

---

## 🗺️ Roadmap

- [ ] Implement Offline Downloads
- [ ] Add Lock Screen Media Controls & OS Notifications
- [ ] Personalized Recommendations Engine
- [ ] Premium Subscriptions & Payment Integration
- [ ] Social Sharing & Collaborative Playlists

## 🛡️ Security Considerations
- JWT Tokens are heavily secured and transmitted over HTTPS.
- Refresh tokens mitigate long-lived session hijacking.
- SQL Injection is prevented via TypeORM QueryBuilder parameterization.

## ⚡ Performance Optimizations
- **Backend**: DB indices on searchable fields (Artist, Track Title). Server-side pagination.
- **Frontend**: Heavy UI components are marked as `const`. ListView builders utilized for infinite scrolling. Debounced input for search queries.

## 💻 Tech Stack
- **Frontend**: Flutter, Dart, Provider, Dio, Just Audio
- **Backend**: NestJS, TypeScript, TypeORM, Passport, JWT
- **Database**: PostgreSQL

---

## 🤝 Contribution Guidelines
Contributions, issues, and feature requests are welcome! 
Please check the [issues page](https://github.com/Prashant-Shahi-083/Neo/issues).
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License
This project is open-source and free to use.

## 👏 Credits
- Developed by Prashant Pratap Shahi

## 📬 Contact
**Prashant Pratap Shahi**
- Email: mailprashantshahi@gmail.com
- GitHub: [@Prashant-Shahi-083](https://github.com/Prashant-Shahi-083)

<div align="center">
  <i>Built with ❤️ for audio lovers.</i>
</div>
