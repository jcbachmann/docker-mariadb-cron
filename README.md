# MariaDB with Cron and Tini

This Docker image extends the official MariaDB image by adding `cron` and `tini`. It also includes a custom entrypoint script to facilitate the use of cron jobs via an environment variable.

## Purpose

This image is useful for taking backups of MariaDB databases at regular intervals using cron jobs. It can be used in development, testing, or production environments where automated backups are required.

## Table of Contents

- [Features](#features)
- [Usage](#usage)
  - [Building the Image](#building-the-image)
  - [Running the Container](#running-the-container)
  - [Using Cron](#using-cron)
- [Example with Docker Compose](#example-with-docker-compose)
  - [Accessing the Database](#accessing-the-database)
  - [Accessing the Backups](#accessing-the-backups)
- [Disclaimer](#disclaimer)
- [License](#license)

## Features

- Based on the latest MariaDB official image.
- Includes cron for scheduling tasks.
- Uses tini as the init system for proper process management.
- Custom entrypoint script to manage cron jobs via an environment variable.

## Usage

### Building the Image

To build the Docker image, run the following command in the directory containing the `Dockerfile` and `entrypoint.sh`:

```sh
docker build -t mariadb-cron-tini .
```

### Running the Container

To run the container with default settings:

```sh
docker run -d --name my_mariadb -e MARIADB_ROOT_PASSWORD=rootpassword mariadb-cron-tini
```

### Using Cron

You can set up cron jobs by passing the `CRONTAB` environment variable. For example:

```sh
docker run -d --name my_mariadb \
 -e MARIADB_ROOT_PASSWORD=rootpassword \
 -e CRONTAB="\* \* \* \* \* /usr/bin/mariadb-dump --host=my_mariadb --user=root --password=rootpassword --all-databases > /backups/my_mariadb-all_databases.sql" \
 mariadb-cron-tini
```

In this example, the cron job will run every minute and dump all databases of `my_mariadb` to `/backups/my_mariadb-all_databases.sql`.

## Example with Docker Compose

Usually, you would want to backup the databases from an existing MariaDB container.

Here is an example of using this image with Docker Compose to create a MariaDB database and a MariaDB database with cron and tini to take backups of the database every minute.

```yaml
version: '3.1'

services:
  db:
    image: mariadb:latest
    restart: always
    environment:
      MARIADB_DATABASE: ${MARIADB_DATABASE}
      MARIADB_USER: ${MARIADB_USER}
      MARIADB_PASSWORD: ${MARIADB_PASSWORD}
      MARIADB_RANDOM_ROOT_PASSWORD: '1'
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - default
      - adminer_default
    healthcheck:
      test:
        [
          'CMD-SHELL',
          'mysqladmin ping -h localhost -u${MARIADB_USER} -p${MARIADB_PASSWORD}',
        ]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s

  db_backup:
    build:
      context: .
      dockerfile: Dockerfile
    restart: always
    depends_on:
      - db
    volumes:
      - /backups:/backups:rw
    environment:
      CRONTAB: |
        * * * * * bash -c "mariadb-dump --host=db --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} | gzip -9 > /backups/db-all_databases.sql.gz"
    networks:
      - default

volumes:
  db_data:

networks:
  default:
    driver: bridge
  adminer_default:
    external: true
```

This example assumes that you have a `.env` file in the same directory as the `docker-compose.yml` file with the following content:

```sh
MARIADB_DATABASE=mydatabase
MARIADB_USER=myuser
MARIADB_PASSWORD=mypassword
```

The example also assumes that you have the `Dockerfile` and `entrypoint.sh` files in the same directory as the `docker-compose.yml` file.

This Docker stack, when started with `docker-compose up -d`, will create two services: `db` and `db_backup`. The `db` service is a MariaDB database, and the `db_backup` service is a MariaDB database with cron and tini. The `db_backup` service will dump all databases of the `db` service every minute to `/backups/db-all_databases.sql.gz`.

### Accessing the Database

The database is included in the `adminer_default` network, so you can access it using [Adminer](https://www.adminer.org/). After installing Adminer on Docker, make sure the Adminer's default network has the correct name. To access the database, navigate to `http://localhost:8080` in your browser and use the following credentials:

- System: MySQL
- Server: db
- Username: myuser
- Password: mypassword
- Database: mydatabase

Adjust the values based on the `.env` file and your container names, and you should be able to access the database with the provided credentials.

### Accessing the Backups

The backups are stored in the `/backups` directory on the host machine. You can access them by navigating to the `/backups` directory on your host machine.

You will need to unzip the `.gz` files to access the SQL files. You can do this by running the following command:

```sh
gunzip -d /backups/db-all_databases.sql.gz
```

Then, use tools like `cat` or `less` to view the contents of the SQL file.

## Disclaimer

This document should provide a good starting point for users to understand and utilize this Docker image. Adjust the examples and descriptions as needed to fit your specific use case and environment.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
