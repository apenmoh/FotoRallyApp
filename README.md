# PhotoRally - Proyecto Integrado

## 1. Tecnologías utilizadas
- **Framework**: Flutter (versión 3.x)  
  - *Justificación*: Multiplataforma, alto rendimiento, interfaces atractivas.  
- **Base de datos**: Firebase Firestore  
  - *Justificación*: Sincronización en tiempo real, integración con Flutter.  
- **Almacenamiento**: Firebase Storage  
  - *Justificación*: Gestión eficiente de fotos.  
- **Control de versiones**: Git (GitHub)  
  - *Justificación*: Seguimiento incremental.  

## 2. Diagramas
- **Modelo de datos (Firestore)**:  
  - **Participantes**: `userId` (string), `email` (string), `username` (string), `createdAt` (timestamp), `status` (string: "pending", "active", "inactive").  
  - **Administradores**: `userId` (string), `email` (string), `username` (string), `createdAt` (timestamp).  
  - **Fotos**: `photoId` (string), `userId` (string), `url` (string), `status` (string: "pending", "approved", "rejected"), `uploadDate` (timestamp), `title` (string, opcional), `category` (string: ej. "Naturaleza"), `description` (string), `timeFrame` (string/timestamp), `theme` (string, opcional), `location` (string).  
  - **Votaciones**: `voteId` (string), `photoId` (string), `voterIdentifier` (string), `voteDate` (timestamp).  
  - **Configuracion**: `startDate` (timestamp), `endDate` (timestamp), `voteLimit` (int), `rules` (string/array).  
- *Nota*: Fotos en Firebase Storage, URL en `Fotos`. Solo público vota, 1 voto por foto, `voteLimit` es total de votos por usuario.

## 3. Desarrollo del proyecto
- Decisión inicial: Flutter + Firebase por compatibilidad y simplicidad.  
- Nombre: PhotoRally, por claridad y conexión con el rally fotográfico.  
- Modelo de datos: Cinco colecciones (Participantes, Administradores, Fotos, Votaciones, Configuracion).  
- **Categorías de fotos**: Naturaleza, Urbano, Retratos, Abstracto, Cultura (en `category`).  
- **Categorías de ranking**: Bronce (>100 votos), Plata (>500 votos), Oro (>1000 votos).  
- **Notas**: Solo público vota. `Fotos` incluye `timeFrame`, `theme`, `location`. Separación en `Participantes` y `Administradores`. `Configuracion` para plazos, límites y reglas. `voteLimit` es el total de votos por usuario público.

## 4. Estructura de pantallas
- **Inicio**: Info del rally, botones "Iniciar Sesión", "Registrarse", "Ver Galería".  
- **Registro**: Formulario para participantes (espera aprobación).  
- **Participante**: Botones "Ver/Subir Fotos", "Galería General", "Solicitud Baja", "Perfil".  
- **Admin**: Botones "Dar Alta/Baja", "Validar Fotos", "Galería General", "Estadísticas", "Configuración del Rally".  
- **Público**: Botones "Ver Galería", "Ver Estadísticas".  
- *Nota*: Galería muestra fotos en cartas (ScrollView), público vota (1 voto por foto). Incluye "Ver Participantes" con enlace a perfiles (lista de `username` y fotos aprobadas).
