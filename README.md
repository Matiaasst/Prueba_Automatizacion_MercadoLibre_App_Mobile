# 📱 Prueba de Automatización Mobile - Mercado Libre

Este proyecto realiza una **prueba automatizada en la app de Mercado Libre (Android)** utilizando **Ruby, Cucumber y Appium 3**.  
El objetivo es abrir la aplicación, realizar una búsqueda, aplicar filtros y obtener los nombres y precios de los primeros 5 productos.

---

## 🧩 Requisitos previos

Para ejecutar el proyecto, **no es necesario modificar el código**, solo tener las herramientas siguientes instaladas correctamente.

### 💻 En la computadora (Windows 10 o superior recomendado)

| Herramienta | Versión recomendada | Propósito |
|--------------|--------------------|------------|
| [**Java JDK**](https://www.oracle.com/java/technologies/downloads/) | 11 o 17 | Requerido por Android y Appium |
| [**Android SDK (Platform Tools)**](https://developer.android.com/studio#downloads) | Última | Permite conectar y ejecutar dispositivos Android |
| [**Node.js**](https://nodejs.org/) | 18 o 20 | Para instalar y ejecutar Appium |
| [**Appium 3**](https://appium.io/) | 3.x | Servidor para ejecutar pruebas móviles |
| [**Ruby**](https://rubyinstaller.org/) | 3.x | Lenguaje base del proyecto |
| **Bundler** | Última | Maneja las gemas Ruby |
| **Visual Studio Code** *(opcional)* | - | Para visualizar el código o los reportes |

---

## ⚙️ Instalación de dependencias

1️⃣ **Instalar Appium 3 y el driver Android:**
```bash
npm install -g appium
appium driver install uiautomator2
```

2️⃣ **Instalar Bundler (si no lo tienes):**
```bash
gem install bundler
```

3️⃣ **Clonar o descomprimir el proyecto:**
```bash
git clone https://github.com/TU_USUARIO/PruebaAutomatizacionMobile.git
cd PruebaAutomatizacionMobile
```

4️⃣ **Instalar las gemas Ruby:**
```bash
bundle install
```

---

## 📱 Configuración del dispositivo Android

1. Activar las **Opciones de desarrollador** en el teléfono.  
2. Habilitar **Depuración USB**.  
3. Conectar el dispositivo mediante cable USB.  
4. Verificar la conexión:
   ```bash
   adb devices
   ```
   Debe aparecer el ID de tu dispositivo en la lista.

> ⚠️ Asegúrate de tener la app **Mercado Libre** instalada en el teléfono (no es necesario iniciar sesión).

---

## 🚀 Ejecución del proyecto

1️⃣ **Abrir el servidor Appium en una terminal:**
```bash
appium
```
*(Mantén esta ventana abierta mientras se ejecutan las pruebas)*

2️⃣ **Ejecutar el test en otra terminal:**
```bash
cucumber
```
Esto:
- Inicia la app de Mercado Libre.  
- Realiza una búsqueda (por ejemplo “PlayStation”).  
- Aplica filtros (Nuevo, CDMX, Menor precio).  
- Imprime en consola los **5 primeros resultados con nombre y precio**.

---

## 🧾 Reportes de ejecución

- Los reportes HTML y JSON se guardan automáticamente en:
  ```
  /target/cucumber.html
  /target/cucumber.json
  ```

### (Opcional) Reporte Allure
Si tienes Allure instalado:
```bash
cucumber -p allure
allure serve target/allure-reports
```

---

## ✅ Verificación rápida

Si todo está correcto:
- Appium muestra logs en la consola (conexión exitosa).
- El dispositivo abre la app Mercado Libre.
- En la consola de Cucumber se ven los pasos ejecutándose y los productos listados.

---

## 🧠 Estructura principal del proyecto

```
PruebaAutomatizacionMobile/
│
├── features/
│   ├── ML.feature             # Escenario de prueba
│   ├── step_definitions/      # Definición de pasos
│   ├── pages/                 # Clases de páginas y selectores
│   └── support/               # Configuración de entorno (env.rb)
│
├── cucumber.yml               # Perfiles de ejecución
├── Gemfile / Gemfile.lock     # Dependencias Ruby
└── README.md                  # Este archivo
```

---

## 👩‍💻 Ejecutar en 3 pasos (resumen corto)

```bash
bundle install
appium
cucumber
```

---

## 🧰 Solución de problemas comunes

| Problema | Solución |
|-----------|-----------|
| ❌ Appium no se conecta | Verifica que el puerto 4723 no esté ocupado |
| ❌ No aparece el dispositivo | Revisa la depuración USB o ejecuta `adb devices` |
| ❌ Error de gemas | Ejecuta `bundle install` nuevamente |
| ❌ No abre la app | Asegúrate de tener la app de Mercado Libre instalada |

---

## 📚 Créditos

Proyecto desarrollado por **Camila Velázquez Gómez**  
Automatización móvil con **Ruby + Cucumber + Appium 3**
