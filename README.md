# PhotoRally - Proyecto Integrado

## 1. Tecnologías utilizadas
- **Framework**: Flutter (versión 3.x)
  - *Justificación*: Framework multiplataforma con alto rendimiento y soporte para interfaces atractivas.
- **Base de datos**: Firebase Firestore
  - *Justificación*: Sincronización en tiempo real y fácil integración con Flutter.
- **Almacenamiento**: Firebase Storage
  - *Justificación*: Gestión eficiente de fotos.
- **Autentificacion**: Firebase Autentification.
  - *Justificacion*: Muy facil de validar el email y password de los usurarios
- **Control de versiones**: Git (GitHub)
  - *Justificación*: Seguimiento del desarrollo incremental.

## 2. Diagramas
- **Modelo de datos (Firestore)**:  
  - **Usuarios**: `userId` (string), `email` (string), `username` (string), `role` (string: "participant" o "admin"), `createdAt` (timestamp).  
  - **Fotos**: `photoId` (string), `userId` (string), `url` (string), `status` (string: "pending", "approved", "rejected"), `uploadDate` (timestamp), `title` (string, opcional), `category` (string: ej. "Naturaleza").  
  - **Votaciones**: `voteId` (string), `photoId` (string), `userId` (string), `voteDate` (timestamp).  
- *Nota*: Las fotos se almacenan en Firebase Storage, y su URL se guarda en `Fotos`.  
- Pendiente: Diagrama de arquitectura.

## 3. Desarrollo del proyecto
- Decisión inicial: Flutter + Firebase por compatibilidad y simplicidad.  
- Nombre: PhotoRally, elegido por claridad y conexión con el rally fotográfico.  
- Modelo de datos: Tres colecciones (Usuarios, Fotos, Votaciones) para gestión, subida y votación.  
- **Categorías de fotos**: Naturaleza, Urbano, Retratos, Abstracto, Cultura. Añadidas para clasificar las fotos subidas (campo `category` en `Fotos`).  
- **Categorías de ranking**: Bronce (>100 votos), Plata (>500 votos), Oro (>1000 votos). Basadas en la cantidad de votos por foto, mostradas en la interfaz.
