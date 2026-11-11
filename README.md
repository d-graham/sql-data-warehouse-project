# SQL Data Warehouse from Scratch
Build a data warehouse with postgresql, including ETL processes, data modeling, and analytics.
From data with Baraa. Modifying source material SQL Server to my workflow using postresql.

----

Resources:
YouTube https://www.youtube.com/watch?v=9GVqKuTVANE
Github https://github.com/DataWithBaraa/sql-data-warehouse-project
Notion https://www.notion.com/templates/sql-data-warehouse-project




Data Warehouse design flow at high level:
- Start with a project plan (Notion). Can be complex. Planning up front reduces time cost risk of the project.
- Analyze & Understand the requirements. Meet with stakeholders and understand what exactly is needed to build, to guide design choices of the warehouse.


Objective
Develop a modern data warehouse using postgresql to consolidate sales data, enabling analytical reporting and informed ddecision-making.

Specifications
* Data Sources: Import data from two source systems (ERP and CRM) provided as csv files
* Data Quality: Cleanse and resolve data quality issues prior to analysis
* Integration: Combine both sources into a single, user-friendly data model designed for analytical queries
* Scope: Focus on the latest dataset only; historization of data is not required
* Documentation: Provide clear documentation of the data model to support both business stakeholders and analytics teams



Friction points
* Translating SQL Server to PostgreSQL
* SQL Server provides programmability for load scripts with tracking of load times, records loaded, and tests.
  Chose to load postgres at terminal using a bash script to handle server credential simply, with repeatable convenience.
  Python is a better fit for this friction point to include tests and collect information, left out respectful project scope as a SQL exercise.

