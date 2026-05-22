use itunes_project;
-- x=x=x=x=x==x=x=x=x= combining first_name and last_name
-- SET SQL_SAFE_UPDATES = 0;
-- UPDATE customer 
-- SET first_name = CONCAT(first_name, ' ', last_name);
-- select * from customer;
-- select c.name, c.customer_id, count(*) as total_invoices
-- from invoice i
-- join customer c on
-- c.customer_id = c.customer_id
-- group by c.name, c.customer_id
-- having count(*) > 1;
-- select c.name, c.customer_id, count(*) as total_invoices
-- from invoice i
-- join customer c on
-- c.customer_id = c.customer_id
-- group by c.name, c.customer_id
-- having count(*) = 1;
-- alter table customer
-- rename column first_name to name;


-- x=x=x=x=x=x=x=x=x= Which customers have spent the most money on music?x=x=x=x=x=x=x=
-- SELECT name, sum(invoice.total) as most_money
-- FROM invoice
-- JOIN customer
-- ON customer.customer_id = invoice.customer_id
-- group by customer.name
-- order by most_money desc
-- limit 1;

SELECT country, MAX(total) AS highest_total
FROM invoice
JOIN customer
ON invoice.customer_id = customer.customer_id
GROUP BY country
ORDER BY highest_total DESC
LIMIT 1;
-- x-x-x-x-xx-x-x-x-x-x-x-Which country generates the most revenue per customer? x-x-x-x-x-x-x-x-x-x-

SELECT 
    name,
    country, 
    SUM(total) AS individual_revenue,
    AVG(SUM(total)) OVER(PARTITION BY country) AS country_avg_revenue_per_customer
FROM invoice 
JOIN customer ON invoice.customer_id = customer.customer_id 
GROUP BY customer.customer_id, name, country
ORDER BY country_avg_revenue_per_customer DESC, individual_revenue DESC;

-- x=x=x=x=x=x=x=x=x==x=x= What is the average customer lifetime value? x=x=x=x=x==x=x=x

SELECT 
    customer.customer_id, 
    customer.name,
    min(invoice_date) as first_purchase,
    MAX(invoice_date) AS last_purchase_date, datediff(max(invoice_date), min(invoice_date)) as difference
FROM customer
JOIN invoice ON
invoice.customer_id = customer.customer_id
group by customer.customer_id , customer.name
HAVING MAX(invoice_date) < NOW() - INTERVAL 6 MONTH
ORDER BY last_purchase_date DESC;



select avg(customer_total) as average_customer_lifetime_value
from( select customer.customer_id, sum(invoice.total) as customer_total
from customer
join invoice on 
invoice.customer_id = customer.customer_id
group by customer.customer_id)
as customer_spending;

-- =================================================================  Sales & Revenue Analysis ==========================================================


--             What are the monthly revenue trends for the last two years?
SELECT 
    YEAR(invoice_date) AS year,
    MONTH(invoice_date) AS month,
    SUM(total) AS monthly_revenue
FROM invoice
WHERE invoice_date >= (
    SELECT DATE_SUB(MAX(invoice_date), INTERVAL 2 YEAR)
    FROM invoice
)
GROUP BY YEAR(invoice_date), MONTH(invoice_date)
ORDER BY year, month;
 -- x=x=x=x=x=x=x=   What is the average value of an invoice (purchase)? x=x=x=x=x=x=x==x
select avg(total) as average_purchase
from invoice;

-- select month(invoice_date) as  month, year(invoice_date) as this_year,
-- sum(total) as total_sales
-- from invoice
-- group by month(invoice_date), year(invoice_date)
-- order by total_sales desc;


-- x=x=x=x=x=x=x=x=x=x=x=x==x==x==x==x==x==x=x==x=x==x=x=x=x=x=x Product & Content Analysis=x=x=x=x=x=x==x===x==x=x==x=x==x==x=x=



