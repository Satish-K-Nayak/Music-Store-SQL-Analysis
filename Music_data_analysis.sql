-- 01>Who is the senior most employee based on job title?
select first_name,last_name from employee
order by levels desc
limit 1;


-- 02>Which countries have the most Invoices?
select count(*) as c,billing_country from invoice
group by billing_country
order by c desc


-- 03>What are top 3 values of total invoice?
select total From invoice
order by total desc
limit 3


-- 04>Which city has the best customers? We would like to throw a 
-- promotional Music Festival in the city we made the most money.
-- Write a query that returns one city that has the highest sum of 
-- invoice totals. Return both the city name & sum of all invoice totals
select billing_city as city,sum(total) as total_billing from invoice
group by city
order by total_billing desc
limit 1



-- 05>Who is the best customer? The customer who has spent the most money will
-- be declared the best customer. Write a query that returns the person who
-- has spent the most money.
select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as Billing
from customer join invoice
on customer.customer_id=invoice.customer_id
Group by customer.customer_id
Order by Billing desc
limit 1


-- 06>Write query to return the email, first name, last name, & Genre of all
-- Rock Music listeners. Return your list ordered alphabetically by email
-- starting with A
Select Distinct customer.email,customer.first_name,customer.last_name
	from customer join invoice 
on customer.customer_id=invoice.customer_id
	join invoice_line on invoice.invoice_id=invoice_line.invoice_id
	Where track_id IN(
select track.track_id from track
join genre on track.genre_id=genre.genre_id
Where genre.name = 'Rock')
order by email;



-- 07>Lets invite the artists who have written the most rock music in our 
-- dataset. Write a query that returns the Artist name and total track count
-- of the top 10 rock bands
select artist.artist_id,artist.name,count(artist.artist_id) as count
from artist join album on artist.artist_id=album.artist_id
join track on album.album_id=track.album_id
join genre on track.genre_id=genre.genre_id
Where genre.name = 'Rock'
group by artist.artist_id
order by count desc
limit 10;



-- 08>Return all the track names that have a song length longer than
-- the average song length. Return the Name and Milliseconds for each track.
-- Order by the song length with the longest songs listed first.
Select name,milliseconds as song_length From track
	Where milliseconds > 
(Select (Sum(milliseconds)/count(*)) as Average_time from track)
Order by milliseconds desc



-- 09>Which customers have spent the most on tracks by the best-selling
--  artist, and how much have they spent? Write a
-- query to return customer name, artist name and total spent.
	With best_selling_artist AS 
	(select artist.artist_id,artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity)
from invoice_line join track on 
invoice_line.track_id=track.track_id
join album on track.album_id=album.album_id
join artist on album.artist_id=artist.artist_id
group by 1
order by 3 desc limit 1)

select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as total_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on il.track_id=t.track_id
join album al on al.album_id=t.album_id
join best_selling_artist bsa on al.artist_id=bsa.artist_id
group by 1,2,3,4
order by 5 desc;



-- 10>We want to find out the most popular music Genre for each country.
-- We determine the most popular genre as the genre with the highest
-- amount of purchases. Write a query that returns each country along with
-- the top Genre. For countries where the maximum number of purchases 
-- is shared return all Genres.
with popular_genre as (select Count(invoice_line.quantity) as Total_purchase,
customer.country, genre.name, genre.genre_id,
row_number() over(partition by customer.country order by
	Count(invoice_line.quantity) desc) as Row_no
from invoice_line join invoice
on invoice_line.invoice_id=invoice.invoice_id
join customer on invoice.customer_id=customer.customer_id
join track on invoice_line.track_id=track.track_id
join genre on track.genre_id=genre.genre_id
group by 2,3,4
order by 2 asc, 1 desc)

select * from popular_genre where row_no<=1


-- 11>Write a query that determines the customer that has spent the most
-- on music for each country. Write a query that returns the country along
-- with the top customer and how much they spent. For countries where the
-- top amount spent is shared, provide all customers who spent this amount.
With customer_with_country AS 
(select c.customer_id,c.first_name,c.last_name,i.billing_country as country,
	sum(i.total) as total_spent,
	row_number() over(partition by i.billing_country order by sum(i.total) desc) as Row_no
	from invoice i
	join customer c on i.customer_id=c.customer_id
	group by 1,2,3,4
	order by 4, 5 desc)

select * from customer_with_country where row_no <= 1;
















