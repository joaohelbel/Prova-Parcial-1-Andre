# 🧾 Relatório – Prova Parcial DevOps (Flask + PostgreSQL)

**Aluno:** João Pedro Helbel  
**Curso:** Sistemas de Informação – DevOps  
**Professor:** André Insardi  

---

## 1) Construção da imagem e boas práticas

### a) Imagem base e otimização de camadas
A imagem foi construída a partir da base python:3.11-slim, que oferece bom equilíbrio entre tamanho reduzido e compatibilidade com biblioteca nativa`psycopg2`.  
A ordem das instruções no `Dockerfile` foi planejada para **maximizar o cache** e reduzir o tempo de build:

1. Instalação de dependências do sistema (`gcc`, `libpq-dev`, `build-essential`), necessárias para compilar dependências Python.
2. Definição do `WORKDIR` para `/app`.
3. Cópia do `requirements.txt` e instalação das dependências.
4. Cópia do código da aplicação (`COPY app/ /app/`).
5. Criação do usuário não-root `appuser`, garantindo segurança na execução.
6. Exposição da porta **5000** e execução do script `entrypoint.sh`, que valida o banco antes de iniciar o Gunicorn.

Essas etapas seguem boas práticas de **segurança**, **reprodutibilidade** e **reuso de camadas**.

### b) Evidência de construção e execução


```bash
docker-compose up --build
```

A rota `/` respondeu com código **200 OK**, retornando:
```
Aplicação Flask no Docker – Prova de DevOps
```

Isso comprova o correto funcionamento e exposição na **porta 5000**.

---

## 2) Execução do container e integração com PostgreSQL (2,0 pts)

### a) Variáveis de ambiente e conexão
As variáveis configuradas no `docker-compose.yml`:

```yaml
DB_HOST: db
POSTGRES_DB: aula_prova
POSTGRES_USER: postgres
POSTGRES_PASSWORD: 123456
POSTGRES_PORT: 5432
```

Esses valores são lidos no `app.py` via `os.getenv()`, evitando segredos hardcoded.  
A conexão é realizada com `psycopg2.connect()`, garantindo comunicação interna com o container `db`.

### b) Publicação e mapeamento de portas
A aplicação Flask escuta na **porta 5000** e foi publicada externamente com:

```yaml
ports:
  - "5000:5000"
```

Assim, o acesso é feito por `http://localhost:5000`.

### c) Rota `/produtos`
O banco é inicializado com o script `db/init-db.sql`:

```sql
CREATE TABLE IF NOT EXISTS produtos (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(80),
  preco NUMERIC(10,2)
);

INSERT INTO produtos (nome, preco) VALUES
('Caneta', 3.50),
('Caderno', 12.90),
('Mochila', 89.90)
ON CONFLICT DO NOTHING;
```

A rota `/produtos` retorna:
```json
[
  {"id": 1, "nome": "Caneta", "preco": 3.5},
  {"id": 2, "nome": "Caderno", "preco": 12.9},
  {"id": 3, "nome": "Mochila", "preco": 89.9}
]
```

---

## 3) Arquitetura multi-container, persistência e readiness (3,0 pts)

### a) Diagrama da arquitetura

img

O Docker Compose cria uma **rede bridge** interna, permitindo comunicação entre os serviços via nome DNS (`db`).

### b) Estratégia de readiness
O script `entrypoint.sh` inclui uma rotina que testa a conexão com o banco via `psycopg2`.  
Somente após o PostgreSQL responder, o Gunicorn inicia o servidor Flask.  
Isso evita falhas por **inicialização prematura** do web service.

### c) Persistência
O volume nomeado `pgdata` armazena os dados do PostgreSQL fora do ciclo de vida dos containers:

```yaml
volumes:
  pgdata:
```

Após reiniciar o serviço `db`, os dados continuaram disponíveis, comprovando **persistência de dados**.

---

## 4) Camadas, artefatos e manutenção do ambiente (2,5 pts)

### a) Artefato portátil
A imagem pode ser exportada como artefato:

```bash
docker save web:latest -o prova_devops.tar
```

E importada em outro host com:

```bash
docker load -i prova_devops.tar
```

Essa prática garante **portabilidade e reuso** da imagem entre ambientes.

### b) Inventário e limpeza
Inventário final do ambiente:

| Tipo       | Nome/Descrição              |
|-------------|-----------------------------|
| Container   | `web`, `db`                 |
| Imagens     | `python:3.11-slim`, `postgres:14`, `web:latest` |
| Volume      | `pgdata` (dados persistentes) |

Procedimento de limpeza seguro:

```bash
docker-compose down
docker system prune -a
docker volume ls
```

A limpeza remove containers e imagens antigas, **preservando os volumes** e dados do banco.

---
**Data:** 06/10/2025  
**Assinatura:** *João Pedro Helbel*
