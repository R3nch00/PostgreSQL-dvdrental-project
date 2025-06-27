# PostgreSQL-dvdrental-project 🎬
PostgreSQL dvdrental sample database for query practice
This project explores the popular `dvdrental` sample database using PostgreSQL. It includes SQL practice covering fundamentals, joins, filtering, data types, schema design, and advanced queries.
- Source: [dvdrental Sample Dataset](https://github.com/imkumaraju/dvdrenat-sample-databse)
  
## 📁 Project Structure

```bash
postgresql-dvdrental-project/
├── dvdrental.tar                 # PostgreSQL backup file
├── sql/
│   ├── 01_basics.sql
│   ├── 02_data_types.sql
│   ├── 03_filtering.sql
│   ├── 04_table_management.sql
│   ├── 05_modifying_data.sql
│   ├── 06_conditionals.sql
│   └── 07_joins_and_schemas.sql
└── README.md

📚 Topics Covered
  •	✅ PostgreSQL Basics

  •	✅ Data Types & Filtering

  •	✅ Table Creation and Management

  •	✅ Joins, Subqueries & Schemas

  •	✅ Modifying Data with Conditions

  •	✅ Real-world use cases with practice queries

🚀 How to Use

1. Restore the Database
  •	Open pgAdmin 4
  •	Create a new database: dvdrental
  •	Go to Restore → Select dvdrental.tar → Format: Custom or tar
  •	Check ✅ "Clean before restore"
  •	Click Restore
2. Explore Queries
  •	Go to the /sql folder
  •	Open each SQL file and run the queries in pgAdmin or psql

📸 Screenshots

🛠️ Requirements
  •	PostgreSQL 13+
  •	pgAdmin 4 / SQL Shell (psql)

📃 License
This project is open-source under the MIT License.