-- x=x=x=x==x==xx=x=x=x=x=   What is the average price per track across different genres?
select avg(unit_price) as avg_price, genre.name
from genre
join track on
track.genre_id = genre.genre_id
group by genre.name
order by avg_price desc;
-- x=x=x=x=x=x=x=x==x=x==xx=x=Which tracks generated the most revenue
select SUM(invoice_line.unit_price * invoice_line.quantity) as total_price, track.track_id
from track 
join invoice_line on
invoice_line.track_id = track.track_id
group by track_id
order by total_price desc;
-- x=x=x=x=x=x=x=x=x=x=Which albums or playlists are most frequently included in purchases?
select playlist.name, playlist_track.playlist_id, count(invoice_line.track_id) as numberoftimes
from invoice_line
join playlist_track on 
invoice_line.track_id = playlist_track.track_id
JOIN playlist
ON playlist.playlist_id = playlist_track.playlist_id
group by playlist_track.playlist_id, playlist.name
order by numberoftimes desc;
-- x=x=x=x=x=x=x==x=x=x=Are there any tracks or albums that have never been purchased?
SELECT track.name
FROM track
LEFT JOIN invoice_line
ON track.track_id = invoice_line.track_id
WHERE invoice_line.track_id IS NULL;
-- x=x=x=x=x=x=x==x==x=x=x How many tracks does the store have per genre and how does it correlate with sales
 
select  genre.name, count(track.track_id) as no_of_track
from track
join genre on 
genre.genre_id = track.genre_id
group by genre.name;

select genre.name, genre.genre_id, sum(invoice_line.quantity) as total_qantity_sales
from genre
join track on
track.genre_id = genre.genre_id
join invoice_line on
invoice_line.track_id = track.track_id
group by genre.name, genre.genre_id;

-- =x=x=x=x=x=x=x=x=x==x=x=x==x=x==x=x==x=x=Artist & Genre Performance=x=x=x=x=x==x=x=x==x=
-- x=x=x=x=x==x=x==x=x Who are the top 5 highest-grossing artists?
select a.name, sum(invoice_line.unit_price*invoice_line.quantity) as total_revenue
from artist a
join album on 
a.artist_id = album.artist_id 
join track on
track.album_id = album.album_id
join invoice_line on
invoice_line.track_id = track.track_id 
group by a.name
order by total_revenue desc
limit 5;

-- =x=x=x=x=x==x=x=x=x=x==x=x=x= Which music genres are most popular in terms of: ○ Number of tracks sold  ○ Total revenue =x=x=x=x=x=x==x=x=x=x==x==x=x

select g.name, sum(invoice_line.unit_price*invoice_line.quantity) as total_revenue
from genre g 
join track on 
track.genre_id = g.genre_id
join invoice_line on
invoice_line.track_id = track.track_id
group by g.name
order by total_revenue desc;

select g.name, sum(invoice_line.quantity) as tracks_sold
from genre g 
join track on 
track.genre_id = g.genre_id
join invoice_line on
invoice_line.track_id = track.track_id
group by g.name
order by tracks_sold desc;

-- x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x= Are certain genres more popular in specific countries? =x=x=x=x=x=x==x=x==x=x==x==x=x=x==x=x=x

select c.country, genre.name, sum(invoice_line.quantity) as This_Genre
from customer c
join invoice on 
invoice.customer_id = c.customer_id
join invoice_line on
invoice_line.invoice_id = invoice.invoice_id 
join track on 
track.track_id = invoice_line.track_id
join genre on
track.genre_id = genre.genre_id 
group by c.country, genre.name
order by This_Genre desc;

-- =x=x=x=x=x=x=x=x=x=x=x=x=x=x=Employee & Operational Efficiencyx=x=x=x=x==x=x==x=x=x=x=x=x
-- ------x=x=x=x==xWhich employees (support representatives) are managing the highest-spending customers?x=x=x=x==x 

-- ALTER TABLE employee 
-- ADD COLUMN full_name VARCHAR(255) 
-- GENERATED ALWAYS AS (CONCAT(first_name, ' ', last_name)) STORED;

select e.full_name as employee_name, customer.name, sum(invoice.total) as total_spending
from employee e
join customer on 
customer.support_rep_id = e.employee_id
join invoice on 
invoice.customer_id = customer.customer_id
join invoice_line on
invoice_line.invoice_id = invoice.invoice_id
group by e.full_name, customer.name
order by total_spending desc;

-- x=x=x=x=x=x=x==x=x=x=x==x= What is the average number of customers per employee?x=x=x=x=x=x=x

select e.full_name , count(customer.customer_id) as average_customers
from employee e
join customer on
customer.support_rep_id = e.employee_id
group by e.full_name;

SELECT AVG(total_customers) AS average_customers_per_employee
FROM (
    SELECT 
        COUNT(customer.customer_id) AS total_customers
    FROM employee e
    JOIN customer 
    ON customer.support_rep_id = e.employee_id
    GROUP BY e.employee_id
) AS customer_counts;

-- =x=x=x=x=x=x=x=x=x=x=● Which employee regions bring in the most revenue? =x=x=x==x=x=x===x=x=x=

