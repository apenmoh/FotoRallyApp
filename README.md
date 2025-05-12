# PhotoRally - Proyecto Integrado

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
  - **Configuracion**: `startDate` (timestamp), `endDate` (timestamp), `photoLimit` (int, ej. 5), `voteLimit` (int, ej. 10), `isRallyActive` (bool), `allowPhotoUploads` (bool), `allowVoting` (bool), `allowedCategories` (string, ej. "Naturaleza,Urbano,Retratos"), `theme` (string, opcional), `timeFrame` (string, opcional).  
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
    - `allowPhotoUploads`: Indica si los participantes pueden subir fotos.
    - `allowVoting`: Indica si los participantes pueden votar.
    - `allowedCategories`: Categorías permitidas para las fotos.
    - `theme` y `timeFrame`: Tema y marco temporal del rally, si aplica.
  - Votación restringida a participantes activos (1 voto por foto, máximo `voteLimit` votos por participante).  
  - Límite de fotos subidas por participante definido por `photoLimit`.

## 4. Estructura de pantallas
- **Inicio**: Info del rally (fechas, reglas desde `Configuracion`), botones "Iniciar Sesión", "Registrarse", "Ver Galería".  
- **Registro**: Formulario para participantes (email, username, contraseña, localidad; espera aprobación).  
- **Participante**: Botones "Ver/Subir Fotos" (máximo `photoLimit`, según `allowPhotoUploads`), "Galería General" (con opción de votar si `allowVoting` es true, máximo `voteLimit`), "Solicitud Baja", "Perfil".  
- **Admin**: Botones "Dar Alta/Baja", "Validar Fotos", "Galería General", "Configuración del Rally" (editar campos de `Configuracion`).  
- **Público**: Botones "Ver Galería" (solo visualización).  
- *Nota*: Galería muestra fotos en cartas (ScrollView). Votación exclusiva para participantes activos.

## 5. Reglas de negocio
- **Participantes**:
  - Solo los participantes con `status: "activo"` pueden subir fotos (máximo `photoLimit`, si `allowPhotoUploads` es true) y votar (máximo `voteLimit`, 1 voto por foto, si `allowVoting` es true).
  - Participantes con `status: "pendiente"` o `"inactivo"` solo pueden ver la galería (sin votar ni subir).
- **Administradores**:
  - Pueden dar de alta/baja a participantes, validar/rechazar fotos, y configurar el rally (editar `Configuracion`).
- **Público**:
  - Solo puede ver las fotos aprobadas (sin votar ni interactuar).
- **Fotos**:
  - Las fotos subidas por participantes tienen `status: "pendiente"` hasta que el administrador las apruebe (`aprobada`) o rechace (`rechazada`).
  - Solo las fotos `aprobada` son visibles en la galería pública.
  - Las fotos deben cumplir con `category` en `allowedCategories`, y opcionalmente con `theme` y `timeFrame`.

## 6. Reglas de seguridad (Firestore)
- Solo usuarios autenticados con rol de participante y `status: "activo"` pueden escribir en `Fotos` y `Votaciones`.
- Solo administradores pueden modificar `Participantes` (para alta/baja) y `Fotos` (para validar).
- Cualquier usuario (autenticado o no) puede leer `Fotos` con `status: "aprobada"`.
- Solo administradores pueden modificar `Configuracion`.
- Lectura de `Configuracion` permitida para todos (para mostrar reglas en la pantalla de inicio).

## 7. Futuras mejoras (fuera del MVP)
- Votación para el público.
- Estadísticas y rankings (Bronce, Plata, Oro).
- Notificaciones push para aprobación de fotos o alta de participantes.
- Filtros en la galería (por categoría, tema, etc.).
- Galería privada para participantes (ver solo sus fotos).
