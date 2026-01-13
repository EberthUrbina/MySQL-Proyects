-- ¿Qué géneros son más prevalentes en la base de datos NetflixDB? 
-- Genera una lista de los distintos géneros y la cantidad de series por cada uno.

select genero, count(genero) count_genero
from series
group by genero
order by count_genero desc;

-- Esta consulta SQL nos permite ver cuántas series hay en cada género dentro de la base de datos NetflixDB. 
-- Agrupando las series por su género y contándolas, podemos identificar cuáles géneros son más prevalentes.



-- ¿Cuáles son las tres series con mayor rating IMDB y cuántos episodios tienen? 
-- Considera usar un JOIN para combinar la información de las tablas de series y episodios.

select s.titulo, count(e.episodio_id) as count_episodio, avg(e.rating_imdb) as avg_episodio
from series s
inner join episodios e
on s.serie_id = e.serie_id
group by s.serie_id
order by avg_episodio desc
limit 3;


-- Con esta consulta, identificamos las tres series con el mayor rating IMDB 
-- en la base de datos y contamos cuántos episodios tiene cada una de ellas, combinando información de las tablas Series y Episodios.



-- ¿Cuál es la duración total de todos los episodios para la serie "Stranger Things"? 
-- Este análisis te permitirá entender el compromiso temporal necesario para ver una serie completa.

select s.titulo, sum(e.duracion) as suma_total from episodios e
join series s
on s.serie_id = e.serie_id
where s.titulo like "Stranger Things"
group by s.titulo;

-- esta consulta me trae la suma total de la duracion de todos los episodios en la serie "Stranger Things"
