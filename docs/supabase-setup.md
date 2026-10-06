# Supabase Migration & Setup Guide

This guide walks you through migrating **Student Life Manager** from MySQL Workbench to **Supabase (Cloud PostgreSQL)**.

---

## 1. Why Supabase?
- **Cloud Hosted**: No local MySQL service needed on your machine.
- **Enterprise PostgreSQL**: Full ACID compliance, robust indexing, and standard SQL.
- **Built-in Web SQL Editor**: Run queries and view tables directly in your browser.
- **SSL by Default**: Secure encrypted connections out-of-the-box.

---

## 2. Step-by-Step Setup

### Step A: Create a Free Supabase Project
1. Go to [https://supabase.com](https://supabase.com) and sign in (via GitHub or email).
2. Click **New Project**.
3. Choose your organization, set a project name (e.g. `student-life-manager`), and set a **strong Database Password** *(save this password!)*.
4. Select a region closest to you (e.g., `South Asia (Mumbai)` or `East US`).
5. Click **Create new project** and wait ~1 minute for provisioning.

---

### Step B: Run the Database Schema & Seed Script
1. In your Supabase project dashboard, navigate to the **SQL Editor** tab (icon on the left sidebar).
2. Click **New query** (or `+`).
3. Open the file `database/supabase_setup.sql` in this project.
4. Copy the entire contents of `database/supabase_setup.sql` and paste them into the Supabase SQL Editor.
5. Click the green **Run** button (or press `Ctrl + Enter`).
6. You should see `Success. No rows returned` in the output window.
7. Click the **Table Editor** tab on the left sidebar to verify all 14 tables (`users`, `subjects`, `tasks`, `exams`, `timetable`, etc.) are populated!

---

### Step C: Retrieve Your Connection Details
1. In the Supabase dashboard, click the **Settings** gear icon (bottom left) -> **Database**.
2. Scroll to the **Connection parameters** section or **Connection string**.

You have two connection options:

#### Option 1: Direct Connection (Port 5432)
- **Host**: `db.[your-project-ref].supabase.co`
- **Port**: `5432`
- **Database name**: `postgres`
- **User**: `postgres`
- **Password**: `[the database password you created in Step A]`
- **SSL**: `require`

#### Option 2: Connection Pooler / URI (Recommended for IPv4 networks)
- Under **Connection string**, select **URI** and choose **Session** or **Transaction** mode.
- Format:
  ```text
  postgresql://postgres.[project-ref]:[your-password]@aws-0-[region].pooler.supabase.com:6543/postgres
  ```

---

### Step D: Configure the Java Application
You can supply your Supabase credentials in either of two ways:

#### Method 1: Edit `src/main/resources/db.properties`
Open `src/main/resources/db.properties` and enter your details:

```properties
db.type=postgresql
db.host=db.YOUR_PROJECT_REF.supabase.co
db.port=5432
db.name=postgres
db.user=postgres
db.password=YOUR_ACTUAL_PASSWORD
db.sslmode=require
```

*Or paste the full URI:*
```properties
db.url=postgresql://postgres.YOUR_PROJECT_REF:YOUR_PASSWORD@aws-0-ap-south-1.pooler.supabase.com:6543/postgres
```

#### Method 2: Using Environment Variables (Production / CI / Docker)
Set the following environment variables:
```bash
# Windows PowerShell
$env:DB_HOST="db.YOUR_PROJECT_REF.supabase.co"
$env:DB_PORT="5432"
$env:DB_NAME="postgres"
$env:DB_USER="postgres"
$env:DB_PASSWORD="YOUR_ACTUAL_PASSWORD"
$env:DB_SSLMODE="require"

# Or simply set DATABASE_URL
$env:DATABASE_URL="postgresql://postgres.YOUR_PROJECT_REF:YOUR_PASSWORD@aws-0-ap-south-1.pooler.supabase.com:6543/postgres"
```

---

## 3. Demo Credentials
Once the seed data is executed in Supabase:
- **URL**: `http://localhost:8080/student-life-manager/` (or root context depending on Tomcat deployment)
- **Username**: `demo`
- **Password**: `demo123`

---

## 4. Key Differences from MySQL Workbench

| Feature | MySQL Workbench | Supabase (PostgreSQL) |
|---|---|---|
| **Primary Keys** | `INT AUTO_INCREMENT` | `SERIAL PRIMARY KEY` |
| **Current Date** | `CURDATE()` | `CURRENT_DATE` |
| **Conditional Count** | `SUM(IF(cond, 1, 0))` | `SUM(CASE WHEN cond THEN 1 ELSE 0 END)` |
| **Custom Ordering** | `FIELD(col, 'A', 'B')` | `CASE col WHEN 'A' THEN 1 WHEN 'B' THEN 2 END` |
| **Timestamp Triggers** | `ON UPDATE CURRENT_TIMESTAMP` | PostgreSQL `BEFORE UPDATE` trigger function |
| **Management GUI** | Desktop app (Workbench) | Browser Web App (Supabase Dashboard) |
| **SSL Enforcement** | Optional | Required (`sslmode=require`) |
