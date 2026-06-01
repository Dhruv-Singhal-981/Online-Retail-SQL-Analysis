
# Online Retail Store Database Design & Business Analysis

---

## Project Background

This project focuses on the end-to-end database design, data ingestion, data quality optimization, and strategic business analysis for an online retail bookstore system (`ONLINE_RETAIL_STORE`). Operating as a foundational data engineering and business intelligence asset, the database manages three core relational entities: Books, Customers, and Orders. 

The primary business objective is to transition raw, unstructured transactional records into a clean, highly reliable relational schema. By writing optimized T-SQL queries, this analysis surfaces actionable insights across sales performance, customer purchasing behavior, and critical inventory metrics—proving how targeted data queries directly inform backend retail operations, warehouse stock control, and revenue retention strategies.

### Tools & Technologies Used:
* **Database Engine:** Microsoft SQL Server (T-SQL)
* **Core Core Concepts:** Relational Database Design, Data Definition Language (DDL), Data Manipulation Language (DML), Data Quality Control
* **Advanced SQL Techniques:** Bulk Data Ingestion, Post-Ingestion Schema Alteration, Multi-Table Conversions (INNER/LEFT/RIGHT Joins), Conditional Aggregations, Subqueries, Subquery Reconciliations

---

## Data Structure & Schema Optimization

The system processes an operational dataset split across three relational tables containing data points across booking workflows, financial margins, customer contact data, and warehouse tracking.

### Entity Attributes & Data Type Transformations

During the initial ingestion phase, raw staging tables were designed with broad `VARCHAR` constraints to guarantee successful raw data loads. Post-ingestion, strict data validation checks were applied using `ALTER TABLE` procedures to transform structural attributes into native database types, protecting mathematical operations from string calculation bugs.

| Table | Attribute | Initial Staging Type | Optimized Production Type | Business Domain / Logic |
| :--- | :--- | :--- | :--- | :--- |
| **BOOKS** | `Book_ID` | VARCHAR(10) | INT (Primary Key) | Unique identifier for product inventory |
| | `Title` | VARCHAR(150) | VARCHAR(150) | Full title of the bookstore book asset |
| | `Author` | VARCHAR(100) | VARCHAR(100) | Book author name for categorical tracking |
| | `Genre` | VARCHAR(50) | VARCHAR(50) | Core genre classification (e.g., Fiction, Fantasy) |
| | `Published_Year`| VARCHAR(4) | INT | Historical publication timeline tracking |
| | `Price` | DECIMAL(10,2) | DECIMAL(10,2) | Numeric book base cost per item unit |
| | `Stock` | VARCHAR(10) | INT | Physical warehouse stock units available |
| **CUSTOMERS**| `Customer_ID` | VARCHAR(10) | INT (Primary Key) | Unique relational identifier for store accounts |
| | `Name_` | VARCHAR(100) | VARCHAR(100) | Full customer registration name |
| | `Email` | VARCHAR(100) | VARCHAR(100) | Primary customer electronic communication record |
| | `Phone` | VARCHAR(20) | VARCHAR(20) | Customer mobile contact number |
| | `City` | VARCHAR(100) | VARCHAR(100) | Local municipality distribution geography |
| | `Country` | VARCHAR(100) | VARCHAR(100) | International boundary distribution country |
| **ORDERS** | `Order_ID` | VARCHAR(10) | INT (Primary Key) | Unique system transaction voucher receipt |
| | `Customer_ID` | VARCHAR(10) | INT (Foreign Key) | Mapping field to the validated Customer table |
| | `Book_ID` | VARCHAR(10) | INT (Foreign Key) | Mapping field to the validated Books inventory table |
| | `Order_Date` | DATE | DATE | Calendar date when transaction was recorded |
| | `Quantity` | VARCHAR(10) | INT | Number of specific product volumes purchased |
| | `Total_Amount` | DECIMAL(10,2) | DECIMAL(10,2) | Net transaction financial value ($) |

### Ingestion Strategy & Data Quality Controls
To mimic modern corporate data engineering workflows, data pipelines were simulated locally using structured bulk operations. 

