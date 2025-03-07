--Question Set 1 - Easy
--Q1. Who is the most senior employee based on job title? 

select first_name, last_name, levels from employee 
order by levels desc limit 1;

--Q2. Which country has the most invoices? 

select count(invoice_id) as total_invoice, billing_country from invoice 
group by billing_country
order by total_invoice desc limit 1;

--Q3. What are the top 3 values of the total invoice? 

select total from invoice
order by total desc limit 3; 

--Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city where we made the most money. 
--Write a query that returns the city with the highest invoice totals.
--The query should return both the city name and the sum of all invoice totals.

select sum(total) as total_invoices, billing_city from invoice 
group by billing_city 
order by total_invoices desc limit 3;

--Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money.

SELECT customer.customer_id, first_name, last_name, SUM(invoice.total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;

--Question Set 2 - Moderate

--Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--Q2: Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands.


SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

--Q3.Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

select name, milliseconds from track 
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
order by milliseconds desc limit 1;


--Question Set 3 - Advance
--Q1: Find how much each customer spent on artists. Write a query to return customer name, artist name, and total spent.

select customer.first_name as name, artist.artist_id as Artist_id, sum(invoice_line.unit_price*invoice_line.quantity) as Total_spent
from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by customer.first_name, artist.artist_id
order by total_spent desc;

--Q2.Q2: We want to find out each country's most popular music Genre. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared for all the Genres.

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


--Q3: Write a query that determines the customer spending the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount.


WITH CUSTOMER_COUNTRY AS 
(select customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country as country, SUM(Invoice.Total) as Total_spending,
ROW_NUMBER()OVER(PARTITION BY invoice.billing_country order by SUM(Invoice.Total)DESC) as Rowno
from Customer 
Join Invoice on customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by invoice.billing_country asc, total_spending desc
)
select * from customer_country where rowno<=1







 
