--Creating the Database
CREATE DATABASE ONLINE_RETAIL_STORE
USE ONLINE_RETAIL_STORE


--Creating the Tables
CREATE TABLE ORDERS(
Order_ID VARCHAR(4),
Customer_ID VARCHAR(4),
Order_Date DATE,
Quantity VARCHAR(4),
Total_Amount DECIMAL(6,2)
)

CREATE TABLE BOOKS(
Book_ID VARCHAR(4),
Title VARCHAR(75),
Author VARCHAR(50),
Genre VARCHAR(50),
Published_Year VARCHAR(4),
Price DECIMAL(5,2),
Stock VARCHAR(5)
)

CREATE TABLE CUSTOMERS(
Customer_ID VARCHAR(4),
Name_ VARCHAR(50),
Email VARCHAR(75),
Phone VARCHAR(15),
City VARCHAR(40),
Country VARCHAR(40)
)


-- Drop existing tables if they exist to apply new schema
DROP TABLE IF EXISTS ORDERS;
DROP TABLE IF EXISTS BOOKS;
DROP TABLE IF EXISTS CUSTOMERS;


CREATE TABLE ORDERS (
Order_ID VARCHAR(10),
Customer_ID VARCHAR(10),
Book_ID VARCHAR(10),
Order_Date DATE,
Quantity VARCHAR(10),
Total_Amount DECIMAL(10,2)
)

CREATE TABLE BOOKS (
Book_ID VARCHAR(10),
Title VARCHAR(150),
Author VARCHAR(100),
Genre VARCHAR(50),
Published_Year VARCHAR(4),
Price DECIMAL(10,2),
Stock VARCHAR(10)
)

CREATE TABLE CUSTOMERS (
Customer_ID VARCHAR(10),
Name_ VARCHAR(100),
Email VARCHAR(100),
Phone VARCHAR(20),
City VARCHAR(100),
Country VARCHAR(100)
)


--Importing the Datasets
BULK INSERT ORDERS
FROM "C:\Users\dhruv\Downloads\Orders.csv"
WITH(
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)

BULK INSERT BOOKS
FROM "C:\Users\dhruv\Downloads\Books.csv"
WITH(
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)

BULK INSERT CUSTOMERS
FROM "C:\Users\dhruv\Downloads\Customers.csv"
WITH(
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)


SELECT TOP 10 * FROM ORDERS
SELECT TOP 10 * FROM BOOKS
SELECT TOP 10 * FROM CUSTOMERS


--BASIC QUERIES
-- Retrieve all books in the "Fiction" genre.
SELECT Title as Book_Name, Author FROM BOOKS
WHERE Genre = 'Fiction'
ORDER BY Title asc

-- Find books published after the year 1950.
SELECT Title as Book_Name, Author FROM BOOKS
WHERE Published_Year > 1950
ORDER BY Title asc

-- List all customers from the Canada.
SELECT Name_ FROM CUSTOMERS
WHERE Country = 'Canada'
ORDER BY Name_ asc

-- Show orders placed in November 2023.
SELECT * FROM ORDERS
WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30'
ORDER BY Order_ID asc

-- Retrieve the total stock of books available.
SELECT SUM(CAST(ISNULL(Stock,0) AS INT)) as Total_Stock_Available FROM BOOKS


--Correction
ALTER TABLE ORDERS ALTER COLUMN Order_ID INT
ALTER TABLE ORDERS ALTER COLUMN Customer_ID INT
ALTER TABLE ORDERS ALTER COLUMN Book_ID INT
ALTER TABLE ORDERS ALTER COLUMN Quantity INT

ALTER TABLE BOOKS ALTER COLUMN Book_ID INT
ALTER TABLE BOOKS ALTER COLUMN Published_Year INT
ALTER TABLE BOOKS ALTER COLUMN Stock INT

ALTER TABLE CUSTOMERS ALTER COLUMN Customer_ID INT


-- Find the details of the most expensive book.
SELECT * FROM BOOKS
WHERE Price = (SELECT MAX(Price) FROM BOOKS)

