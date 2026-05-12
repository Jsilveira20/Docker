# Premier League Data Lakehouse

Stack de análisis de datos para la Premier League usando **Dremio** como query engine y **MinIO** como object storage.

## Requisitos
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado

## 1. Clonar el repo
```bash
git clone https://github.com/Jsilveira20/Docker.git
cd Docker
```

## 2. Levantar el stack
```bash
docker compose up -d
```

## 3. Subir el CSV a MinIO
1. Ir a **http://localhost:9001**
2. Usuario: `minioadmin` / Contraseña: `minioadmin`
3. Entrar al bucket `premier-league`
4. Subir el archivo `premier_league_complete_stats_until31thGameDayOnSeason2025-26.csv`

## 4. Configurar Dremio
1. Ir a **http://localhost:9047**
2. Crear usuario admin la primera vez
3. Agregar source **S3** con:
   - Access Key: `minioadmin`
   - Secret Key: `minioadmin`
   - Endpoint: `http://minio:9000`
   - Path style access: ✅
   - Bucket: `premier-league`
4. Nombrar el source `pldata`

## 5. Crear el modelo dimensional
Ejecutar en orden las queries de `queries/create_tables.sql` desde el editor SQL de Dremio.
