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
  - **Usuarios**: `userId` (string), `email` (string), `username` (string), `role` (string: "participant" o "admin"), `createdAt` (timestamp), `status` (string: "pending", "active", "inactive"), `bajaRequested` (boolean).  
  - **Fotos**: `photoId` (string), `userId` (string), `url` (string), `status` (string: "pending", "approved", "rejected"), `uploadDate` (timestamp), `title` (string, opcional), `category` (string: ej. "Naturaleza"), `description` (string), `timeFrame` (string/timestamp), `theme` (string, opcional).  
  - **Votaciones**: `voteId` (string), `photoId` (string), `voterIdentifier` (string), `voteDate` (timestamp).  
- *Nota*: Fotos en Firebase Storage, URL en `Fotos`. Solo público vota, 1 voto por foto.

## 3. Desarrollo del proyecto
- Decisión inicial: Flutter + Firebase por compatibilidad y simplicidad.  
- Nombre: PhotoRally, por claridad y conexión con el rally fotográfico.  
- Modelo de datos: Tres colecciones (Usuarios, Fotos, Votaciones).  
- **Categorías de fotos**: Naturaleza, Urbano, Retratos, Abstracto, Cultura (en `category`).  
- **Categorías de ranking**: Bronce (>100 votos), Plata (>500 votos), Oro (>1000 votos).  
- **Notas**: Solo público vota. `Fotos` incluye `timeFrame` y `theme`. `Usuarios` con `status` y `bajaRequested` para alta/baja.
