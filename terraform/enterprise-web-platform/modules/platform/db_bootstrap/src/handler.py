import json
import os
import secrets
import time

import boto3
import pymysql
from pymysql.converters import escape_string


secrets_client = boto3.client("secretsmanager")


def read_secret(secret_arn):
    response = secrets_client.get_secret_value(SecretId=secret_arn)
    return json.loads(response["SecretString"])


def get_or_create_application_secret(secret_name, connection_details):
    try:
        secrets_client.describe_secret(SecretId=secret_name)
        existing = read_secret(secret_name)
        return existing
    except secrets_client.exceptions.ResourceNotFoundException:
        password = secrets.token_urlsafe(36)

        secret_value = {
            "engine": "mysql",
            "host": connection_details["host"],
            "port": int(connection_details["port"]),
            "dbname": connection_details["dbname"],
            "username": "wordpress_app",
            "password": password,
        }

        try:
            secrets_client.create_secret(
                Name=secret_name,
                Description="Least-privilege WordPress database credentials",
                SecretString=json.dumps(secret_value),
            )
        except secrets_client.exceptions.ResourceExistsException:
            # Another invocation may have created the secret concurrently.
            return read_secret(secret_name)

        return secret_value


def connect_to_database(master, endpoint, port, database):
    return pymysql.connect(
        host=endpoint,
        port=int(port),
        user=master["username"],
        password=master["password"],
        database=database,
        connect_timeout=10,
        read_timeout=20,
        write_timeout=20,
        autocommit=True,
        ssl={"check_hostname": True},
    )


def handler(event, context):
    master_secret_arn = os.environ["MASTER_SECRET_ARN"]
    app_secret_name = os.environ["APP_SECRET_NAME"]
    endpoint = os.environ["DB_ENDPOINT"]
    port = int(os.environ.get("DB_PORT", "3306"))
    database = os.environ["DB_NAME"]

    master = read_secret(master_secret_arn)

    connection_details = {
        "host": endpoint,
        "port": port,
        "dbname": database,
    }

    app_secret = get_or_create_application_secret(
        app_secret_name,
        connection_details,
    )

    if app_secret.get("username") != "wordpress_app":
        raise ValueError("The application secret has an unexpected username.")

    if app_secret.get("host") != endpoint:
        raise ValueError("The application secret endpoint does not match RDS.")

    connection = None
    last_error = None

    # RDS can be available before every connection path is immediately ready.
    for attempt in range(1, 7):
        try:
            connection = connect_to_database(
                master,
                endpoint,
                port,
                database,
            )
            break
        except Exception as exc:
            last_error = exc
            time.sleep(attempt * 5)

    if connection is None:
        raise RuntimeError(
            f"Unable to connect to the database after retries: {last_error}"
        )

    try:
        cursor = connection.cursor()

        # Password is escaped for the SQL statement and is never logged.
        escaped_password = "'" + escape_string(app_secret["password"]) + "'"

        cursor.execute(
            "CREATE USER IF NOT EXISTS 'wordpress_app'@'%' "
            f"IDENTIFIED BY {escaped_password}"
        )
        cursor.execute(
            "ALTER USER 'wordpress_app'@'%' "
            f"IDENTIFIED BY {escaped_password}"
        )
        cursor.execute(
            f"GRANT ALL PRIVILEGES ON `{database}`.* "
            "TO 'wordpress_app'@'%'"
        )

        cursor.close()
    finally:
        connection.close()

    # Return metadata only. Never return the password.
    return {
        "status": "ready",
        "secret_name": app_secret_name,
        "username": "wordpress_app",
        "database": database,
    }
