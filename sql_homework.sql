# Homework Assignment
/*
* 1a. Display the first and last names of all actors from the table `actor`.
*/
-- use sakila;
select 
	a.first_name,
	a.last_name
from sakila.actor a 
;

/*
* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
*/
select 
	concat(a.first_name,' ',a.last_name) as 'Actor Name'
from sakila.actor a 
;

/*
* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
*/

select 
	a.actor_id,
    a.first_name,
    a.last_name
from sakila.actor a 
where a.first_name = 'joe'
;

/*
* 2b. Find all actors whose last name contain the letters `GEN`:
*/

select concat(a.first_name,' ',a.last_name) as 'Actor Name'
from sakila.actor a
where a.last_name like '%gen%'
;
/*
* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
*/

select 
	concat(a.first_name,' ',a.last_name) as 'Actor Name'
from sakila.actor a
where a.last_name like '%li%'
order by 
	a.last_name,
    a.first_name
;
/*
* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
*/

select 
	c.country_id,
    c.country
from sakila.country c
where c.country in ('Afghanistan','Bangladesh','China')
;

/*
* 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
*/

alter table sakila.actor
add middle_name varchar(45) AFTER first_name
;
/*
* 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
*/

alter table sakila.actor
modify middle_name blob
;

/*
* 3c. Now delete the `middle_name` column.
*/

alter table sakila.actor 
drop column middle_name
;

/*
* 4a. List the last names of actors, as well as how many actors have that last name.
*/

select 
	a.last_name,
    count(*)
from sakila.actor a
group by
	a.last_name
;
/*
* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
*/

select 
	a.last_name,
    count(*)
from sakila.actor a
group by
	a.last_name
having count(*)>1
;

/*
* 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, 
the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
*/


update sakila.actor
set first_name = 'HARPO'  
where first_name = 'groucho'
	and last_name = 'williams'
;
	-- to check
-- select first_name, last_name from sakila.actor where last_name = 'williams'

/*
* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
It turns out that `GROUCHO` was the correct name after all! 
In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. 
Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. 
BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
*/
update sakila.actor
set first_name = 'GROUCHO'  
where actor_id = 172
;
/*
* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
NOTE:
i need to figure out what's going on after phone 
*/

