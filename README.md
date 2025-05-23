# Nginx Configuration with Docker Compose

This repository contains an optimized Nginx configuration following best practices, implemented with Docker Compose. It includes services for log management (logrotate) and geolocation (GeoIP).

## Features

- **Nginx**: Highly configurable web server and reverse proxy.
- **GeoIP**: Visitor geolocation implementation.
- **Logrotate**: Automatic log rotation and management.
- **Configuration splits**: Separate files using includes for better organization.
- **Examples**:
  - Configuration for REST API
  - TCP/UDP Streaming
  - Load balancing
  - Security configurations

## Directory Structure

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

## Prerequisites

- Docker and Docker Compose installed
- MaxMind account for GeoIP (you can use the free GeoLite2 version)
- SSL certificates for your domains (for production)

## Installation and Usage

1. Clone this repository
2. Copy `.env.example` to `.env` and configure the variables:
   ```bash
   cp .env.example .env
   ```
3. Edit the `.env` file and add your MaxMind credentials
4. Create the necessary directories:
   ```bash
   mkdir -p nginx/conf/conf.d nginx/conf/api nginx/conf/streams nginx/html nginx/ssl logs/nginx data/geoip logrotate/conf
   ```
5. Copy the configuration files to the corresponding directories:
   - `nginx.conf` → `nginx/conf/`
   - `default.conf` → `nginx/conf/conf.d/`
   - `stream.conf` → `nginx/conf/streams.d/`
6. Generate the dhparam file for secure SSL:
   ```bash
   openssl dhparam -out ./nginx/ssl/dhparam.pem 2048
   ```
7. Place your SSL certificates in the `nginx/ssl/` directory
8. Start the services:
   ```bash
   docker compose up -d
   ```

## Log Monitoring

Logs are configured to include GeoIP information and are saved in JSON format for easier analysis. You can find them at:

- HTTP Access: `logs/nginx/access.log`
- JSON Access (analytics): `logs/nginx/analytics.log`
- Streams Access: `logs/nginx/stream_access.log`
- API Access: `logs/nginx/api_access.log`
- Errors: `logs/nginx/error.log`

## Customization

- Modify the configuration files as needed
- Adjust security policies and cache rules
- Configure upstreams for your backend servers
- Adjust log rotation parameters

## Security Notes

- Change SSL keys regularly
- Adjust GeoIP restrictions as needed
- Periodically review logs for attack patterns
- Consider implementing a Web Application Firewall (WAF) for increased security

## Best Practices Implemented

- Separation of configurations by functionality
- Optimized cache rules
- HTTP security headers
- Efficient log rotation
- Load balancing with health checks
- Secure TLS configuration
- Rate limiting to prevent abuse

## Basic Auth Configuration

To protect a location or site with HTTP Basic Authentication:

1. **Generate a password file** (if you don't have `htpasswd`, install it via `apache2-utils` or `httpd-tools`):
   ```bash
   htpasswd -c ./nginx/conf/.htpasswd yourusername
   ```
   You will be prompted to enter a password.

2. **Edit your site configuration** (e.g., `nginx/conf/conf.d/default.conf`) and add inside the desired `location` or `server` block:
   ```nginx
   location /protected/ {
       auth_basic "Restricted Area";
       auth_basic_user_file /etc/nginx/conf/.htpasswd;
       # ...other directives...
   }
   ```

3. **Mount the `.htpasswd` file** in your Docker Compose volume so it is available inside the container.

4. **Reload Nginx** to apply the changes:
   ```bash
   ./bin/reload.sh
   ```

Now, accessing `/protected/` will prompt for a username and password.
