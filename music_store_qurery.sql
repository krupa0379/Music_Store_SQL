-- Q1: Who is the senior most employee based on job title?

select * from employee
order by levels DESC 
limit 1;

-- Q2: which countries have the most Invoices?

select count(*) as c, billing_country
from invoice
group by billing_country
order by c desc;

-- Q3: what are top 3 values of total invoice?

select total
from invoice
order by total desc 
limit 3;

-- Q4: Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice
-- totals

select billing_city, sum(invoice.total) as total_invoice
from invoice
group by billing_city
order by total_invoice DESC
limit 1

-- Q5: Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total_invoice
from customer 
JOIN invoice  ON (customer.customer_id = invoice.customer_id)
group by customer.customer_id
order by total_invoice desc
limit 1

-- Q6:Write query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting with A

select distinct customer.email, customer.first_name, customer.last_name
from customer 
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
where genre.name LIKE 'Rock'
order by customer.email asc

-- Q.7:Let's invite the artists who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock bands

select artist.artist_id,artist.name, count(track.track_id) as totaltrack_count
from artist 
JOIN album ON (artist.artist_id = album.artist_id )
JOIN track ON (album.album_id = track.album_id)
JOIN Genre ON (track.genre_id = genre.genre_id)
where genre.name LIKE 'Rock'
group by artist.artist_id
order by totaltrack_count desc
limit 10

-- Q.8: Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the
-- longest songs listed first

select name, milliseconds  
from track
where milliseconds > (select avg(milliseconds)
	 					from track ) 
order by milliseconds desc

-- -- Q.9 Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent

with best_selling_artists AS (
	select artist.artist_id, artist.name,sum(invoice_line.unit_price * invoice_line.quantity) as total_spent
from invoice_line 
JOIN track on (invoice_line.track_id = track.track_id)
JOIN album on (track.album_id = album.album_id)
JOIN artist on (album.artist_id = artist.artist_id)
group by artist.artist_id
order by total_spent DESC
Limit 1
)
select customer.customer_Id,customer.first_name,customer.last_name,sum(invoice_line.unit_price * invoice_line.quantity) as total_spent
from customer
JOIN invoice on (customer.customer_id = invoice.customer_id)
JOIN invoice_line ON (invoice.invoice_id = invoice_line.invoice_id)
JOIN track on (invoice_line.track_id = track.track_id)
JOIN album on (track.album_id = album.album_id)
JOIN best_selling_artists on (album.artist_id = best_selling_artists.artist_id)
group by customer.customer_Id,customer.first_name,customer.last_name
order by total_spent desc

-- Q.10 We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query
-- that returns each country along with the top Genre. For countries where the maximum
-- number of purchases is shared return all Genres

with popular_genre as (
	select genre.genre_id, genre.name, customer.country, count(invoice_line.quantity) as max_purchase,
	row_number() over (partition by customer.country order by count(invoice_line.quantity) desc) as p
from customer
JOIN invoice on (customer.customer_id = invoice.customer_id)
JOIN invoice_line ON (invoice.invoice_id = invoice_line.invoice_id)
JOIN track on (invoice_line.track_id = track.track_id)
JOIN Genre on (track.genre_id = genre.genre_id)
Group By genre.genre_id,genre.name, customer.country
order by country, max_purchase desc
)
select*
from popular_genre
where p<=1

-- Q.11 Write a query that determines the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all
-- customers who spent this amount

WITH Customter_with_country AS (
SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
group by customer.customer_id,first_name,last_name,billing_country
ORDER BY billing_country ASC,total_spending DESC)
SELECT * 
FROM Customter_with_country 
WHERE RowNo <= 1;