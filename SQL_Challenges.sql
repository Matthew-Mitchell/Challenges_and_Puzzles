\\How many females and males are in the panel?
SELECT person_demos_final.gender, COUNT(*) FROM person_demos_final GROUP BY gender;

\\How many people are there between (inclusive) the ages of 18 and 25?
SELECT COUNT(*) FROM person)demos_final WHERE age>=18 AND age<=25;

\\How many web visits were there on January 1st 2015?
SELECT COUNT(*) FROM url_final_new WHERE calendar_day='2015-01-01';

\\How many subcategories are on the url_final_new table?
SELECT COUNT(DISTINCT(subcategory)) FROM url_final_new;

\\How many visits are in the travel subcategory in February 2015?
SELECT COUNT(*) FROM url_final_new WHERE calendar_day LIKE '2015-02-..';

\\What is the year over year change in travel for March?
SELECT EXTRACT(YEAR FROM calendar_day), COUNT(*) FROM url_final_new WHERE calendar_day LIKE '....-03-..' GROUP BY EXTRACT(YEAR FROM calendar_day);

\\Do females visit travel sites more than men?
SELECT person_demos_final.gender, count(*) FROM person_demos_final JOIN url_final_new USING(person_id) WHERE url_final_new.category='Travel - Information' GROUP BY person_demos_final.gender;


\\What is the favorite travel site for men? For women?
SELECT url_final_new.domain_name, COUNT(*) FROM url_final_new JOIN person_demos_final ON url_final_new.person_id=person_demos_final.person_id WHERE person_demos_final.gender='F' AND url_final_new.category='Travel - Information' GROUP BY url_final_new.domain_name ORDER BY COUNT(*) DESC LIMIT 20;


\\How many women went to both a travel site and twitter.com?
SELECT COUNT(DISTINCT(person_id)) WHERE url_final_new.person_id IN (SELECT person_id WHERE domain_name='twitter.com' INTERSECT SELECT person_id WHERE category='Travel - Information');

OR similarly:

SELECT COUNT(DISTINCT(person_id)) from url_final_new WHERE person_id IN (SELECT person_id from url_final_new WHERE domain_name='twitter.com') and person_id in (select person_id from url_final_new where category='Travel - Information');

\\What is the first visit date and time at vw.com for 100 random users?
SELECT Search_date FROM search_final WHERE person_id IN (SELECT person_de
d FROM person_demos_final JOIN url_final_new ON person_demos_final.person_id=url_fin WHERE domain_name='vw.com' ORDER BY RANDOM() LIMIT 100) ORDER BY Search_date LIMIT 1;

\\UPDATED:
SELECT url_final_new.person_id, MIN(url_final_new.calendar_day) INTO #TempVW FROM url_final_new JOIN person_demos_final USING(person_id) WHERE person_demos_final.person_id IN(SELECT distinct(person_demos_final.person_id)sele FROM person_demos_final JOIN url_final_new USING(person_id) WHERE url_final_new.domain_name='vw.com' ORDER BY RANDOM() LIMIT 100) GROUP BY url_final_new.person_id;

\\For the 100 random vw users, what is the visit rate to twitter.com?
SELECT COUNT(*) FROM url_final_new WHERE person_id IN (SELECT person_demos_final.person_id FROM person_demos_final JOIN url_final_new USING(person_id) WHERE url_final_new.domain_name='vw.com' ORDER BY RANDOM() LIMIT 100) AND url_final_new.domain_name='twitter.com';

\\Select a random sample of 100 users that did not visit vw.com.
SELECT person_id into #NotVW FROM person_demos_final JOIN url_final_new USING(person_id) WHERE NOT url_final_new.domain_name='vw.com' ORDER BY RANDOM() LIMIT 100;

\\What is the index of visit rates to twitter.com for the vw versus non vw users?
SELECT COUNT(*) FROM url_final_new WHERE person_id IN (SELECT person_demos_final.person_id FROM person_demos_final JOIN url_final_new USING(person_id) WHERE NOT url_final_new.domain_name='vw.com' ORDER BY RANDOM() LIMIT 100) AND url_final_new.domain_name='twitter.com';

\\UPDATED:
select count(*) from url_final_new join #NotVW using(person_id) where url_final_new.domain_name='twitter.com';
select count(*) from url_final_new join #TempVW using(person_id) where url_final_new.domain_name='twitter.com';

\\What is the top site visited prior to the users hitting vw.com?
\\Tmp table; person_id, 1st visit to vw.com (updated and referenced previously)
SELECT url_final_new.person_id, MIN(url_final_new.calendar_day) INTO #TempVW FROM url_final_new JOIN person_demos_final USING(person_id) WHERE person_demos_final.person_id IN(SELECT distinct(person_demos_final.person_id)sele FROM person_demos_final JOIN url_final_new USING(person_id) WHERE url_final_new.domain_name='vw.com' ORDER BY RANDOM() LIMIT 100) GROUP BY url_final_new.person_id;

\\Join this temp table to url_final_new and filter based on when calendar_day<vw visit
\\First attempt; incorrect solution
SELECT url_final_new.domain_name, count(*) FROM url_final_new JOIN #TempVW USING(person_id) WHERE url_final_new.person_id IN (#TempVW.person_id) AND url_final_new.calendar_day< #TempVW.min GROUP BY url_final_new.domain_name ORDER BY COUNT(url_final_new.domain_name) DESC;

\\Updated correct solution using diffdate(time, start, end)
select url_fina_new.domain_name, count(*) from url)final)new join #TempVW using(person_id) wher diffdate(day, url_final_new.calendar_day, #TempVW) < 0 group by url_final_new.domain_name order b count(*) desc;



\\What are the defining demographics of the random 100 vw.com visitors?
\\Could be improved
SELECT * FROM person_demos_final AS p JOIN #TempVW USING(person_id) GROUPBY p.gender, p.age, p.ethnicity;

\\Dataset is huge; generating random samples and testing queries on this limited domain is typically adventageous;