1. **Schema Isolation:** Implemented idempotent table teardown scripts using `DROP TABLE IF EXISTS` to ensure clean initial staging runs.
2. **Bulk Ingestion Pipeline:** Extracted flat source files directly via the `BULK INSERT` protocol, managing header rows and parsing localized delimiters safely:
```sql
   BULK INSERT ORDERS
   FROM "C:\Users\dhruv\Downloads\Orders.csv"
   WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n')
```

## Executive Summary

### Overview of Operational Findings
The relational schema validation reveals a bookstore portfolio driven by highly concentrated demand segments across key genres and transaction types. Fiction and Fantasy genres command the highest volume footprint, requiring prioritized warehouse positioning and strategic logisitical planning.

A deep logical review of transaction volumes highlighted that simple, flat joins result in structural calculation errors due to row replication. Corrective statistical auditing isolated the system from "Fan-Out" data inflation traps, providing business leaders with a true, uninflated visualization of physical assets and operational performance.

---

### Three Key Takeaways
*   **Data Engineering Drives Analytics Accuracy:** Transitioning unstructured data types from flexible `VARCHAR` formats to highly specialized numeric systems is a strict prerequisite for executing baseline business metrics like profit tracking and inventory volume monitoring.
*   **Direct Operational Optimization via SQL Data Quality:** By analyzing customer purchase frequency thresholds (`HAVING COUNT(Order_ID) >= 2`), marketing programs can execute localized retention targeting rather than relying on margin-eroding, wide-net promotions.
*   **Warehouse Financial Risk Mitigation:** Resolving join duplication logic errors revealed that true operational remaining stock figures must be calculated using isolated, non-joined subqueries, successfully avoiding catastrophic systemic inventory inflation reports.

---

## Analytical Deep Dive & Business Logic Insights

### Category 1: Revenue & Sales Performance

#### Insight 1: Financial Footprint Identification
Summing total gross performance across all history via `SUM(ISNULL(Total_Amount,0))` acts as the baseline economic metric, establishing the corporate benchmark to judge future product category rollouts against.

#### Insight 2: High-Velocity Volume Sorting
Isolating distinct book listings valued at premium pricing thresholds reveals high-margin inventory concentrations, allowing business teams to optimize retail display architecture around maximum revenue drivers.

```sql
SELECT * FROM BOOKS
WHERE Price = (SELECT MAX(Price) FROM BOOKS);
```

#### Insight 3: Premium-Basket Volume Extraction
Filtering orders exceeding specific monetary basket sizes isolates high-value sales behaviors from baseline small retail sales, establishing clear criteria for premium shipment validation rules.

```SQL
SELECT * FROM ORDERS
WHERE Total_Amount > 20
ORDER BY Order_ID ASC;
```
---

### Category 2: Customer Segmentation & Behavior

#### Insight 1: Regional Boundary Targeting
Isolating regional boundary criteria identifies specific geographical consumer bases (such as international customer segments located in Canada). This allows supply chain planners to calculate localized regional distribution centers efficiently.

```SQL
SELECT Name_ FROM CUSTOMERS
WHERE Country = 'Canada'
ORDER BY Name_ ASC;
```
#### Insight 2: Wholesale vs. Single-Unit Purchasing Patterns
Joining transactional files with customer records exposes accounts buying multiple product iterations simultaneously within individual transactions. This distinguishes corporate or wholesale buyers from everyday retail store traffic.

```SQL
SELECT C.Name_, O.Quantity 
FROM CUSTOMERS C
INNER JOIN ORDERS O ON C.Customer_ID = O.Customer_ID
WHERE O.Quantity > 1
ORDER BY C.Name_ ASC;
```
#### Insight 3: Core Lifetime Customer Value (LTV) Mapping
Grouping customer transactions via analytical aggregations extracts the single highest financial contributor across history. Identifying this top tier guides VIP loyalty program outreach and high-value account management.