use sakila;
CREATE TABLE address (
  address_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT UNSIGNED NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  /*!50705 location GEOMETRY NOT NULL,*/
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (address_id),
  KEY idx_fk_city_id (city_id),
  /*!50705 SPATIAL KEY `idx_location` (location),*/
  CONSTRAINT `fk_address_city` FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*
  * Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
*/


/*
* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
*/

select 
	s.first_name,
    s.last_name,
    ad.address
from sakila.staff s 
	left join sakila.address ad  -- in case we don't have address for every staff memeber
		on s.address_id = ad.address_id
;
/*
* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
*/

select 
	s.first_name,
    s.last_name,
    sum(p.amount) as sum_payment
from sakila.staff s
	inner join sakila.payment p 
		on s.staff_id = p.staff_id
where p.payment_date between '2005-08-01 00:00:00' and '2005-08-31 23:59:59'
group by
	s.first_name,
    s.last_name
;
/*
* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
*/

select 
	f.title,
    count(fa.actor_id) as count_actor
from sakila.film_actor fa
	inner join sakila.film f 
		on fa.film_id = f.film_id
group by
	f.title

;
/*
* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
*/

select 
	f.title,
    count(*)
from sakila.film f
	inner join sakila.inventory i
		on f.film_id = i.film_id
where f.title = 'hunchback impossible'
group by
	f.title
;

/*
* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
List the customers alphabetically by last name:
*/

select 
	c.first_name,
    c.last_name,
    sum(p.amount) as 'total paid'
from sakila.customer c
	left join sakila.payment p
		on c.customer_id = p.customer_id
group by 
	c.first_name,
    c.last_name
order by
	c.last_name
        
;

/*
* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
*/

select 
	f.title,
    lg.language
from sakila.film f 
	inner join 
		(
		select 
			l.language_id,
            l.name as language
        from sakila.language l
        where l.name = 'english'
        ) lg
        on f.language_id = lg.language_id
where f.title like 'k%'
	or f.title like 'q%'
;

/*
* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
*/

select 
	fd.title,
    a.first_name,
    a.last_name
from sakila.actor a
	inner join
	(
	select 
		fa.actor_id,
		fi.film_id,
		fi.title
	from sakila.film_actor fa
		inner join 
		(
		select 
			f.film_id,
			f.title
		from sakila.film f
		where f.title = 'alone trip'
		) fi
			on fa.film_id = fi.film_id
	)fd
		on a.actor_id = fd.actor_id
;

/*
* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
of all Canadian customers. Use joins to retrieve this information.
*/

select 
	co.first_name,
    co.last_name,
    co.email,
    cn.country
from sakila.country cn
	inner join sakila.city ct
		on cn.country_id = ct.country_id
	inner join sakila.address ad
		on ct.city_id = ad.city_id
	inner join sakila.customer co 
		on ad.address_id = co.address_id
where cn.country = 'canada'

;

/*
* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as famiy films.
*/

select 
	f.title,
    ct.name
from sakila.category ct
	inner join sakila.film_category fc
		on ct.category_id = fc.category_id
	inner join sakila.film f
		on fc.film_id = f.film_id
where ct.name = 'family'

;

/*
* 7e. Display the most frequently rented movies in descending order.
*/


select 
	f.title,
    count(r.rental_id) as rental_count
from sakila.rental r
	inner join sakila.inventory i
		on r.inventory_id = i.inventory_id
	inner join sakila.film f
		on i.film_id = f.film_id
group by
	f.title
order by 
	count(r.rental_id) desc
;


/*
* 7f. Write a query to display how much business, in dollars, each store brought in.
*/

select 
	s.store_id,
    ad.address,
    concat('$', format(sum(p.amount), 2)) as revenue
from sakila.store s
	inner join sakila.address ad
		on s.address_id = ad.address_id
	inner join sakila.staff st
		on s.store_id = st.store_id
	inner join sakila.payment p
		on st.staff_id = p.staff_id
group by
	s.store_id,
    ad.address
;

/*
* 7g. Write a query to display for each store its store ID, city, and country.
*/

select 
	s.store_id,
    cy.city,
    cn.country
from sakila.store s
	inner join sakila.address ad
		on s.address_id = ad.address_id
	inner join sakila.city cy
		on ad.city_id = cy.city_id
	inner join sakila.country cn
		on cy.country_id = cn.country_id
;
/*
* 7h. List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
*/

select 
	ct.name,
    sum(pm.amount) as revenue
from sakila.category ct
	inner join sakila.film_category fc
		on ct.category_id = fc.category_id
	inner join sakila.inventory i 
		on fc.film_id = i.film_id
	inner join sakila.rental r
		on i.inventory_id = r.inventory_id
	inner join sakila.payment pm
		on r.rental_id = pm.rental_id
group by
	ct.name
order by sum(pm.amount) desc

;


/*
* 8a. In your new role as an executive, you would like to have an easy way of viewing the 
Top five genres by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.
*/

create or replace view top_five_genres as 
select 
	ct.name,
    sum(pm.amount) as revenue
from sakila.category ct
	inner join sakila.film_category fc
		on ct.category_id = fc.category_id
	inner join sakila.inventory i 
		on fc.film_id = i.film_id
	inner join sakila.rental r
		on i.inventory_id = r.inventory_id
	inner join sakila.payment pm
		on r.rental_id = pm.rental_id
group by
	ct.name
order by sum(pm.amount) desc
limit 5
;

/*
* 8b. How would you display the view that you created in 8a?
*/

select *
from top_five_genres;

/*
* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
*/

drop view top_five_genres;

/*
## Appendix: List of Tables in the Sakila DB
*/


/*
* A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

```sql
	'actor'
	'actor_info'
	'address'
	'category'
	'city'
	'country'
	'customer'
	'customer_list'
	'film'
	'film_actor'
	'film_category'
	'film_list'
	'film_text'
	'inventory'
	'language'
	'nicer_but_slower_film_list'
	'payment'
	'rental'
	'sales_by_film_category'
	'sales_by_store'
	'staff'
	'staff_list'
	'store'
```

## Uploading Homework

* To submit this homework using BootCampSpot:

  * Create a GitHub repository.
  * Upload your .sql file with the completed queries.
  * Submit a link to your GitHub repo through BootCampSpot.
*/
