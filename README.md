# Premier League Data Lakehouse

Stack de análisis de datos para la Premier League usando **Dremio** como query engine y **MinIO** como object storage.

## Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y **corriendo** (esperá a que el ícono de la ballena esté quieto en la barra de tareas)
- Git instalado
- Abrir PowerShell **sin** "Ejecutar como administrador"

---

## 1. Clonar el repo

```powershell
cd C:\Users\<tu_usuario>
git clone https://github.com/Jsilveira20/Docker.git
cd Docker
```

> ⚠️ No ejecutes los comandos desde `C:\WINDOWS\system32`. Siempre trabajá desde tu carpeta de usuario.

---

## 2. Levantar el stack

```powershell
docker compose up -d
```

La primera vez descarga las imágenes de Dremio (~2-3 GB) y MinIO (~500 MB). Puede tardar 20-30 minutos dependiendo de la conexión. **No cambies de red mientras descarga.**

Si aparece alguno de estos errores:
```
The container name "/minio" is already in use
The container name "/dremio" is already in use
```
Eliminá el o los contenedores en conflicto con `-f` (force) y volvé a levantar:
```powershell
docker rm -f minio
docker rm -f dremio
docker compose up -d
```

> 💡 `-f` fuerza la eliminación aunque el contenedor esté corriendo, sin necesidad de detenerlo primero. Podés eliminar ambos en una sola línea: `docker rm -f minio dremio`

---

## 3. Configurar MinIO

1. Abrí **http://localhost:9001**
2. Usuario: `minioadmin` / Contraseña: `minioadmin`

### 3.1 Crear los buckets necesarios

Necesitás crear **dos buckets** antes de continuar:

| Bucket | Para qué sirve |
|--------|----------------|
| `premierleague` | Almacena el dataset fuente (`dataset_limpio.csv`) |
| `tables` | Almacena las tablas que creás desde Dremio |

Para crear cada uno: **Buckets → Create Bucket → ingresá el nombre → Create Bucket**

> ⚠️ El bucket `tables` es indispensable. Dremio guarda ahí las tablas que creás con SQL (`CREATE TABLE`). Sin este bucket, las escrituras van a fallar.

### 3.2 Subir el CSV

1. Entrá al bucket `premierleague`
2. Subí el archivo CSV (botón **Upload**)

---

## 4. Configurar Dremio

### 4.1 Crear usuario admin

1. Abrí **http://localhost:9047**
2. Creá tu usuario admin la primera vez

### 4.2 Agregar source S3 (MinIO)

1. En el panel izquierdo hacé clic en **"+"** al lado de "Sources"
2. Elegí **Amazon S3**
3. Completá la pestaña **General**:
   - Name: `pldata`
   - Authentication: `AWS Access Key`
   - AWS Access Key: `minioadmin`
   - AWS Access Secret: `minioadmin`
   - Encrypt connection: ❌ desactivado

4. Andá a **Advanced Options** y configurá:
   - Root Path: `/`
   - Allowlisted buckets: `premierleague`

5. En **Connection Properties** agregá estas 5 propiedades:

   | Name | Value |
   |------|-------|
   | `fs.s3a.endpoint` | `minio:9000` |
   | `fs.s3a.path.style.access` | `true` |
   | `fs.s3a.connection.ssl.enabled` | `false` |
   | `fs.s3a.aws.credentials.provider` | `org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider` |
   | `dremio.s3.compat` | `true` |

6. Hacé clic en **Save**

> ⚠️ Si da error de credenciales, verificá que `dremio.s3.compat` = `true` esté presente. Es la clave para que no intente conectarse a AWS real.

---

## 5. Formatear el CSV en Dremio

1. En el panel izquierdo andá a **http://localhost:9047/source/pldata**
2. Expandí `premierleague`
3. Hacé clic derecho sobre el archivo CSV
4. Seleccioná **"Text (delimited)"**
5. Configurá:
   - Field Delimiter: `,`
   - Line Delimiter: `\n`
   - Extract Field Names: ✅ activado
6. Guardá

---

## 6. Crear el modelo dimensional

En el editor SQL de Dremio ejecutá en orden las queries del archivo `queries/create_tables.sql`.

Para verificar que todo funciona:

```sql
SELECT * FROM pldata.premierleague."dataset_limpio.csv" LIMIT 5
```

---

## Solución de problemas comunes

| Error | Solución |
|-------|----------|
| `docker daemon is running` | Abrí Docker Desktop y esperá que inicie |
| `container name already in use` | `docker rm -f <nombre_contenedor>` y volvé a hacer `docker compose up -d` |
| `Could not connect to S3 source` | Verificá que tenés las 5 connection properties, especialmente `dremio.s3.compat = true` |
| `Object not found within pldata.premierleague` | Formatear el archivo como "Text (delimited)" desde http://localhost:9047/source/pldata |
| `CREATE TABLE` falla en Dremio | Verificar que el bucket `tables` existe en MinIO |
