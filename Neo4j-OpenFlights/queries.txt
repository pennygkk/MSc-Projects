
--1)
MATCH (a:Airport)
WITH a, SIZE((a)<-[:Departs_from|Arrives_to]-()) as Number_Of_Flights 
RETURN a.name AS Airport, Number_Of_Flights
ORDER BY Number_Of_Flights 
DESC LIMIT 5;

--2)
MATCH (a:Airport)
RETURN a.country AS Country_Name, COUNT(a) AS Number_of_Airports
ORDER BY Number_of_Airports 
DESC LIMIT 5;

--3)
MATCH (a1:Airport)-[:Departs_from]->(r:Route)-[:Arrives_to]->(a2:Airport), (r:Route)-[:Performed_by]->(b:Airline)
WHERE a1.country<>a2.country AND (a1.country='Greece' OR a2.country='Greece')
RETURN b.name AS Airline, COUNT(r) AS Number_of_Flights
ORDER BY Number_of_Flights
DESC LIMIT 5;

--4)
MATCH (a1:Airport)-[r1:Departs_from]->(r:Route)-[:Arrives_to]->(a2:Airport), (r:Route)-[:Performed_by]->(b:Airline)
WHERE(a1.country='Germany' AND a2.country='Germany')
RETURN b.name AS Airline, COUNT(r) AS Number_of_Flights
ORDER BY Number_of_Flights
DESC LIMIT 5;

--5)
MATCH (a1:Airport)-[r1:Departs_from]->(r:Route)-[:Arrives_to]->(a2:Airport)
WHERE(a1.country<>'Greece' AND a2.country='Greece')
RETURN a1.country AS Country, COUNT(r) AS Number_of_Flights
ORDER BY Number_of_Flights
DESC LIMIT 10;

--6)
MATCH (a1:Airport)-[:Departs_from]->(r:Route)-[:Arrives_to]->(a2:Airport)
WHERE a1.country='Greece' OR a2.country='Greece'
WITH COUNT(r) As total
MATCH (a:Airport)-[:Departs_from|Arrives_to]-(r1:Route)
WHERE a.country = 'Greece'
RETURN a.city AS City, 
ROUND(100.0 * COUNT(r1) / total, 2) AS Air_traffic_percentage
ORDER BY Air_traffic_percentage 
DESC;

--7)
MATCH (a1:Airport)-[:Departs_from]->(r:Route)-[:Arrives_to]->(a2:Airport)
WHERE a1.country <> 'Greece' AND a2.country = 'Greece' AND r.equipment in ['738','320']
RETURN r.equipment AS Type, COUNT(r) AS Number_of_Flights;

--8)
MATCH (a1:Airport)-[:Departs_from]->(r:Route)-[:Arrives_to]->(a2:Airport)
WITH point({ longitude: toFloat(a1.longitude), latitude: toFloat(a1.latitude)}) AS p1, point({ longitude: toFloat(a2.longitude), latitude: toFloat(a2.latitude)}) AS p2, a1, a2
RETURN a1.name AS From, a2.name AS To, ROUND(distance(p1,p2)) AS Distance
ORDER BY Distance DESC
LIMIT 5;

--9)
MATCH (a1:Airport)-[:Departs_from]->(r:Route)-[:Arrives_to]->(a2:Airport)
WHERE a2.city = 'Berlin' AND r.stops = '0'
WITH collect(a1.city) AS Cities
MATCH (a1:Airport)-[:Departs_from]->(r:Route)-[:Arrives_to]->(a2:Airport)
WHERE NOT(a1.city IN Cities)
RETURN a1.city AS City, COUNT(r) AS Number_Of_Flights
ORDER BY COUNT(r) DESC
LIMIT 5;

--10)
MATCH p = shortestPath((a1:Airport{city:'Athens'})-[*]-(a2:Airport{city:'Sydney'}))
WHERE NONE(n in nodes(p) WHERE n:Airline) AND a1.country = 'Greece'
RETURN a1.name AS Athens_Airport, a2.name AS Sydney_Airport, length(p) AS Path_Length;

//to return graph showing the shortest paths:
MATCH p = shortestPath((a1:Airport{city:'Athens'})-[*]-(a2:Airport{city:'Sydney'}))
WHERE NONE(n in nodes(p) WHERE n:Airline) AND a1.country = 'Greece'
RETURN p; 
