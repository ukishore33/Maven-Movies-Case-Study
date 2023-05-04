SELECT  LENGTH(concat(first_name,last_name)) AS NameLength,  concat(first_name,' ',last_name) as fullname 
FROM mavenmovies.actor 
ORDER BY NameLength DESC 
LIMIT 10;
select concat(first_name,' ',last_name) 
as "Oscar Awardees" ,length(concat(first_name,' ',last_name)) as 'Length of Names'
from mavenmovies.actor_award
where awards like '%oscar%';
select concat(first_name,' ',last_name) as 'Actor of film Frost Head'
from mavenmovies.actor a 
join mavenmovies.film_actor m on a.actor_id=m.actor_id 
join mavenmovies.film f on m.film_id=f.film_id
where f.title like '%frost%head%';
select f.title as 'Actor-Film Will Wilson'
from mavenmovies.actor a 
join mavenmovies.film_actor m on a.actor_id=m.actor_id 
join mavenmovies.film f on m.film_id=f.film_id 
where a.first_name like '%will%' and a.last_name like '%wilson%';
select f.title as 'Rented and Returned in May'
from mavenmovies.rental r 
join mavenmovies.inventory i on r.inventory_id=i.inventory_id 
join mavenmovies.film f on i.film_id=f.film_id 
where r.rental_date like '__05_______________' and r.return_date like '__05_______________';
select f.title as 'Comedy Category Movies'
from mavenmovies.film f 
join mavenmovies.film_category m on f.film_id=m.film_id
join mavenmovies.category c on m.category_id=c.category_id
where c.name = 'comedy';
