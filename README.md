# Online Retail Store Data Analysis (SQL)

## Project Overview
This project is an end-to-end SQL portfolio piece where I built a relational database for an online bookstore from scratch. I designed the table structures, imported raw data from CSV files, handled post-ingestion data cleaning, and wrote queries to solve practical business problems. 

Instead of just writing code to pull data, I focused on the **"why"** behind every question to demonstrate how basic database administration and querying directly help a retail business manage its inventory, marketing, and sales performance.

---

## The Dataset
The project utilizes three relational datasets representing an online bookstore ecosystem:
*   **BOOKS:** Details about titles, authors, genres, retail prices, and stock levels.
*   **CUSTOMERS:** Profile information including names, emails, and locations.
*   **ORDERS:** Transaction records tracking which customer bought which book, when, and in what quantity.

🔗 **Dataset Link:** https://www.kaggle.com/datasets/dhruvsinghalanalyst/online-retail-store-data-analysis-sql

---

## Database Setup & Data Cleaning

### 1. Table Creation & Bulk Ingestion
I established the initial schemas using flexible text fields (`VARCHAR`) to guarantee a successful raw data load. To load the flat data files into SQL Server efficiently, I implemented the `BULK INSERT` protocol:

```sql
BULK INSERT ORDERS
FROM "C:\YourFilePath\Orders.csv"
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
```

### 2. Fixing Data Types (Data Quality Control)
Raw transactional data frequently imports with type mismatches. Because mathematical operations cannot run on text formatting, I executed post-ingestion ALTER TABLE scripts. This safely converted keys, quantities, and prices into optimized numeric structures (INT and DECIMAL) for accurate processing:

```
ALTER TABLE ORDERS ALTER COLUMN Order_ID INT;
ALTER TABLE ORDERS ALTER COLUMN Quantity INT;
ALTER TABLE BOOKS ALTER COLUMN Price DECIMAL(10,2);
ALTER TABLE BOOKS ALTER COLUMN Stock INT;
```

#### Business-Driven Queries & Insights
The analytical script is organized into three operational categories to answer real-world business problems:

### 1. Sales & Revenue Performance
What is our total historical revenue?

**Business Logic:** This serves as the absolute baseline baseline metric to understand the store's financial footprint.

SELECT SUM(ISNULL(Total_Amount,0)) AS Total_Revenue FROM ORDERS;
    ```

*   **Which genres are driving the highest volume of sales?**
    *   *Business Logic:* Identifying high-velocity genres (like Fiction or Fantasy) tells inventory planners exactly which book categories deserve more budget in future procurement cycles.

```
sql
    SELECT B.Genre, SUM(ISNULL(Quantity,0)) AS Books_Sold 
    FROM BOOKS B
    LEFT JOIN ORDERS O ON B.Book_ID = O.Book_ID
    GROUP BY B.Genre
    ORDER BY Books_Sold DESC;
```

*   **What is the average price of a 'Fantasy' book?**
    *   *Business Logic:* Helps the store understand category pricing benchmarks for setting standard rates on future catalog updates.

```sql
    SELECT ROUND(AVG(ISNULL(Price,0)),2) AS AVG_price FROM BOOKS
    WHERE Genre = 'Fantasy';
```

### 2. Customer Behavior & Core Targeting

*   **Who is our absolute top-spending customer?**
    *   *Business Logic:* Pinpoints high-value accounts so the business can invite them to targeted loyalty programs or exclusive high-ticket sales.

```sql
    SELECT TOP 1 Name_, Phone, Email, SUM(ISNULL(Total_Amount,0)) AS Amount_Spent 
    FROM CUSTOMERS C
    LEFT JOIN ORDERS O ON C.Customer_ID = O.Customer_ID
    GROUP BY Name_, Phone, Email
    ORDER BY SUM(ISNULL(Total_Amount,0)) DESC;
```

*   **Which customers are repeat buyers (placed 2 or more orders)?**
    *   *Business Logic:* Separates one-time drop-in traffic from highly loyal repeat users, allowing marketing teams to run specific retention campaigns instead of profit-wasting storewide sales.

```sql
    SELECT C.Customer_ID, C.Name_, COUNT(O.Order_ID) AS Total_Orders
    FROM CUSTOMERS C
    INNER JOIN ORDERS O ON C.Customer_ID = O.Customer_ID
    GROUP BY C.Customer_ID, C.Name_
    HAVING COUNT(O.Order_ID) >= 2;
```

*   **Who are our bulk/wholesale buyers?**
    *   *Business Logic:* Isolates instances where customers purchase multiple copies of a single book in a single order, highlighting potential commercial or B2B buyers.

```sql
    SELECT C.Name_, O.Quantity FROM CUSTOMERS C
    INNER JOIN ORDERS O ON C.Customer_ID = O.Customer_ID
    WHERE O.Quantity > 1
    ORDER BY C.Name_ ASC;
 ```

### 3. Inventory & Warehouse Control

*   **Which items are running dangerously low on stock?**
    *   *Business Logic:* Instantly surfaces product lines at immediate risk of stocking out, saving the business from missing out on active demand.

```sql
    SELECT Title AS Book_Name, Author, Stock FROM BOOKS
    WHERE Stock = (SELECT MIN(Stock) FROM BOOKS);
 ```

*   **What is the true remaining stock available in our warehouse?**
    *   *The SQL Challenge:* Joining a product table to a transactional table creates a one-to-many match. If a popular book has 20 orders, a flat join duplicates the original warehouse stock level 20 times, inflating aggregate results. 
    *   *The Solution:* I used independent subqueries to keep the total starting inventory completely separate from sales volume before doing the subtraction, ensuring our physical asset data remains 100% accurate.

```sql
    SELECT 
        (SELECT SUM(CAST(ISNULL(Stock, 0) AS INT)) FROM BOOKS) - 
        (SELECT SUM(ISNULL(Quantity, 0)) FROM ORDERS) AS Remainder_Stock;
```

---

## Key Technical Takeaways
*   **Data Integrity Matters First:** Real data is messy. I learned that structuring, cleaning, and optimizing variable data types (`VARCHAR` to numeric keys) is essential before any true analysis can happen.
*   **The Trap of Join Duplications:** This project taught me the "Fan-Out" trap where joins can accidentally multiply inventory values during aggregations. Solving this via isolated subqueries significantly improved my logical approach to relational databases.
*   **Thinking Like an Analyst:** I practiced moving past just "writing code" to focus on connecting my queries to business operations, ensuring my technical work supports better inventory control and smarter sales choices.
