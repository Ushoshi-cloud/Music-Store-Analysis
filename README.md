# Music-Store-Analysis
PostgreSQL Music Store Analysis
A collection of SQL queries to analyze customer behavior, sales, and trends in a digital music store.

About the Project
This project contains SQL queries written in PostgreSQL to analyze various aspects of a music store database. The queries cover Easy, Moderate, and Advanced levels of difficulty and focus on key business insights, such as:

Identifying top customers and best-selling genres

Analyzing artist popularity and customer spending patterns

Finding cities and countries contributing the most revenue

Dataset Used

The queries are designed for a music store database that contains tables like:

Customer – Stores customer details

Invoice – Contains transaction details

Invoice_Line – Tracks each purchased item

Track – Stores song details

Album – Groups tracks into albums

Artist – Contains artist names

Genre – Classifies tracks into genres

SQL Queries Included


Question Set 1 - Easy
1. Find the most senior employee based on job title
   
SELECT first_name, last_name, levels 
FROM employee
ORDER BY levels DESC 
LIMIT 1;
2. Identify the country with the most invoices

SELECT COUNT(invoice_id) AS total_invoice, billing_country 
FROM invoice 
GROUP BY billing_country
ORDER BY total_invoice DESC 
LIMIT 1;

3. List the top 3 highest invoice totals

SELECT total 
FROM invoice
ORDER BY total DESC 
LIMIT 3;

4. Find the city generating the highest revenue

SELECT SUM(total) AS total_invoices, billing_city 
FROM invoice 
GROUP BY billing_city 
ORDER BY total_invoices DESC 
LIMIT 3;

5. Determine the best customer (highest spending)

SELECT customer.customer_id, first_name, last_name, SUM(invoice.total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;

Question Set 2 - Moderate
6. Find all Rock music listeners (email, name, genre)

SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
    SELECT track_id 
    FROM track
    JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

7. Identify the top 10 Rock artists based on track count

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

8. Find tracks longer than the average song length

SELECT name, milliseconds 
FROM track 
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_length
    FROM track 
)
ORDER BY milliseconds DESC 
LIMIT 1;

Question Set 3 - Advanced

9. Calculate customer spending per artist

SELECT customer.first_name AS name, artist.artist_id AS Artist_id, 
       SUM(invoice_line.unit_price * invoice_line.quantity) AS Total_spent
FROM customer 
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN album ON track.album_id = album.album_id
JOIN artist ON album.artist_id = artist.artist_id
GROUP BY customer.first_name, artist.artist_id
ORDER BY Total_spent DESC;

10. Determine the most popular genre in each country

WITH popular_genre AS (
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
    ORDER BY customer.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

11. Find the top spender in each country

WITH CUSTOMER_COUNTRY AS (
    SELECT customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country AS country, 
           SUM(invoice.total) AS Total_spending,
           ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY SUM(invoice.total) DESC) AS Rowno
    FROM customer 
    JOIN invoice ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country
    ORDER BY invoice.billing_country ASC, Total_spending DESC
)
SELECT * FROM CUSTOMER_COUNTRY WHERE Rowno <= 1;


Note - pgAdmin does not have a built-in formatter. Try these alternatives:

1️⃣ Online Formatter: pgFormatter
2️⃣ VS Code: Install "SQL Formatter", press Shift + Alt + F
