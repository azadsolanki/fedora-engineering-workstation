# Databases

**Status:** ✅ PostgreSQL Installed and Configured

Database systems for development and data engineering work.

---

## Installed Tools

### PostgreSQL
- ✅ **Version:** 16.x (Fedora 43 default)
- ✅ **Status:** Installed and configured
- ✅ **GUI:** pgAdmin 4
- ✅ **Port:** 5432
- ✅ **Authentication:** Password (md5) enabled

---

## PostgreSQL Installation

### 1. Install PostgreSQL

```bash
# Install PostgreSQL server and client
sudo dnf install postgresql-server postgresql-contrib

# Initialize database cluster
sudo postgresql-setup --initdb

# Start and enable PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Verify installation
sudo systemctl status postgresql
```

---

### 2. Create User and Database

```bash
# Switch to postgres superuser
sudo -u postgres psql

# Inside psql prompt:
# Create user with password
CREATE USER your_username WITH PASSWORD 'your_password' CREATEDB;

# Create database
CREATE DATABASE your_database OWNER your_username;

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE your_database TO your_username;

# Exit
\q
```

---

### 3. Enable Password Authentication

PostgreSQL uses peer/ident authentication by default. Enable password authentication for pgAdmin and remote connections:

```bash
# Backup configuration
sudo cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.backup

# Edit configuration
sudo nano /var/lib/pgsql/data/pg_hba.conf
```

**Change these lines from `peer`/`ident` to `md5`:**

```
# "local" is for Unix domain socket connections only
local   all             all                                     md5

# IPv4 local connections:
host    all             all             127.0.0.1/32            md5

# IPv6 local connections:
host    all             all             ::1/128                 md5
```

**Restart PostgreSQL:**

```bash
sudo systemctl restart postgresql
```

---

### 4. Verify Setup

```bash
# Test connection with password
psql -h localhost -U your_username -d your_database

# Inside psql:
SELECT version();  -- Check version
\l                 -- List databases
\du                -- List users
\q                 -- Exit
```

---

## pgAdmin 4 Installation

### Method 1: DNF Package (Requires Setup)

```bash
# Install pgAdmin
sudo dnf install pgadmin4

# Configure to use home directory (fix permission issues)
sudo tee /usr/lib/pgadmin4/config_local.py > /dev/null << 'EOF'
import os
DATA_DIR = os.path.expanduser('~/.pgadmin4')
LOG_FILE = os.path.join(DATA_DIR, 'pgadmin4.log')
SQLITE_PATH = os.path.join(DATA_DIR, 'pgadmin4.db')
SESSION_DB_PATH = os.path.join(DATA_DIR, 'sessions')
STORAGE_DIR = os.path.join(DATA_DIR, 'storage')
EOF

# Create directory
mkdir -p ~/.pgadmin4

# Create convenient launcher
mkdir -p ~/.local/bin
cat > ~/.local/bin/pgadmin4 << 'EOF'
#!/bin/bash
if pgrep -f "pgAdmin4.py" > /dev/null; then
    echo "✅ pgAdmin is already running"
    echo "📍 URL: http://127.0.0.1:5050"
    xdg-open http://127.0.0.1:5050 2>/dev/null &
    exit 0
fi
echo "🚀 Starting pgAdmin 4..."
python3 /usr/lib/pgadmin4/pgAdmin4.py > ~/.pgadmin4/pgadmin4.log 2>&1 &
sleep 3
echo "✅ pgAdmin started at http://127.0.0.1:5050"
xdg-open http://127.0.0.1:5050 2>/dev/null &
EOF

chmod +x ~/.local/bin/pgadmin4

# Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```


---

### Launch pgAdmin

**DNF version:**
```bash
pgadmin4
# Opens at http://127.0.0.1:5050
```


**First launch:** You'll be asked to create pgAdmin login credentials (email/password). These are **separate** from your PostgreSQL credentials.

---

## Connect pgAdmin to PostgreSQL

**Important:** pgAdmin login credentials (email/password) are **separate** from PostgreSQL database credentials (username/password).

1. **Login to pgAdmin** with email/password you created

2. **Register PostgreSQL Server:**
   - Right-click **"Servers"** → **"Register"** → **"Server"**

3. **General tab:**
   - Name: `Local PostgreSQL`

4. **Connection tab:**
   - Host name/address: `localhost` or `127.0.0.1`
   - Port: `5432`
   - Maintenance database: `postgres`
   - Username: `your_postgresql_username` (from PostgreSQL setup)
   - Password: `your_postgresql_password` (from PostgreSQL setup)
   - ✅ Save password: Check this

5. **Click "Save"**

You should now see your databases in the left panel under **Servers → Local PostgreSQL → Databases**.


## Troubleshooting

### Connection Refused

**Error:** `connection refused`

**Solution:**
```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# If not running
sudo systemctl start postgresql
```

---

### Authentication Failed

**Error:** `authentication failed` or `ident authentication failed for user`

