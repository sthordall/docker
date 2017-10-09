# pgAdmin 4, ver 2.0

> Originally from [Chorss](https://github.com/Chorss/docker-pgAdmin4) repository.

|          NAME          |      VARIABLE     | REQUIRED                       |
|------------------------|-------------------|--------------------------------|
| DEFAULT_SERVER_PORT    | 5050              | NO                             |
| SERVER_MODE            | True or False     | YES                            |
| PGADMIN_SETUP_EMAIL    | username@mail.tld | NO (IF SERVER_MODE SET FALSE)  |
| PGADMIN_SETUP_PASSWORD | password          | NO (IF SERVER_MODE SET FALSE)  |
| MAIL_SERVER            | mail.example.tld  | NO (IF SERVER_MODE SET FALSE)  |
| MAIL_PORT              | 465               | NO (IF SERVER_MODE SET FALSE)  |
| MAIL_USE_SSL           | True              | NO (IF SERVER_MODE SET FALSE)  |
| MAIL_USERNAME          | username          | NO (IF SERVER_MODE SET FALSE)  |
| MAIL_PASSWORD          | password          | NO (IF SERVER_MODE SET FALSE)  |

```bash
$ docker run -d -p 5050:5050 -e SERVER_MODE=True kuznero/pgadmin4
$ docker run -d -p 5050:5050 -e SERVER_MODE=True -v $(pwd)/data:/data kuznero/pgadmin4
```
