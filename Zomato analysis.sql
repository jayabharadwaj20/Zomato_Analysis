#Data Cleaning and Conversion:replacing underscores with slashes in Datekey_Opening, which is good for date formatting. Just ensure it's applied correctly.
SET SQL_SAFE_UPDATES = 0;
UPDATE sheet1 SET Datekey_Opening = REPLACE(Datekey_Opening, '_', '/') WHERE Datekey_Opening LIKE '%_%';
alter table sheet1 modify column Datekey_Opening date;
select * from sheet1;

#-----------------------KPI1-----------------------------------------------------
#Build a country Map Table and Currency Map
CREATE TABLE CountryMap (CountryCode INT PRIMARY KEY,CountryName VARCHAR(255));
CREATE TABLE CurrencyMap (
    CountryCode INT,
    Currency VARCHAR(10),
    PRIMARY KEY (CountryCode),
    FOREIGN KEY (CountryCode) REFERENCES CountryMap(CountryCode)
);

-- Insert data into CountryMap
INSERT INTO CountryMap (CountryCode, CountryName)
VALUES (1, 'India'), (14, 'Australia'), (30, 'Brazil'), (37, 'Canada'),
       (94, 'Indonesia'), (148, 'New Zealand'), (162, 'Philippines'), 
       (166, 'Qatar'), (184, 'Singapore'), (189, 'South Africa'),
       (191, 'Sri Lanka'), (208, 'Turkey'), (214, 'United Arab Emirates'), 
       (215, 'United Kingdom'), (216, 'United States of America');

-- Insert data into CurrencyMap
INSERT INTO CurrencyMap (CountryCode, Currency)
VALUES (1, 'INR'), (14, 'AUD'), (30, 'BRL'), (37, 'CAD'),
       (94, 'IDR'), (148, 'NZD'), (162, 'PHP'), 
       (166, 'QAR'), (184, 'SGD'), (189, 'ZAR'),
       (191, 'LKR'), (208, 'TRY'), (214, 'AED'), 
       (215, 'GBP'), (216, 'USD');
 
 
 #-----------------------KPI2-------------------------------------------------
 # Build a Calendar Table using the Column Datekey Add all the below Columns in the Calendar Table using the Formulas.
select year(Datekey_Opening) years,
month(Datekey_Opening)  months,
day(datekey_opening) day ,
monthname(Datekey_Opening) monthname,Quarter(Datekey_Opening)as quarter,
concat(year(Datekey_Opening),'-',monthname(Datekey_Opening)) yearmonth, 
weekday(Datekey_Opening) weekday,
dayname(datekey_opening)dayname, 

case when monthname(datekey_opening) in ('January' ,'February' ,'March' )then 'Q1'
when monthname(datekey_opening) in ('April' ,'May' ,'June' )then 'Q2'
when monthname(datekey_opening) in ('July' ,'August' ,'September' )then 'Q3'
else  'Q4' end as quarters,

case when monthname(datekey_opening)='January' then 'FM10' 
when monthname(datekey_opening)='January' then 'FM11'
when monthname(datekey_opening)='February' then 'FM12'
when monthname(datekey_opening)='March' then 'FM1'
when monthname(datekey_opening)='April'then'FM2'
when monthname(datekey_opening)='May' then 'FM3'
when monthname(datekey_opening)='June' then 'FM4'
when monthname(datekey_opening)='July' then 'FM5'
when monthname(datekey_opening)='August' then 'FM6'
when monthname(datekey_opening)='September' then 'FM7'
when monthname(datekey_opening)='October' then 'FM8'
when monthname(datekey_opening)='November' then 'FM9'
when monthname(datekey_opening)='December'then 'FM10'
end Financial_months,
case when monthname(datekey_opening) in ('January' ,'February' ,'March' )then 'Q4'
when monthname(datekey_opening) in ('April' ,'May' ,'June' )then 'Q1'
when monthname(datekey_opening) in ('July' ,'August' ,'September' )then 'Q2'
else  'Q3' end as financial_quarters

