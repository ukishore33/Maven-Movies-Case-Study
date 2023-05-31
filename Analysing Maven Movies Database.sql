-- MANDATORY PROJECT OF SQL BY U KISHORE DS22 BATCH --

-- Write a SQL query to count the number of characters except the spaces for each actor. Return first 10 actors name length along with their name.

SELECT  LENGTH(concat(first_name,last_name)) AS NameLength,  concat(first_name,' ',last_name) as fullname 
FROM mavenmovies.actor 
ORDER BY NameLength DESC 
LIMIT 10;

-- List all Oscar awardees(Actors who received Oscar award) with their full names and length of their names.

select concat(first_name,' ',last_name) 
as "Oscar Awardees" ,length(concat(first_name,' ',last_name)) as 'Length of Names'
from mavenmovies.actor_award
where awards like '%oscar%';

-- Find the actors who have acted in the film ‘Frost Head’.

select concat(first_name,' ',last_name) as 'Actor of film Frost Head'
from mavenmovies.actor a 
join mavenmovies.film_actor m on a.actor_id=m.actor_id 
join mavenmovies.film f on m.film_id=f.film_id
where f.title like '%frost%head%';

-- Pull all the films acted by the actor ‘Will Wilson’.

select f.title as 'Actor-Film Will Wilson'
from mavenmovies.actor a 
join mavenmovies.film_actor m on a.actor_id=m.actor_id 
join mavenmovies.film f on m.film_id=f.film_id 
where a.first_name like '%will%' and a.last_name like '%wilson%';

-- Pull all the films which were rented and return in the month of May.

select f.title as 'Rented and Returned in May'
from mavenmovies.rental r 
join mavenmovies.inventory i on r.inventory_id=i.inventory_id 
join mavenmovies.film f on i.film_id=f.film_id 
where r.rental_date like '__05_______________' and r.return_date like '__05_______________';

-- Pull all the films with ‘Comedy’ category.

select f.title as 'Comedy Category Movies'
from mavenmovies.film f 
join mavenmovies.film_category m on f.film_id=m.film_id
join mavenmovies.category c on m.category_id=c.category_id
where c.name = 'comedy';
