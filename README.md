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

- **Flutter** 3.16.x
- **Firebase Firestore** y **Authentication**
- **Cloudinary** para almacenamiento de imágenes
- **AppCircle** para generar APK
- Compatible con **Android** (iOS no implementado)

---




## 1. Tecnologías utilizadas
- **Framework**: Flutter (versión 3.x)  
  - *Justificación*: Multiplataforma, alto rendimiento, interfaces atractivas.  
- **Base de datos**: Firebase Firestore  
  - *Justificación*: Sincronización en tiempo real, integración con Flutter.  
- **Almacenamiento**: Cloudinary  
  - *Justificación*: Nivel gratuito generoso (25 GB), gestión eficiente de fotos.  
- **Control de versiones**: Git (GitHub)  
  - *Justificación*: Seguimiento incremental.  

## 2. Diagramas
- **Modelo de datos (Firestore)**:  
  - **Participantes**: `userId` (string), `email` (string), `username` (string), `createdAt` (timestamp), `status` (string: "pendiente", "activo", "inactivo"), `location` (string, opcional), `fotosCount` (int), `voteCount` (int).
  - **Administradores**: `id` (string), `email` (string), `password` (string, opcional si usas Firebase Auth), `createdAt` (timestamp).  
  - **Fotos**: `photoId` (string), `userId` (string), `url` (string), `status` (string: "pendiente", "aprobada", "rechazada"), `uploadDate` (timestamp), `title` (string), `category` (string: ej. "Naturaleza"), `description` (string),  `theme` (string), `location` (string).  
  - **Votaciones**: `voteId` (string), `photoId` (string), `voterId` (string, el `userId` del participante que vota), `voteDate` (timestamp).  
  - **Configuracion**: `startDate` (timestamp), `endDate` (timestamp), `photoLimit` (int, ej. 5), `voteLimit` (int, ej. 10), `isRallyActive` (bool), `allowedCategories` (string, ej. "Naturaleza,Urbano,Retratos"), `theme` (string, opcional), `timeFrame` (string, opcional).  
- *Nota*: Fotos almacenadas en Cloudinary, URL en `Fotos`. Votación solo para participantes activos.  

- **Arquitectura**:  
  - Frontend: Flutter (UI y lógica).  
  - Backend: Firebase Firestore (datos), Cloudinary (fotos), Firebase Authentication (login).  
  - Flujo: Flutter interactúa con Firestore para CRUD, Cloudinary para fotos, Auth para login.

## 3. Desarrollo del proyecto
- Decisión inicial: Flutter + Firebase por compatibilidad y simplicidad.  
- Nombre: PhotoRally, por claridad y conexión con el rally fotográfico.  
- Modelo de datos: Cuatro colecciones (Participantes, Administradores, Fotos, Votaciones, Configuracion).  
- **Categorías de fotos**: Definidas en `Configuracion.allowedCategories` (ej. Naturaleza, Urbano, Retratos, Abstracto, Cultura).  
- **Notas**:  
  - `Fotos` incluye `timeFrame`, `theme`, `location`.  
  - `Participantes` incluye `location`.  
  - Separación en `Participantes` y `Administradores`.  
  - `Configuracion` para plazos, límites y reglas del rally:
    - `photoLimit`: Máximo de fotos por participante.
    - `voteLimit`: Máximo de votos por participante.
    - `isRallyActive`: Indica si el rally está activo.
    - `allowedCategories`: Categorías permitidas para las fotos.
    - `theme` y `timeFrame`: Tema y marco temporal del rally, si aplica.
  - Votación restringida a participantes activos (1 voto por foto, máximo `voteLimit` votos por participante).  
  - Límite de fotos subidas por participante definido por `photoLimit`.

## 4. Estructura de pantallas
- **Inicio**: Info del rally (fechas, reglas desde `Configuracion`), botones "Iniciar Sesión", "Registrarse", "Ver Galería".  
- **Registro**: Formulario para participantes (email, username, contraseña, localidad; espera aprobación).  
- **Participante**: Botones "Ver/Subir Fotos" (máximo `photoLimit`), "Galería General" (con opción de votar máximo `voteLimit`), "Solicitud Baja", "Perfil".  
- **Admin**: Botones "Dar Alta/Baja", "Validar Fotos", "Galería General", "Configuración del Rally" (editar campos de `Configuracion`).  
- **Público**: Botones "Ver Galería" (solo visualización).  
- *Nota*: Galería muestra fotos en cartas (ScrollView). Votación exclusiva para participantes activos.