from sheet1;

#-----------------------KPI3-------------------------------------------
#Find the Numbers of Resturants based on City and Country.
SELECT sheet2.`country name`, sheet1.city, COUNT(sheet1.restaurantid) AS no_of_restaurants
FROM sheet1
INNER JOIN sheet2 ON sheet1.countrycode = sheet2.countryID
GROUP BY sheet2.`country name`, sheet1.city;

#-------------------------KPI4----------------------------------------------------------------
#Numbers of Resturants opening based on Year , Quarter , Month.
select year(datekey_opening)year,quarter(datekey_opening)quarter,monthname(datekey_opening)monthname,count(restaurantid)as no_of_restaurants 
from sheet1 group by year(datekey_opening),quarter(datekey_opening),monthname(datekey_opening) 
order by year(datekey_opening),quarter(datekey_opening),monthname(datekey_opening) ;

#-------------------------KPI5---------------------------------------------------------
#Count of Resturants based on Average Ratings.
select case when rating <=2 then "0-2" when rating <=3 then "2-3" 
when rating <=4 then "3-4" when Rating<=5 then "4-5" end rating_range,count(restaurantid) 
from sheet1 
group by rating_range 
order by rating_range;

#-------------------------KPI6--------------------------------------------------------------
#Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
select case when price_range=1 then "0-500" when price_range=2 then "500-3000" when Price_range=3 then "3000-10000"
 when Price_range=4 then ">10000" end price_range,count(restaurantid)
from sheet1 
group by price_range
order by Price_range;

#--------------------------KPI7----------------------------------------------------------------------
#Percentage of Resturants based on "Has_Table_booking"
SELECT 
    has_table_booking, 
    CONCAT(ROUND(COUNT(has_table_booking) * 100.0 / (SELECT COUNT(*) FROM sheet1), 1), '%') AS percentage 
FROM sheet1 
GROUP BY has_table_booking;


#-----------------------------KPI8----------------------------------------------------------------------
#8.Percentage of Resturants based on "Has_Online_delivery"
SELECT 
    has_online_delivery, 
    CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM sheet1), 1), '%') AS percentage 
FROM sheet1 
GROUP BY has_online_delivery;

#-----------------------------KPI9---------------------------------------------------------------------------
#Develop Charts based on Cusines, City, Ratings
# top 5 restaurants who has more number of votes
select  `country name`,restaurantname,votes,Average_Cost_for_two from sheet1 inner join sheet2 on sheet1.`countrycode`=sheet2.countryid
group by sheet2.`country name`,restaurantname,votes,Average_Cost_for_two
order by votes desc limit 5;

# top restaurant with highest rating and votes from each country
SELECT 
    sheet2.`country name`,
    sheet1.restaurantname,MAX(sheet1.rating) AS highest_rating,MAX(sheet1.votes) AS max_votes
FROM sheet1
INNER JOIN sheet2 ON sheet1.`countrycode` = sheet2.countryid
GROUP BY sheet2.`country name`, sheet1.restaurantname
ORDER BY max_votes DESC
LIMIT 5;

#-------------------------
SELECT 
  SUBSTRING_INDEX(cuisines, ',',1) AS split
FROM sheet1;

SELECT restaurantname,
  cuisines,SUBSTRING_INDEX(cuisines, ',',1) AS split,SUBSTRING_INDEX(cuisines, ',',2) AS split,
  SUBSTRING_INDEX(cuisines, ',',1) 
FROM sheet1;

#---How does this query handle cases where the cuisines column contains fewer than three comma-separated values
SELECT 
  restaurantname, cuisines,
  SUBSTRING_INDEX(cuisines, ',', 1) AS cuisine1,
  SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ',', 2), ',', -1) AS cuisine2,
SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ',', 3), ',', -1) AS cuisine3
FROM sheet1;
