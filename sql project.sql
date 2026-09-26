---Q1.Who is the senior most employee based on job title?
SELECT * FROM employess
ORDER BY DESC
LIMIT 1

---Q2 Which countries have the most invoices?
SELECT COUNT (*) AS C,billing_country
FROM invoice
GROUP BY billing_city
ORDER BY C DESC

---Q3.What are top 3 values of total invoice?
SELECT * FROM invoice
ORDER BY total DESC
LIMIT 1

---Q4.Which city has the best customers? We would like to throw a promotional Music Festival in the
----city we made the most money. Write a query that returns one city that has the highest sum of
---invoice totals. Return both the city name & sum of all invoice totals.

SELECT SUM(total) AS TOTAL_INVOICE, billing_city FROM INVOICE
GROUP BY billing_city
ORDER BY TOTAL_INVOICE DESC
LIMIT 1

---Q5.Who is the best customer? The customer who has spent the most money will be declared the best
---customer. Write a query that returns the person who has spent the most money.

SELECT customer.customer_id ,customer.first_name , customer.last_name , SUM(invoice.total) AS TOTAL
FROM customer
FULL OUTER JOIN invoice
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY TOTAL DESC
LIMIT 1

---Q6: Write query to return the email, first name, last name,& Genre of all Rock Music listeners. 
---Return your list ordered alphabetically by email starting with A.
SELECT DISTINCT email ,first_name , last_name 
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN ( SELECT track_id FROM track 
                    JOIN genre 
					ON genre.genre_id = track.genre_id
                    WHERE genre.name  LIKE 'Rock')
ORDER BY email

---Q7:Let's invite the artists who have written the most rock music in our dataset.
---Write a query that returns the Artist name and total track count of the top 10 rock bands.
SELECT artist.name ,artist.artist_id ,COUNT(artist.artist_id) AS TOTAL
FROM artist JOIN album 
ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY total
LIMIT 10

--Q8 Return all the track names that have a song length longer than the average song length.Return the
--Name and milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT name , milliseconds  FROM track 
   WHERE milliseconds > ( SELECT AVG(milliseconds) as sec_avg FROM track)
ORDER BY milliseconds DESC

--Q9 Find how much amount is spent by each customer on artists? Write a query to return customer name
--,artist name and total spent.

WITH best_selling AS ( 
SELECT artist.artist_id,artist.name , SUM(invoice_line.quantity*invoice_line.unit_price) AS 
TOTAL_SPENT
FROM invoice_line
JOIN track ON invoice_line.track_id = track.track_id
JOIN album ON  track.album_id = album.album_id
JOIN artist ON album.artist_id = artist.artist_id
GROUP BY artist.artist_id
ORDER BY  TOTAL_SPENT DESC
LIMIT 1
)

SELECT customer.customer_id , customer.first_name,customer.last_name , best_selling.artist_id ,
SUM(invoice_line.quantity*invoice_line.unit_price)
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN album ON  track.album_id = album.album_id
JOIN artist ON album.artist_id = artist.artist_id
JOIN best_selling ON artist.artist_id = best_selling.artist_id
GROUP BY  customer.customer_id ,best_selling.artist_id ,best_selling.TOTAL_SPENT, customer.first_name,
customer.last_name
ORDER BY SUM(invoice_line.quantity*invoice_line.unit_price) DESC
LIMIT 5

--Q10: We want to find out the most popular music Genre for each country.We determine the most 
--popular genre as the genre with the highest amount of purchases. Write a query that returns each 
--country along with the top Genre. For countries where the maximum number of purchases is shared, 
--return all Genres.
WITH HIGH_PURCHASE AS
(
SELECT DISTINCT customer.country, genre.name, count(invoice_line.quantity) AS PURCHASE,
ROW_NUMBER() OVER(PARTITION BY  customer.country ORDER BY count(invoice_line.quantity) DESC)
AS RANK_NUM
FROM genre 
JOIN track ON genre.genre_id = track.genre_id
JOIN invoice_line ON track.track_id = invoice_line.track_id
JOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
JOIN customer ON invoice.customer_id = customer.customer_id
GROUP BY  genre.name,customer.country ,invoice_line.quantity
ORDER BY customer.country ASC ,RANK_NUM ASC, genre.name DESC
)
 SELECT * FROM HIGH_PURCHASE WHERE RANK_NUM =1

--Q11:Write a query that determines the customer that has spent the most on music for each country.
--Write a query that returns the country along with the top customer and how much they spent. For 
--countries where the top amount spent is shared, provide all customers who spent that amount.
WITH TOP_CUSTOMER AS
(
SELECT DISTINCT customer.first_name , customer.last_name,customer.country , playlist.name , 
SUM(invoice_line.unit_price * invoice_line.quantity) AS money_spend ,
ROW_NUMBER() OVER(PARTITION BY  customer.country ORDER BY SUM(invoice_line.unit_price *
invoice_line.quantity) DESC) AS RANK_NUM 
FROM playlist 
JOIN playlist_track ON playlist.playlist_id = playlist_track.playlist_id
JOIN track ON playlist_track.track_id = track.track_id
JOIN invoice_line ON track.track_id = invoice_line.track_id
JOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
JOIN customer ON invoice.customer_id = customer.customer_id
GROUP BY  customer.country ,playlist.name , customer.first_name , customer.last_name
ORDER BY customer.country ASC , RANK_NUM ASC
)

SELECT * FROM TOP_CUSTOMER WHERE rank_num = 1 ORDER BY money_spend DESC

