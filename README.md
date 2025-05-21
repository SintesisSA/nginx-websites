# Configuración de Nginx con Docker Compose

Este repositorio contiene una configuración de Nginx optimizada y siguiendo las mejores prácticas, implementada con Docker Compose. Incluye servicios para gestión de logs (logrotate) y geolocalización (GeoIP).

## Características

- **Nginx**: Servidor web y proxy inverso altamente configurable.
- **GeoIP**: Implementación para geolocalización de visitantes.
- **Logrotate**: Rotación y gestión automática de logs.
- **Divisiones de configuración**: Archivos separados mediante includes para una mejor organización.
- **Ejemplos**:
  - Configuración para API REST
  - Streaming TCP/UDP
  - Balanceo de carga
  - Configuraciones de seguridad

## Estructura de directorios

```
├── docker-compose.yml
├── nginx
│   ├── conf
│   │   ├── conf.d
│   │   │   └── default.conf
│   │   ├── includes
│   │   │   ├── block-exploits.conf
│   │   │   ├── buffers.conf
│   │   │   ├── exceptions.conf
│   │   │   ├── file-cache.conf
│   │   │   ├── gzip.conf
│   │   │   └── logging.conf
│   │   ├── nginx.conf
│   │   └── streams.d
│   │       └── readme.txt
│   ├── geoip
│   ├── html
│   │   ├── 400.html
│   │   ├── 403.html
│   │   ├── 404.html
│   │   ├── 500.html
│   │   ├── 502.html
│   │   ├── 503.html
│   │   └── 504.html
│   └── ssl
│       └── readme.txt
└── README.md
```

## Requisitos previos

- Docker y Docker Compose instalados
- Cuenta MaxMind para GeoIP (puede usar la versión gratuita GeoLite2)
- Certificados SSL para los dominios (para producción)

## Instalación y uso

1. Clonar este repositorio
2. Copiar `.env.example` a `.env` y configurar las variables:
   ```bash
   cp .env.example .env
   ```
3. Editar el archivo `.env` y agregar sus credenciales de MaxMind
4. Crear los directorios necesarios:
   ```bash
   mkdir -p nginx/conf/conf.d nginx/conf/api nginx/conf/streams nginx/html nginx/ssl logs/nginx data/geoip logrotate/conf
   ```
5. Copiar los archivos de configuración a los directorios correspondientes:
   - `nginx.conf` → `nginx/conf/`
   - `default.conf` → `nginx/conf/conf.d/`
   - `stream.conf` → `nginx/conf/streams.d/`
6. Generar el archivo dhparam para SSL seguro:
   ```bash
   openssl dhparam -out ./nginx/ssl/dhparam.pem 2048
   ```
7. Colocar los certificados SSL en el directorio `nginx/ssl/`
8. Iniciar los servicios:
   ```bash
   docker compose up -d
   ```

## Monitoreo de logs

Los logs están configurados para incluir información de GeoIP y se guardan en formato JSON para un análisis más sencillo. Puede encontrarlos en:

- Acceso HTTP: `logs/nginx/access.log`
- Acceso JSON (analytics): `logs/nginx/analytics.log`
- Acceso de Streams: `logs/nginx/stream_access.log`
- Acceso API: `logs/nginx/api_access.log`
- Errores: `logs/nginx/error.log`

## Personalización

- Modifique los archivos de configuración según sus necesidades
- Ajuste las políticas de seguridad y las reglas de caché
- Configure los upstreams para sus servidores back-end
- Ajuste los parámetros de rotación de logs

## Notas de seguridad

- Cambie regularmente las claves SSL
- Ajuste las restricciones de GeoIP según sus necesidades
- Revise periódicamente los logs para detectar patrones de ataque
- Considere implementar Web Application Firewall (WAF) para mayor seguridad

## Mejores prácticas implementadas

- Separación de configuraciones por funcionalidad
- Reglas de caché optimizadas
- Headers de seguridad HTTP
- Rotación de logs eficiente
- Balanceo de carga con comprobaciones de salud
- Configuración TLS segura
- Limitación de tasas para prevenir abusos