**Cause:** PostgreSQL is using peer/ident instead of password authentication

**Solution:**
```bash
# Edit pg_hba.conf
sudo nano /var/lib/pgsql/data/pg_hba.conf

# Change all "peer" and "ident" to "md5"
# Save and restart
sudo systemctl restart postgresql
```

---

### Can't Resolve Host

**Error:** `failed to resolve host 'loalhost'`

**Cause:** Typo in hostname

**Solution:** Use `localhost` or `127.0.0.1` (not "loalhost" or other typos)

---

### Permission Denied (pgAdmin)

**Error:** `Permission denied: /var/lib/pgadmin`

**Cause:** DNF pgAdmin tries to use system directory without permissions

**Solution:** Configure pgAdmin to use home directory (see installation steps above)

---

### Reset PostgreSQL User Password

```bash
# Connect as postgres superuser
sudo -u postgres psql

# Reset password
ALTER USER username WITH PASSWORD 'new_password';

# Exit
\q
```

---

### Port Already in Use

**Error:** Port 5432 already in use

**Solution:**
```bash
# Check what's using port 5432
sudo lsof -i :5432

# Or
sudo ss -tlnp | grep 5432

# Kill old PostgreSQL processes if needed
sudo pkill postgres
sudo systemctl restart postgresql
```

---

## Configuration Files

**PostgreSQL:**
```
/var/lib/pgsql/data/
├── postgresql.conf    # Main configuration
├── pg_hba.conf       # Authentication configuration (IMPORTANT)
└── pg_ident.conf     # User name mapping
```

**pgAdmin (DNF):**
```
~/.pgadmin4/
├── pgadmin4.db       # Server connections saved here
├── pgadmin4.log      # Application logs
└── storage/          # Query history and saved queries
```



---

## Security Best Practices

1. **Strong passwords:** Use strong passwords for database users
2. **Least privilege:** Create role-specific users, don't use `postgres` superuser for apps
3. **Network access:** Restrict to localhost for development
4. **Regular backups:** Automate daily backups
5. **Keep updated:** 
   ```bash
   sudo dnf update postgresql postgresql-server
   ```
6. **SSL/TLS:** For production, enable SSL connections
7. **Audit logging:** Enable logging for security audits

---

## Planned Tools

### Coming Soon
- **MongoDB:** NoSQL document database
- **Redis:** In-memory data store and cache
- **MinIO:** S3-compatible object storage for data lakes

Documentation will be added as tools are installed.

---

## Quick Reference

### One-Command Install

```bash
# Install PostgreSQL + pgAdmin
sudo dnf install postgresql-server postgresql-contrib pgadmin4 && \
sudo postgresql-setup --initdb && \
sudo systemctl start postgresql && \
sudo systemctl enable postgresql

# Configure authentication
sudo sed -i.backup 's/peer$/md5/g; s/ident$/md5/g' /var/lib/pgsql/data/pg_hba.conf && \
sudo systemctl restart postgresql

# Setup pgAdmin
sudo tee /usr/lib/pgadmin4/config_local.py > /dev/null << 'EOF'
import os
DATA_DIR = os.path.expanduser('~/.pgadmin4')
LOG_FILE = os.path.join(DATA_DIR, 'pgadmin4.log')
SQLITE_PATH = os.path.join(DATA_DIR, 'pgadmin4.db')
SESSION_DB_PATH = os.path.join(DATA_DIR, 'sessions')
STORAGE_DIR = os.path.join(DATA_DIR, 'storage')
EOF

mkdir -p ~/.pgadmin4

echo "✅ PostgreSQL installed and configured"
echo "Next: Create user and database with 'sudo -u postgres psql'"
```

### Essential Commands Cheat Sheet

```bash
# PostgreSQL Service
sudo systemctl start postgresql      # Start
sudo systemctl stop postgresql       # Stop
sudo systemctl status postgresql     # Status

# psql Access
psql -h localhost -U user -d db     # Connect
sudo -u postgres psql                # As superuser

# Inside psql
\l          # List databases
\du         # List users
\dt         # List tables
\c dbname   # Switch database
\q          # Quit

# Backup
pg_dump dbname > backup.sql         # Backup database
psql dbname < backup.sql            # Restore database

# pgAdmin
pgadmin4                            # Launch (DNF)
http://127.0.0.1:5050              # Access URL
```

---

## Resources

- **PostgreSQL Official Docs:** https://www.postgresql.org/docs/
- **pgAdmin Documentation:** https://www.pgadmin.org/docs/
- **Fedora PostgreSQL Guide:** https://docs.fedoraproject.org/en-US/quick-docs/postgresql/
- **PostgreSQL Tutorial:** https://www.postgresqltutorial.com/
- **SQL Practice:** https://pgexercises.com/

---

**Last Updated:** January 4, 2026  
**Tested On:** Fedora 43  
**PostgreSQL Version:** 16.x

---

[← Back to README](../README.md)
