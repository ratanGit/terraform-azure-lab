#Terraform will inject the variables into this file. 
#Note the double dollar signs ($${})—these tell Terraform: "Don't touch this; let Docker handle it later."

# --- Base Directory ---
BASE_PATH=${base_path}

# --- Credentials ---
GUAC_DB_NAME=${guac_db_name}
GUAC_DB_USER=${guac_db_user}
GUAC_DB_PASSWORD=${guac_db_password}

NPM_DB_NAME=npm_mgmt_db
NPM_DB_USER=npm_admin
NPM_DB_PASSWORD=${npm_db_password}

# --- Dynamic Paths (Escaped for Docker) ---
GUAC_HOME_DIR=$${BASE_PATH}/home
INIT_SQL_PATH=$${BASE_PATH}/init/initdb.sql
DB_DATA_PATH=$${BASE_PATH}/data/postgres
NPM_DATA_PATH=$${BASE_PATH}/data/npm
LETSENCRYPT_PATH=$${BASE_PATH}/letsencrypt

# --- Network ---
GUAC_PORT=8080
GUAC_DNS=${guacamole_dns_name}