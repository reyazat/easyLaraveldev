# Laravel Docker Development Setup

Welcome to this **Laravel Docker Development Environment**! This setup allows you to seamlessly develop your Laravel applications using Docker, ensuring consistent environments across development, testing, and production. With this professional setup, you can manage dependencies efficiently, scale as needed, and enjoy seamless integration with **VS Code** for an optimized development experience.

## 🛠 Prerequisites

Before you begin, ensure that you have the following installed:

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/) (optional for cloning repositories)

### Optional VS Code Extensions:
- Docker Extension
- PHP Intelephense
- Prettier - Code Formatter

## 🚀 Project Structure

The project is organized into the following structure for better management and scalability:

```
my-project/
├── app/                  # Laravel source code
├── docker/               # Docker-related files
│   ├── nginx/
│   │   └── default.conf   # Nginx configuration
│   ├── php/
│   │   └── Dockerfile     # Dockerfile for PHP
│   ├── mysql/
│   │   └── my.cnf         # MySQL config (optional)
│   ├── redis/
│   │   └── redis.conf     # Redis config (optional)
├── .env                  # Laravel environment file
├── docker-compose.yml     # Docker Compose file
├── php.ini               # PHP configuration (optional)
├── Makefile              # Command automation file
└── README.md             # Project documentation
```

## 🐳 Docker Setup

### Docker Compose

We use **Docker Compose** to manage different services like Nginx, PHP, MySQL, and Redis. Here's a sample of the `docker-compose.yml` used for this project:

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: ./docker/php/Dockerfile
    container_name: laravel_app
    working_dir: /var/www
    volumes:
      - ./:/var/www
    environment:
      - APP_ENV=${APP_ENV}
      - APP_DEBUG=${APP_DEBUG}
    networks:
      - laravel_network
    depends_on:
      - db
      - redis

  webserver:
    image: nginx:alpine
    container_name: laravel_webserver
    volumes:
      - ./:/var/www
      - ./docker/nginx/default.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "${APP_PORT}:80"
    networks:
      - laravel_network
    depends_on:
      - app

  db:
    image: mysql:8.0
    container_name: laravel_mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_USER: ${DB_USERNAME}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - dbdata:/var/lib/mysql
    ports:
      - "${DB_PORT}:3306"
    networks:
      - laravel_network

  redis:
    image: redis:alpine
    container_name: laravel_redis
    volumes:
      - redisdata:/data
    networks:
      - laravel_network

volumes:
  dbdata:
    driver: local
  redisdata:
    driver: local

networks:
  laravel_network:
    driver: bridge
```

### Dockerfile for PHP

The Dockerfile for PHP handles the installation of necessary PHP extensions and sets up the environment for running the Laravel application:

```dockerfile
FROM php:8.1-fpm

# Install necessary extensions
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    zip unzip git curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . /var/www

RUN chown -R www-data:www-data /var/www

CMD ["php-fpm"]
```

### Nginx Configuration

The Nginx configuration file handles web requests and directs them to the PHP backend:

```nginx
server {
    listen 80;
    index index.php index.html;
    server_name localhost;
    root /var/www/public;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

## 📦 Environment Variables

Be sure to configure your `.env` file for Laravel and Docker:

```env
APP_NAME=Laravel
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=root

REDIS_HOST=redis
REDIS_PORT=6379
```

## 🔧 Makefile for Easy Commands

We've included a `Makefile` to simplify the common Docker commands:

```makefile
up:
	docker-compose up -d

down:
	docker-compose down

build:
	docker-compose build

logs:
	docker-compose logs -f

migrate:
	docker-compose exec app php artisan migrate

composer-install:
	docker-compose exec app composer install

artisan:
	docker-compose exec app php artisan
```

With these commands, you can easily start the application, monitor logs, and run migrations with simple `make` commands like:

```bash
make up          # Start Docker Compose
make down        # Stop Docker Compose
make logs        # View logs
make migrate     # Run Laravel migrations
```

## 🖥 Integrating with VS Code

You can use **Remote - Containers** in VS Code to seamlessly integrate with this Docker setup. Just add a `.devcontainer/devcontainer.json` file:

```json
{
  "name": "Laravel",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/var/www",
  "extensions": [
    "ms-azuretools.vscode-docker",
    "bmewburn.vscode-intelephense-client",
    "esbenp.prettier-vscode"
  ],
  "settings": {
    "php.validate.executablePath": "/usr/local/bin/php"
  }
}
```

## 🎯 Benefits of This Setup

- **Flexibility**: Each service runs in its own container, allowing easy modifications.
- **Scalability**: Add new services like Elasticsearch or Mailhog with ease.
- **Simplified Dependency Management**: No need for local installation of dependencies.
- **Environment Management**: Easily switch between development, testing, and production environments with separate configurations.
