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
