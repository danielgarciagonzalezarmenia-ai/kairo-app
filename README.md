# Kairo — Eventos deportivos en vivo

App iOS para ver eventos deportivos en vivo, con diseño premium estilo Apple (HIG), construida en Flutter.

## Características

- Pantalla de carga con animación (máx. 2s)
- Home con carrusel destacado, chips de deportes y secciones "En vivo ahora", "Próximos eventos", "Destacados"
- Reproductor de pantalla completa con controles Cupertino, renovación automática de token (m3u8 firmado)
- Favoritos persistentes localmente
- Calendario y ajustes
- Notificaciones locales para recordatorios
- Soporte claro/oscuro, Dynamic Type, VoiceOver

## Flujo del stream (m3u8 firmado)

1. La app obtiene `channel_id` desde la API de dlive.sx
2. Pide un token con TTL a `https://edge.cowedd4855ws.sbs/api/playlist-token?slug=<channel>` (requiere `Origin` y `Referer` de `dembed.st`)
3. Construye la URL firmada: `https://edge.cowedd4855ws.sbs/<channel>/index.m3u8?t=<token>&_=<ts>`
4. Renueva el token cada ~55s o ante un 403

## Requisitos previos (build local)

- Flutter 3.41.9 en `C:\src\flutter\bin\flutter.bat`
- JAVA_HOME JDK 17 (`C:\Users\Daniel\Android\jdk-17\jdk-17.0.14+7`)
- No usar `java` del PATH (JDK 25 rompe Gradle)

## Verificación local

```powershell
& "C:\src\flutter\bin\flutter.bat" analyze
& "C:\src\flutter\bin\flutter.bat" test
& "C:\src\flutter\bin\flutter.bat" build apk --debug
```

## Compilación iOS (.ipa sin firmar)

La compilación iOS ocurre en GitHub Actions (`macos-latest`) usando `--no-codesign`. El artifact `.ipa` se sube como release.

## Instalación en iPhone (Apple ID gratuito)

1. Descargar [Sideloadly](https://sideloadly.io) e instalar **Apple Devices** o iTunes de apple.com (el de Microsoft Store no funciona).
2. Conectar el iPhone por USB, desbloquear y pulsar **Confiar**.
3. **Ajustes > Privacidad y seguridad > Modo desarrollador** → activar → reiniciar el iPhone.
4. Arrastrar el `.ipa` a Sideloadly, escribir tu **Apple ID gratuito** y pulsar **Start**; introducir el código 2FA.
5. **Ajustes > General > VPN y gestión de dispositivos > Desarrollador de la app > Confiar**.
6. Abrir la app y conceder permisos.

### Límites de la firma gratuita

- Caduca a los **7 días**. Renovar volviendo a pasar el `.ipa` por Sideloadly (conserva datos) o usar **SideStore**.
- Máximo **3 apps** por Apple ID.
- **TrollStore no sirve** en iOS 26/27.

## Estructura del proyecto

```
lib/
  main.dart              # Punto de entrada y tema Cupertino
  theme/app_theme.dart   # Colores y tipografía
  models/event.dart      # Modelos Event y Channel
  services/
    api_service.dart     # Llamadas a dlive.sx API
    token_service.dart   # Token edge y URL m3u8 firmada
    notification_service.dart  # Notificaciones locales
    preferences_service.dart   # Favoritos locales
  screens/
    root_screen.dart     # CupertinoTabBar con 5 pestañas
    splash_screen.dart   # Pantalla de carga animada
    home_screen.dart     # Home con carruseles y chips
    player_screen.dart   # Reproductor con renovación de token
    favorites_screen.dart# Favoritos, calendario, ajustes
  widgets/
    live_tag.dart        # Etiqueta EN VIVO con pulso
    sport_chip.dart      # Chip de deporte
    event_card.dart      # Tarjeta de evento
```

## Licencia

Uso personal. El contenido de los streams pertenece a sus respectivos propietarios.
