# App Driver

## Descripción
App Driver es una aplicación móvil desarrollada con Flutter que permite la gestión de viajes y productos en un entorno de transporte logístico. Proporciona funcionalidades para conductores y administradores, incluyendo navegación en ruta, control de entregas y monitoreo de condiciones de transporte.

## Tecnologías Utilizadas
- **Flutter:** 3.29.2
- **Dart:** 3.7.2
- **Firebase** (opcional, si se integra para autenticación o almacenamiento)
- **PostgreSQL** (si se usa para la persistencia de datos en el backend)
- **GraphQL** (para consultas de datos eficientes)
- **MQTT** (para comunicación en tiempo real con sensores IoT, si aplica)

## Características
- Navegación optimizada para conductores.
- Monitoreo de condiciones de transporte (temperatura, humedad, ubicación GPS, etc.).
- Sistema de autenticación seguro.
- Soporte para conectividad en tiempo real.

## Instalación
### Prerrequisitos
Asegúrate de tener instalado:
- [Flutter SDK 3.29.2](https://flutter.dev/docs/get-started/install)
- [Dart SDK 3.7.2](https://dart.dev/get-dart)
- [Android Studio o Visual Studio Code](https://flutter.dev/docs/get-started/editor)

### Pasos de Instalación
1. Clonar el repositorio:
   ```sh
   git clone https://github.com/kevinquintanah12/app-driver.git
   cd app-driver
   ```
2. Instalar dependencias:
   ```sh
   flutter pub get
   ```
3. Ejecutar la aplicación:
   ```sh
   flutter run
   ```

## Dependencias Principales
Este proyecto utiliza las siguientes librerías:
- **animations** (2.0.11) - Efectos de transiciones animadas.
- **cached_network_image** (3.3.1) - Carga de imágenes con caché.
- **connectivity_plus** (5.0.2) - Manejo de conectividad a internet.
- **flutter_map** (3.1.0) - Mapas interactivos para la aplicación.
- **flutter_rating_bar** (4.0.1) - Barra de valoraciones.
- **flutter_svg** (2.0.9) - Soporte para imágenes SVG.
- **fluttertoast** (8.2.8) - Notificaciones tipo toast.

