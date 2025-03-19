# 🚛 App Driver

**App Driver** es una aplicación móvil desarrollada con **Flutter** para la gestión de viajes y productos en un entorno de transporte logístico. Ofrece funcionalidades para conductores y administradores, como navegación en ruta, control de entregas y monitoreo de condiciones de transporte.  

---

## 📌 Tecnologías Utilizadas

- **🟡 Flutter:** 3.29.2  
- **🔷 Dart:** 3.7.2  
- **🔥 Firebase** (Opcional, si se integra para autenticación o almacenamiento)  
- **🐘 PostgreSQL** (Si se usa para la persistencia de datos en el backend)  
- **🔗 GraphQL** (Para consultas de datos eficientes)  
- **📡 MQTT** (Para comunicación en tiempo real con sensores IoT)  

---

## ✨ Características

✔️ Navegación optimizada para conductores.  
✔️ Monitoreo de condiciones de transporte (**temperatura, humedad, ubicación GPS, etc.**).  
✔️ Sistema de autenticación seguro.  
✔️ Soporte para conectividad en **tiempo real**.  

---

## 🛠 Instalación  

### 📌 Prerrequisitos  
Asegúrate de tener instalado:  
- [📥 Flutter SDK 3.29.2](https://flutter.dev/docs/get-started/install)  
- [🐦 Dart SDK 3.7.2](https://dart.dev/get-dart)  
- [💻 Android Studio o Visual Studio Code](https://flutter.dev/docs/get-started/editor)  

### 🚀 Pasos de Instalación  

1️⃣ **Clonar el Repositorio**  
Abre la terminal (o la línea de comandos en Windows) y ejecuta lo siguiente para clonar el repositorio del proyecto:

```sh
git clone https://github.com/kevinquintanah12/app-driver.git
cd app-driver
```

2️⃣ **Instalar Flutter y Dart**

#### En **Linux**:

1. **Instalar Flutter SDK**:

```sh
sudo apt update
sudo apt install curl git unzip xz-utils zip
curl -LO https://storage.googleapis.com/download.flutter.io/flutter_linux_3.29.2-stable.tar.xz
tar xf flutter_linux_3.29.2-stable.tar.xz
sudo mv flutter /opt/
export PATH="$PATH:/opt/flutter/bin"
```

2. **Verificar la instalación**:

```sh
flutter doctor
```

#### En **Windows**:

1. **Descargar Flutter SDK** desde [aquí](https://flutter.dev/docs/get-started/install/windows).
2. Extraer el archivo `.zip` en una ubicación como `C:\src\flutter`.
3. Agregar la ruta `C:\src\flutter\bin` al PATH del sistema.

4. **Verificar la instalación**:

```sh
flutter doctor
```

3️⃣ **Instalar Dependencias para Android Studio o VS Code**

#### En **Linux**:

1. **Android Studio**: Sigue la [guía de instalación](https://developer.android.com/studio#linux) para tu distribución de Linux.
2. **VS Code**: Instala desde la [página oficial](https://code.visualstudio.com/Download).

#### En **Windows**:

1. **Android Studio**: Descarga desde [aquí](https://developer.android.com/studio).
2. **VS Code**: Descarga desde [aquí](https://code.visualstudio.com/Download).

6️⃣ **Configurar Firebase **

Si estás utilizando Firebase para la autenticación o el almacenamiento en la aplicación, sigue estos pasos:

1. **Configura un proyecto de Firebase** desde la [consola de Firebase](https://console.firebase.google.com/).
2. **Agrega Firebase al proyecto Flutter**:
   - Agrega las dependencias en `pubspec.yaml`:

   ```yaml
   dependencies:
     firebase_core: ^1.10.0
     firebase_auth: ^3.3.4
   ```

3. **Configura Firebase en Android** siguiendo [la guía de Firebase para Flutter](https://firebase.flutter.dev/docs/overview).

---

## 🛠 **Ejecución del Proyecto**

### 1️⃣ **Ejecutar la aplicación Flutter**

1. Abre el proyecto en tu editor (Android Studio o Visual Studio Code).
2. Instalar Dependencias
Ejecuta el siguiente comando para obtener todas las dependencias necesarias para el proyecto:

sh
Copiar
Editar
flutter pub get
3️⃣ Verificar Configuración de Flutter
Antes de ejecutar la aplicación, asegúrate de que Flutter esté configurado correctamente. Ejecuta:

sh
Copiar
Editar
flutter doctor
4. Ejecuta la aplicación con el siguiente comando:

```sh
flutter run
```


---