select e.full_name, e.city, sum(unit_price*quantity) as total_revenue
from employee e
join customer on
customer.support_rep_id = e.employee_id
join invoice on 
invoice.customer_id = customer.customer_id
join invoice_line on
invoice_line.invoice_id = invoice.invoice_id
group by e.full_name, e.city
order by total_revenue desc
limit 1;

-- =x=x=x=x=x=x=x=x=x=x=x=x=  Geographic Trends =x=x=x=x=x=x=x=x=x=x=x==x
Which countries or cities have the highest number of customers?

select country, count(customer.customer_id) as no_of_customers
from customer
group by country 
order by no_of_customers desc;
-- =x=x=x=x=x=x=x=x=x=x=x=x= How does revenue vary by region? =x=x=x=x=x=x=x=x=x=x=x=x=x=
elect c.country, sum(unit_price*quantity) as total_sell_in_country
from customer c
join invoice on
invoice.customer_id = c.customer_id
join invoice_line on
invoice_line.invoice_id = invoice.invoice_id
group by c.country;

-- x=x=x=x=x=x=x=x=x=x= Are there any underserved geographic regions (high users, low sales) x=x=x=x=x=x=x=
select c.country, count(c.customer_id) as no_of_customer, sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
from customer c
join invoice on
invoice.customer_id = c.customer_id 
join invoice_line on
invoice.invoice_id = invoice_line.invoice_id
group by c.country
order by total_sales asc;

-- x=x=x=x=x=x=x=x=x=x=x= Customer Retention & Purchase Patterns =x=x=x=x=x=x=x=x=x=x=
--  -- What is the distribution of purchase frequency per customer?
select c.customer_id, count(invoice.invoice_id) as no_of_times
from customer c
join invoice on
c.customer_id = invoice.customer_id
join invoice_line on
invoice_line.invoice_id= invoice.invoice_id
group by c.customer_id
order by no_of_times desc;

-- =x=x=xx==x=x=x===x=x=x=How long is the average time between customer purchases?x=x=x==x=x==x=x
select customer_id, invoice_date, lead(invoice_date)
over( partition by customer_id order by invoice_date)
as next_purchase,
Datediff(
lead(invoice_date) over(partition by customer_id order by invoice_date), 
invoice_date
) as days_between
from invoice;

-- x=x=x=x==x=x=x==x=x=x=x==x=x=x==x  What percentage of customers purchase tracks from more than one genre? =x=x=x=x=x=x=x==x=x==x=x==x
-- show tables;
select (count(*) *100/(select count(*) from customer)
) as percentage_of_multi_genre_customer
from (
SELECT 
    customer.customer_id,
    customer.name,
    COUNT(DISTINCT genre.genre_id) AS genre_count
from customer
join invoice on
invoice.customer_id = customer.customer_id
join invoice_line on
invoice_line.invoice_id = invoice.invoice_id
join track on
track.track_id = invoice_line.track_id
join genre on
genre.genre_id = track.genre_id
GROUP BY customer.customer_id, customer.name
having genre_count > 1 )
AS multi_genre_customers;

-- =x=x=x=x==x=x=x==x=x=x=x=x=xWhat are the most common combinations of tracks purchased together?x=x=x=x==x=x==x=x=x=x=

select a.track_id as track1, 
b.track_id as track2,
count(*) times_purchased_together
from invoice_line a 
join invoice_line b 
on a.invoice_id = b.invoice_id
and a.track_id < b.track_id
group by a.track_id, b.track_id 
order by times_purchased_together desc;

-- =x=x=x=x==x=x=x=x=x=x=x==x=x=x==x=x=x=x=Are there pricing patterns that lead to higher or lower sales? =x=x=x=x=x=x=x=x=x==x=x=x=x=
-- i can answer this because dataset have same unit_price for every track 


-- =x=x=x=x=x=x==x=x=x==x=x=Which media types (e.g., MPEG, AAC) are declining or increasing in usage?=x=x==x=x==x=x=x=x==x==x=x==x=x=x=

  SELECT 
    media_type.name,
    YEAR(invoice.invoice_date) AS year,
    MONTH(invoice.invoice_date) AS month,
    COUNT(invoice_line.track_id) AS usage_count
FROM media_type
JOIN track 
ON track.media_type_id = media_type.media_type_id
JOIN invoice_line 
ON invoice_line.track_id = track.track_id
JOIN invoice 
ON invoice.invoice_id = invoice_line.invoice_id
GROUP BY 
    media_type.name,
    YEAR(invoice.invoice_date),
    MONTH(invoice.invoice_date)
ORDER BY year, month;

