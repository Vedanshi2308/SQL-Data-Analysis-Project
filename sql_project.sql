-- question set easy level 

-- who is the senior most employee in the company? 
select * from employee
Order by levels desc
limit 1

-- which country has most invoices?
select count(*) as cont, billing_country
from invoice
group by billing_country
order by cont desc  

-- what are top 3 values of invoices?
select total from invoice
order by total desc
limit 3
 
-- Which city has the best customers?
-- We would like to throw a promotional music festival in the city we made the most money.
-- Write a query that return one city that has highest sum of invoice totals.  Return both city name and sum of all invoice totals.

select sum(total) as invoice_total, billing_city from invoice
group by billing_city
order by invoice_total desc

-- Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that return the person who has spent the most money.
select * from customer

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by total desc
limit 1

-- question set moderate level

-- Write query to return email, first_name, Last_name, genre of all rock music listener.
 -- Return your list alphabetically order email starting by a.

select distinct email, first_name, Last_name
from customer
join invoice
on customer.customer_id = invoice.customer_id
join invoice_line 
on invoice.invoice_id = invoice_line.invoice_id
where track_id IN (
                    select track_id from track
                    join genre
                    on track.genre_id = genre.genre_id
                    where genre.name  = 'rock'
				 )
order by email

-- Lets invite artist who have written the most rock music in our dataset. 
-- Write a query that written the artist name and total track count of top 10 rock bands.

Select artist.artist_id, artist.name, count(artist.artist_id) as no_of_songs
from track
join album 
on album.album_id = track.album_id
join artist
on artist.artist_id = album.artist_id
join genre
on genre.genre_id = track.genre_id
where genre.name = 'rock'
group by artist.artist_id, artist.name
order by no_of_songs desc
limit 10

-- Return a track name that have song length longer than avg song length.
-- Return name and milliseconds for each track. Order by song length with longest song listed first.

Select name, milliseconds
from track
where  milliseconds > (
                         select avg(milliseconds) as avg_length
                         from track
                         )
order by milliseconds desc


-- Question set 3 | Advance
-- Find how much amount spend by each customer on artist? 
-- Write a query to return a customer name, artist name and total spent.

with best_selling_artist as
(
select artist.artist_id as artist_id, artist.name as artist_name, sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
from invoice_line
join track
on track.track_id = invoice_line.track_id
join album
on album.album_id = track.album_id
join artist
on artist.artist_id = album.artist_id
group by artist.artist_id, artist.name
order by total_sales desc
limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price * il.quantity) as amount_spent
from invoice i
join customer c
on c.customer_id = i.customer_id
join invoice_line il
on il.invoice_id = i.invoice_id
join track t
on t.track_id = il.track_id
join album alb
on alb.album_id = t.album_id
join best_selling_artist bsa
 on bsa.artist_id = alb.artist_id
 group by customer_id, first_name, Last_name, artist_name
 order by 5 desc;
 
 
 select version();

--  We want to find out most popular genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases.
 -- Write a query that returns each country along with the top genre. 
-- For countries where the maximum number of purchases is shared return all genres.

with popular_genre as (
         select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
         row_number() over(partition by (customer.country) order by count(invoice_line.quantity) desc ) as row_no
         from invoice_line
         join invoice
         on invoice.invoice_id = invoice_line.invoice_id
         join customer
         on customer.customer_id = invoice.customer_id
         join track
         on track.track_id = invoice_line.track_id
         join genre
         on genre.genre_id = track.genre_id
         group by 2,3,4
         order by 2 asc, 1 desc 
         )
select * from popular_genre where row_no = 1
         
         
-- Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.  

with recursive
customer_country as(
     select customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country, sum(total) as Total_spending
     from invoice
     join customer
     on customer.customer_id = invoice.customer_id
     group by 1,2,3,4
     order by 1,5 desc
     ),
country_maxspending as (
			select billing_country, max(Total_spending) as max_spending
            from customer_country
            group by billing_country
            )
            
select cc.billing_country, cc.customer_id, cc.first_name, cc.last_name, cc.Total_spending
from customer_country cc
join country_maxspending cm
on cm.billing_country = cc.billing_country
where cm.max_spending = cc.Total_spending
order by 1
        
         
         
         
	




