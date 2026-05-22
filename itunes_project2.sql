use itunes_project;
show tables;
-- =x=x=x=x=x=x=x=x=x=x=x=x=x=x=Who is the senior most employee based on job title?=x=x=x=x=x=x=x=x==x=
select * from employee
order by levels desc
limit 1;

-- =x=x=x=x=x=x=x=x=x=x=x=x==x==x=Which countries have the most Invoices?=x=x=x==x=x=x=x=x=x==x=x=x==x=x==x==x=x==x=x=
select billing_country, count(invoice_id) as this_country
from invoice
group by billing_country
order by this_country desc
limit 1;

-- =x=x=x=x=x=x=x=x=x=x=x=x=x=x=What are top 3 values of total invoice=x=x=x=x=x=x=x=x=x=x=x=x==x=x
select invoice_id, sum(unit_price*quantity) as total_invoice
from invoice_line
group by invoice_id
order by total_invoice desc
limit 3;

-- =x=x=x=x=x=x=x=x==x=x=x=x==x==x=Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals.=x=x=x=x=x=x=x=x=x=x=x=x=x==x=x=x==xx=x=x=x==x=x=x==x==
select billing_city, sum(total) as city_total
from invoice
group by billing_city
order by city_total desc
limit 1;
-- x=x=x=x=x=x==x Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.x=x=x=x=x=x=
select billing_city, sum(total) as have_best_customers
from invoice
group by billing_city
order by have_best_customers desc
limit 1;
-- xx=x=x=x=x=x=x=x=Who is the best customer? The customer who has spent the most money will be declared the best customer.=x=x=x=x=x==x=x=x=x=x=x=

select customer.name, sum(total) as total_revenue
from invoice
join customer on
customer.customer_id = invoice.customer_id
group by customer.name
order by total_revenue desc
limit 1;

-- x=x=x=x=x=x==x=x=Write a query to return the email, first name, last name, & Genre of all Rock Music listeners.

select distinct customer.name, customer.last_name, customer.email, genre.name
from customer
join invoice on
invoice.customer_id = customer.customer_id
join invoice_line on
invoice_line.invoice_id = invoice.invoice_id
join track on 
invoice_line.track_id = track.track_id
join genre on 
genre.genre_id = track.genre_id
where genre.name = 'Rock';
-- x=x=x=x=x=x==x=x=x=x=x==x=x==x Let's invite the artists who have written the most rock music in our dataset. 
-- xx=x=x==x=x=x==x=x=x==x=x=x=x=x= Write a query that returns the Artist name and total track count of the top 10 rock bands.
select artist.name, count(track.track_id) as rock_music
from artist
join album on
album.artist_id = artist.artist_id
join track on 
track.album_id = album.album_id
join genre on
genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.name
order by rock_music desc
limit 10;

-- x=x=x=x=xReturn all the track names that have a song length longer than the average song length. 
-- x=x=x=x=x Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
  SELECT 
    name,
     milliseconds
 FROM track
 WHERE milliseconds > (
     SELECT AVG(milliseconds)
     FROM track
 )

 ORDER BY milliseconds DESC;


-- . Find how much amount spent by each customer on artists. Write a query to return the customer name, artist name, and total spent.

select customer.name, artist.name, sum(invoice_line.unit_price*invoice_line.quantity) as total_spent
from customer 
join invoice on
customer.customer_id = invoice.customer_id
join invoice_line on
invoice.invoice_id = invoice_line.invoice_id
join track on
track.track_id = invoice_line.track_id
join album on
album.album_id = track.album_id
join artist on
album.artist_id = artist.artist_id
group by customer.name, artist.name;
-- We want to find out the most popular music Genre for each country. 
--      We determine the most popular genre as the genre with the highest amount of purchases. 
--      Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared (tie) return all Genres.
select* from (
select invoice.billing_country, genre.name, count(invoice_line.invoice_id) as no_of_purchases, DENSE_RANK() OVER(
  --   PARTITION BY invoice.billing_country
    ORDER BY COUNT(invoice_line.invoice_id) DESC
) as ranking
from track
join genre on
genre.genre_id = track.genre_id
join invoice_line on
track.track_id = invoice_line.track_id
join invoice on 
invoice.invoice_id = invoice_line.invoice_id
group by invoice.billing_country, genre.name
order by no_of_purchases desc ) 
as ranked_genre
where ranking = 1;


-- Q11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount
select* from (
select invoice.billing_country, customer.name, sum(invoice.total) as total_revenue, dense_rank() over(partition by invoice.billing_country order by sum(invoice.total) desc) as highest_spender
from invoice
join customer on
customer.customer_id = invoice.customer_id
group by invoice.billing_country, customer.name
order by total_revenue desc
) as ranked_customers
where highest_spender = 1;


-- =x=x=x=x=x=x=x=x=x=x=x=x= Who are the most popular artists x=x=x=x=x=x=x=x=x=x=x=x=
select* from (
select artist.name, dense_rank() over(order by sum(invoice_line.unit_price*invoice_line.quantity) desc) as highest_earning
from artist
join album on
album.artist_id = artist.artist_id
join track on
album.album_id = track.album_id
join invoice_line on 
invoice_line.track_id = track.track_id
group by artist.name ) as ranked_artist
where highest_earning = 1;

 -- =x=x=x=x=x=x=x=x=x==x=x=x=Which is the most popular song?x=x=x=x=x==x=x=
  select* from (
  select track.name, dense_rank() over(order by sum(invoice_line.quantity) desc) as popularity_rank
  from track 
  join invoice_line on
  invoice_line.track_id = track.track_id
  group by track.name)  as ranked_song
  where popularity_rank = 1;

-- x=x=x=x=x=x=x=x=x=x=x=x=x=x=What are the average prices of different types of music?=x=x=x=x=x=x=x=x=x=x=x=x=x==x=x=x=x=x=x=

select genre.name, avg(track.unit_price) as average_price
from genre
join track on 
genre.genre_id = track.genre_id
group by genre.name;
-- x=x=x=x=x=x=x=x=x=x==x=x=x=x=x==x=x=x=x=x= =x=x=x=x=x=x=x=x=x==x=x=x=x==x=x=x
select * from invoice;
select* from (
select invoice.billing_country, sum(invoice_line.quantity) as total_purchased, dense_rank() over( order by sum(invoice_line.quantity) desc) as most_selled_countries_ranked
from invoice
join invoice_line on
invoice.invoice_id = invoice_line.invoice_id
group by invoice.billing_country
) as most_selled_country
;
