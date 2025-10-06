# Prova Parcial - DevOps (Flask + PostgreSQL via Docker)

Arquivos criados nesta entrega:

- `Dockerfile` - imagem da aplicação Flask
- `docker-compose.yml` - orquestra `web` e `db` com volume nomeado
- `app/` - código da aplicação e `entrypoint.sh`
- `db/init-db.sql` - script de inicialização do banco (cria e popula `produtos`)

Como executar (Windows PowerShell):

1) Construir e iniciar os containers:

```powershell
docker-compose up --build
```

2) Verificar rota de saúde:

Abra http://localhost:5000/ no navegador ou:

```powershell
Invoke-RestMethod http://localhost:5000/
```

3) Listar produtos:

```powershell
Invoke-RestMethod http://localhost:5000/produtos
```

Observações:
- `db/init-db.sql` é copiado para o container postgres via volume e executado na primeira inicialização.
- Em Windows o bit de execução para `entrypoint.sh` pode precisar ser ajustado; o container usa shell e o arquivo funciona normalmente.
