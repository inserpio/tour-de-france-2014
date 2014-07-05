LOAD CSV WITH HEADERS FROM "https://github.com/inserpio/tour-de-france-2014/blob/master/tour-de-france-2014-0001-teams-and-riders.csv" AS csvLine
MERGE (r:Race { id: toInt(csvLine.RACE_ID), name: csvLine.RACE_NAME, from: csvLine.RACE_FROM, to: csvLine.RACE_TO, edition: csvLine.RACE_EDITION, distance: csvLine.RACE_DISTANCE, number_of_stages: csvLine.RACE_NUMBER_OF_STAGES, website: csvLine.RACE_WEBSITE })
MERGE (t:Team { id: toInt(csvLine.TEAM_ID), name: csvLine.TEAM_NAME, country: csvLine.TEAM_COUNTRY, sportingDirectors: csvLine.TEAM_MANAGERS })
MERGE (p:Rider { name: csvLine.RIDER_NAME, country: csvLine.RIDER_COUNTRY })
CREATE (t)-[:TAKES_PART_IN]->(r)<-[:TAKES_PART_IN { number: toInt(csvLine.RIDER_NUMBER), info: csvLine.RIDER_INFO }]-(p), (p)-[:RIDES_FOR { year: toInt(csvLine.RACE_YEAR) }]->(t)
RETURN t,r,p;

LOAD CSV WITH HEADERS FROM "https://github.com/inserpio/tour-de-france-2014/blob/master/tour-de-france-2014-0002-stages.csv" AS csvLine
MATCH (r:Race { id: 1 })
MERGE (s:Stage { name: csvLine.STAGE_START + " / " + csvLine.STAGE_FINISH, number: toInt(csvLine.STAGE_NUMBER), type: csvLine.STAGE_TYPE, date: csvLine.STAGE_DATE, distance: toFloat(csvLine.STAGE_DISTANCE), info: csvLine.STAGE_INFO})
MERGE (cs: City { name: csvLine.STAGE_START, country: csvLine.STAGE_START_COUNTRY, lat: toFloat(csvLine.STAGE_START_LATITUDE), lon: toFloat(csvLine.STAGE_START_LONGITUDE) })
MERGE (cf: City { name: csvLine.STAGE_FINISH, country: csvLine.STAGE_FINISH_COUNTRY,  lat: toFloat(csvLine.STAGE_FINISH_LATITUDE), lon: toFloat(csvLine.STAGE_FINISH_LONGITUDE) })
CREATE (s)-[:IS_A_STAGE_OF]->(r), (s)-[:STARTS_FROM]->(cs), (s)-[:FINISH_AT]->(cf)
RETURN r,s,cs,cf;

LOAD CSV WITH HEADERS FROM "https://github.com/inserpio/tour-de-france-2014/blob/master/tour-de-france-2014-0003-climbs.csv" AS csvLine
MATCH (s:Stage { number: toInt(csvLine.STAGE_NUMBER) })
CREATE (s)-[:INCLUDES]->(c:Climb { startingAtKm: toFloat(csvLine.STARTING_AT_KM), name: csvLine.NAME, initialAltitude: toFloat(csvLine.INITIAL_ALTITUDE), averageSlope: toFloat(csvLine.AVERAGE_SLOPE), distance: toFloat(csvLine.DISTANCE), category: csvLine.CATEGORY })
RETURN s,c;

LOAD CSV WITH HEADERS FROM "https://github.com/inserpio/tour-de-france-2014/blob/master/tour-de-france-2014-0004-intermediate_sprints.csv" AS csvLine
MERGE (c:City { name: csvLine.CITY, country: csvLine.COUNTRY, lat: toFloat(csvLine.LATITUDE), lon: toFloat(csvLine.LONGITUDE) })
WITH c, csvLine
MATCH (s:Stage { number: toInt(csvLine.STAGE_NUMBER) })
CREATE (s)-[:INCLUDES]->(i:IntermediateSprint { atKm: toFloat(csvLine.AT_KM) })-[:TAKES_PLACE_IN]->(c)
RETURN s,i;