```SQL
SELECT TOP 1 Name_, Phone, Email, SUM(ISNULL(Total_Amount,0)) AS Amount_Spent 
FROM CUSTOMERS C
LEFT JOIN ORDERS O ON C.Customer_ID = O.Customer_ID
GROUP BY Name_, Phone, Email
ORDER BY SUM(ISNULL(Total_Amount,0)) DESC;
```
#### Insight 4: Dynamic Customer Order Frequency Tracking
Applying conditional structural grouping separates casual consumer drop-ins from habitual repeat users. This query filters the customer base to locate accounts who have successfully achieved real lifetime repeat ordering volume thresholds.

```SQL
SELECT C.Customer_ID, C.Name_, COUNT(O.Order_ID) AS Total_Orders_Placed
FROM CUSTOMERS C
INNER JOIN ORDERS O ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_ID, C.Name_
HAVING COUNT(O.Order_ID) >= 2
ORDER BY Total_Orders_Placed DESC;
```
---

### Category 3: Inventory Control & Warehouse Optimization

#### Insight 1: Genre Product Velocity Mapping
Grouping units sold across distinct category genres tracks exactly which themes dominate product volume. This allows warehouse managers to optimize physical shelf allocation based on real consumer velocity.

```SQL
SELECT B.Genre, SUM(ISNULL(Quantity,0)) AS Books_Sold 
FROM BOOKS B
LEFT JOIN ORDERS O ON B.Book_ID = O.Book_ID
GROUP BY B.Genre
ORDER BY Books_Sold DESC;
```
#### Insight 2: Mitigating Supply Chain Stockout Failures
Isolating low stock metrics identifies warehouse items approaching zero volume availability. This surfaces high-velocity items that require immediate reorder triggers to maintain continuity of supply.

```SQL
SELECT Title AS Book_Name, Author, Stock 
FROM BOOKS
WHERE Stock = (SELECT MIN(Stock) FROM BOOKS);
```
#### Insight 3: Resolving Relational "Fan-Out" Duplication Errors
The Technical Problem: Joining the BOOKS catalog table to a transactional ORDERS sales tracking sheet creates a one-to-many relationship mapping. If an individual book contains multiple sales orders, a simple joint aggregation duplicates the original warehouse inventory counts on every single sales line, generating highly inflated reporting errors.

The Solution: To compute true remaining stock quantities safely, the query processes calculations via totally isolated independent subqueries. It isolates warehouse starting quantities completely from sales volume metrics before performing the final arithmetic, preventing row inflation.

```SQL
SELECT 
    (SELECT SUM(CAST(ISNULL(Stock, 0) AS INT)) FROM BOOKS) - 
    (SELECT SUM(ISNULL(Quantity, 0)) FROM ORDERS) AS Remainder_Stock;
```    
---

### Operational Recommendations
Implement Automated Schema Guards: Build transactional constraints into the data pipeline to check data types during file loading, stopping malformed data from ever entering core tracking environments.

Establish Automatic Low-Stock Reordering Thresholds: Wire the minimum warehouse stock alert queries directly into procurement workflows, reducing manual inventory checks and mitigation delays.

Execute High-Spender Loyalty Promotions: Leverage historical lifetime value (LTV) groupings to build automated rewards or retention campaigns for repeat buyers, increasing high-margin retention.

Enforce Independent Calculations for Inventory Accounting: Mandate that all operational business reports use isolated subquery logic for stock calculations, shielding corporate leadership from artificial asset inflation reports.

---

### How to Deploy & Execute This Project
Clone the Environment: Download the localized repository structure and script files to your local workstation.

Launch Database Management Tooling: Open Microsoft SQL Server Management Studio (SSMS) or any relational database engine terminal.

Configure Source Files: Place the raw transactional CSV resources (Books.csv, Customers.csv, Orders.csv) into a known database tracking directory.

Initialize Path Coordinates: Update the static storage paths within the project's BULK INSERT processing blocks to align exactly with your local storage location.

Run Script Pipeline Sequentially: Execute the structural statements in order to generate the initial database shell, complete the post-ingestion data cleaning, and execute the full analytics suite.