-- Show all customers who ordered more than 1 quantity of a book.
SELECT C.Name_, O.Quantity FROM CUSTOMERS C
INNER JOIN ORDERS O ON C.Customer_ID = O.Customer_ID
WHERE O.Quantity > 1
ORDER BY C.Name_ asc

-- Retrieve all orders where the total amount exceeds $20.
SELECT * FROM ORDERS
WHERE Total_Amount > 20
ORDER BY Order_ID asc

-- List all genres available in the Books table.
SELECT DISTINCT Genre FROM BOOKS

-- Find the book with the lowest stock.
SELECT Title as Book_Name, Author, Stock FROM BOOKS
WHERE Stock = (SELECT MIN(Stock) FROM BOOKS)

-- Calculate the total revenue generated from all orders.
SELECT SUM(ISNULL(Total_Amount,0)) as Total_Revenue FROM ORDERS


--ADVANCE QUERIES
-- Retrieve the total number of books sold for each genre.
SELECT B.Genre, SUM(ISNULL(Quantity,0)) as Books_Sold FROM BOOKS B
LEFT JOIN ORDERS O ON B.Book_ID = O.Book_ID
GROUP BY B.Genre
ORDER BY SUM(ISNULL(Quantity,0)) DESC

-- Find the average price of books in the "Fantasy" genre.
SELECT ROUND(AVG(ISNULL(Price,0)),2) as AVG_price FROM BOOKS
WHERE Genre = 'Fantasy'

-- List customers who have placed at least 2 orders.
SELECT C.Name_, COUNT(ISNULL(O.Quantity,0)) as Total_Orders FROM CUSTOMERS C
INNER JOIN ORDERS O ON C.Customer_ID = O.Customer_ID
GROUP BY C.Name_
HAVING COUNT(ISNULL(O.Quantity,0)) >= 2
ORDER BY COUNT(ISNULL(O.Quantity,0)) desc

-- Find the most frequently ordered book.
SELECT TOP 1 B.Title as Book_Name, B.Author, COUNT(DISTINCT O.Order_ID) as Total_Orders FROM BOOKS B
RIGHT JOIN ORDERS O ON B.Book_ID = O.Book_ID
GROUP BY B.Title, B.Author
ORDER BY COUNT(DISTINCT O.Order_ID) desc

-- Show the top 3 most expensive books of 'Fantasy' Genre.
SELECT TOP 3 Title as Book_Name, Author, Price FROM BOOKS
ORDER BY Price desc

-- Retrieve the total quantity of books sold by each author.
SELECT B.Author, SUM(ISNULL(O.Quantity,0)) as Books_Sold FROM BOOKS B
LEFT JOIN ORDERS O ON B.Book_ID = O.Book_ID
GROUP BY B.Author
ORDER BY SUM(ISNULL(O.Quantity,0)) desc

-- List the cities where customers who spent over $30 are located.
SELECT C.City, SUM(ISNULL(O.Total_Amount,0)) as Total_Amount FROM CUSTOMERS C
INNER JOIN ORDERS O ON C.Customer_ID = O.Customer_ID
GROUP BY C.City
HAVING SUM(ISNULL(O.Total_Amount,0)) > 30
ORDER BY SUM(ISNULL(O.Total_Amount,0)) desc

-- Find the customer who spent the most on orders.
SELECT TOP 1 Name_, Phone, Email, SUM(ISNULL(Total_Amount,0)) as Amount_Spent FROM CUSTOMERS C
LEFT JOIN ORDERS O ON C.Customer_ID = O.Customer_ID
GROUP BY Name_, Phone, Email
ORDER BY SUM(ISNULL(Total_Amount,0)) desc

-- Calculate the stock remaining after fulfilling all orders.
SELECT (SELECT SUM(ISNULL(Stock,0)) FROM BOOKS) - (SELECT SUM(ISNULL(Quantity,0)) FROM ORDERS) as Remainder_Stock