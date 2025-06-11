# PhotoRally - Proyecto Integrado

## Manual de Usuario

FotoRallyApp es una aplicación móvil multiplataforma diseñada para organizar y gestionar un rally fotográfico. Permite la inscripción de participantes, la validación y publicación de fotos por parte de administradores, la votación entre participantes, y la visualización de estadísticas.

---

### 👤 Tipos de Usuario

#### 1. Participante
- **Registro**: Se realiza mediante un formulario con los campos: nombre, correo, contraseña y localidad.
- **Estado inicial**: `"pendiente"` hasta que un administrador lo activa.
- **Estado `"activo"`**: Puede subir fotos, votar y gestionar su perfil.
- **Estado `"inactivo"`**: No puede participar ni votar, pero conserva su cuenta.
- **Solicitud de baja**: Puede solicitarla y el administrador decidirá si concederla.

#### 2. Administrador
- Se registra manualmente en la base de datos (no desde la app).
- Accede a funciones exclusivas:
  - Validación de fotos (aprobación o rechazo).
  - Alta y baja de participantes.
  - Configuración del rally (fechas, categorías, límites...).
  - Visualización de estadísticas (TOP 3 más votados).

---

### 🔐 Inicio de Sesión y Registro

- Desde la pantalla principal:
  - **"Iniciar sesión"**: Introducir email y contraseña.
  - **"Registrarse"**: Solo para participantes.
- También se muestra:
  - Tema del rally, fechas de inicio y fin, reglas y categorías disponibles.

---

### 📸 Funcionalidades por Rol

#### Participante (activo)

| Funcionalidad     | Descripción                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| Subir foto        | Completar: título, descripción, categoría, ubicación. Máximo: `photoLimit`. |
| Galería           | Visualizar fotos **aprobadas** y votar fotos de otros.                      |
| Mis fotos         | Ver todas las fotos subidas y su estado (pendiente, aprobada, rechazada).   |
| Votar             | Solo puede votar fotos de otros (sin auto-voto). Límite: `voteLimit`.       |
| Perfil            | Ver sus propios datos y estadísticas personales.                            |
| Solicitar baja    | Cambiar su estado a baja, pendiente de validación del administrador.         |

#### Administrador

| Funcionalidad             | Descripción                                                              |
|---------------------------|--------------------------------------------------------------------------|
| Validar fotos             | Aprobar o rechazar fotos enviadas por los participantes.                 |
| Gestionar participantes   | Activar, inactivar o dar de baja participantes registrados.              |
| Configurar el rally       | Modificar: fechas, límite de fotos, límite de votos, categorías, tema.   |
| Ver estadísticas          | Ver TOP 3 participantes con más votos en sus fotos aprobadas.            |

---

### 🔧 Reglas del Sistema

- **No se permite auto-voto**: Los participantes no pueden votar sus propias fotos (validado por lógica).
- **Máximo de fotos**: Cada participante puede subir hasta `photoLimit` fotos.
- **Máximo de votos**: Cada participante puede emitir hasta `voteLimit` votos, uno por cada foto.
- **Categorías válidas**: Las fotos deben pertenecer a una de las `allowedCategories` configuradas.
- **Solo las fotos con estado `"aprobada"` son visibles en la galería.**
- **Participantes inactivos o pendientes no pueden votar ni subir fotos.**

---

### 📊 Estadísticas

- Se muestran los **Top 3 participantes** con más votos acumulados en sus fotos.
- Se consultan en tiempo real desde Firestore y se ordenan por votos recibidos.

---

### 📱 Navegación y diseño

- **Barra de navegación inferior** adaptada al rol:
  - Participante: Galería, Mis Fotos, Perfil, Estadísticas.
  - Administrador: Validar Fotos, Usuarios, Configuración, Estadísticas.
- **Diseño responsive y minimalista**.
- **Colores**: Azul marino oscuro, verde oscuro, rojo y blanco.

---

### 🧑‍💼 Tabla resumen de permisos

| Funcionalidad                  | Participante `pendiente/inactivo` | Participante `activo` | Administrador |
|-------------------------------|:----------------------------------:|:----------------------:|:-------------:|
| Ver galería                   | ❌                                 | ✅                     | ✅            |
| Registrarse                   | ❌                                 | ❌                     | ❌            |
| Subir fotos                   | ❌                                 | ✅                     | ❌            |
| Votar fotos                   | ❌                                 | ✅                     | ❌            |
| Ver estadísticas              | ❌                                 | ✅                     | ✅            |
| Validar fotos                 | ❌                                 | ❌                     | ✅            |
| Gestionar participantes       | ❌                                 | ❌                     | ✅            |
| Editar configuración del rally| ❌                                 | ❌                     | ✅            |

---

### ✅ Requisitos técnicos

- **Flutter** 3.7.x
- **Firebase Firestore** y **Authentication**
- **Cloudinary** para almacenamiento de imágenes
- **AppCircle** para generar APK
- Compatible con **Android** (iOS no implementado)

---

## 🔧 Guía de Instalación y Ejecución

### 1. Requisitos

- Flutter 3.7.x
- Android Studio o dispositivo Android
- Cuenta en Firebase
- Cuenta en Cloudinary
- Git y Visual Studio Code

---

### 2. Clonar el proyecto

git clone https://github.com/apenmoh/FotoRallyApp.git
cd FotoRallyApp

### 3. Instalar dependencias
flutter pub get

### 4. Ejecutar el proyecto
flutter run


