--Review the data structure
select * from campaigns

--UNDERSTAND THE DATA

SELECT COUNT(*) FROM campaigns
--There are about 200,000 record in the data

SELECT count(*) as column_count
      from information_schema.columns 
	  where table_name = 'campaigns';
-- There are about 16 coulumns in the dataset

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
      FROM information_schema.columns
	  WHERE table_name = 'campaigns';
	  
--Examine each categorical variable in the dataset and identify the unique values within each
select distinct(company_name)
from campaigns;

select distinct(campaign_type)
from campaigns;

select distinct(target_audiences)
from campaigns;

select distinct(channel_used)
from campaigns;

select distinct(location)
from campaigns;

select distinct(language)
from campaigns;

select distinct(customer_segment)
from campaigns;

--IDENTIFY IF THERE IS EXISTENCE OF NULL VALUES AND CLEAN THE DATA	  
-- Check for null values 
SELECT 
    SUM(CASE WHEN Campaign_ID IS NULL THEN 1 ELSE 0 END) AS null_campaign_id,
    SUM(CASE WHEN Company_name IS NULL THEN 1 ELSE 0 END) AS null_company,
    SUM(CASE WHEN Campaign_Type IS NULL THEN 1 ELSE 0 END) AS null_campaign_type,
    SUM(CASE WHEN Target_Audiences IS NULL THEN 1 ELSE 0 END) AS null_target_audience,
    SUM(CASE WHEN Duration IS NULL THEN 1 ELSE 0 END) AS null_duration,
    SUM(CASE WHEN Channel_Used IS NULL THEN 1 ELSE 0 END) AS null_channel_used,
    SUM(CASE WHEN Conversion_Rate IS NULL THEN 1 ELSE 0 END) AS null_conversion_rate,
    SUM(CASE WHEN Acquisition_Cost IS NULL THEN 1 ELSE 0 END) AS null_acquisition_cost,
    SUM(CASE WHEN ROI IS NULL THEN 1 ELSE 0 END) AS null_roi,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN Language IS NULL THEN 1 ELSE 0 END) AS null_language,
    SUM(CASE WHEN Clicks IS NULL THEN 1 ELSE 0 END) AS null_clicks,
    SUM(CASE WHEN Impressions IS NULL THEN 1 ELSE 0 END) AS null_impressions,
    SUM(CASE WHEN Engagement_Score IS NULL THEN 1 ELSE 0 END) AS null_engagement_score,
    SUM(CASE WHEN Customer_Segment IS NULL THEN 1 ELSE 0 END) AS null_customer_segment,
    SUM(CASE WHEN Date IS NULL THEN 1 ELSE 0 END) AS null_date
FROM 
    campaigns;
	--This depicts that there is null values in the data.
	
	
-- Convert 'duration' column to numeric by extracting the number of days	
update campaigns
      set duration = REGEXP_REPLACE(duration, 'days$', '', 'i');

ALTER TABLE campaigns
ALTER COLUMN duration TYPE INTEGER using duration :: INTEGER;

-- To confirm	
select duration
      from campaigns; --The data type has been converted to integer
	  
-- I decided to do some feature engeneering so the targeting can be broader. 		   
--To add 'Gender_Target' column
ALTER TABLE campaigns
ADD COLUMN Gender_Target TEXT 

UPDATE campaigns
SET Gender_Target = case 
	                when target_audiences like '%Men%' Then 'Men'
	                when target_audiences like '%Women%' Then 'Women'
		            else 'Both'
		            end;
--Too confirm					
select target_audiences, Gender_Target
      from campaigns;					

select * from campaigns


--CAMPAIGN ANALYSIS
--1. Which campaign type yield the highest conversion_rate

SELECT 
    campaign_type, 
    COUNT(*) AS most_used, 
    AVG(conversion_rate) AS most_effective
FROM 
    campaigns
GROUP BY 
    campaign_type
ORDER BY 
    most_effective DESC;
--influencer ads is the most used and the most effective in terms of conversion. Influencer ads performed the most	

--2. How does the performance of the campaign vary by companies
select company_name,
       avg(conversion_rate) as average_conversion,
	   avg(roi) as average_roi, 
	   sum(clicks) as total_clicks,
	   sum(impressions) as total_impressions,
	   avg(engagement_score) as avg_engagement_score
from campaigns
group by company_name
order by average_conversion desc

--3 Is there a correlation between duration of a campaign and it conversion rate or roi

select 
  corr(duration, conversion_rate)
  from campaigns;
  --It shows that there is a negative relationship between duration and conversion
  
select 
  corr(duration, roi)
  from campaigns; 
  --It shows that there is a slightly positive relationship between duration and conversion

/* It's crucial to emphasize that correlation does not imply causation. 
A negative correlation between duration and conversion rate or ROI does not mean that increasing the duration 
will directly or automatically lead to low performance.There are several potential confounding factors that could 
influence both duration and the outcome metrics, such as: channel used, campaign_type, target audiences and so on.*/ 
	   
select channel_used,
  corr(duration, conversion_rate) as duration_conversion, 
  corr(duration, roi) as duration_roi
  from campaigns
  group by channel_used
  
/* As you can see, the correlation between duration and conversion is negative which also shows 
a negative return on investment for email ads. But as for Google ads, there is a positive correlation between
duration of the campaign and conversion rate which shows a slightly positive return on investment. 

Let also consider other factors*/

select target_audiences,
  corr(duration, conversion_rate) as duration_conversion, 
  corr(duration, roi) as duration_roi
  from campaigns
  group by target_audiences
  
select campaign_type,
  corr(duration, conversion_rate) as duration_conversion, 
  corr(duration, roi) as duration_roi
  from campaigns
  group by campaign_type
/* As the result shows, there are scenarios where duration of a campaign type depicts a negative conversion rate.
Such as the Display campaign type and Email ads. Whereas, there are scenarios where duration of a campaign type
depicts a negative conversion rate. Such as Influencer ads, Search ads, Socia Media ads*/


--4 How does the campaign type impact conversion rate and roi across the customer segment.

WITH Campaign_Performance as (select campaign_type,
							         customer_segment,
							         avg(conversion_rate) as average_conversion,
							         avg(roi) as average_roi
							  from campaigns
							  group by campaign_type,
							           customer_segment)
								select campaign_type, 
								       customer_segment, 
									   average_conversion,
									   average_roi
								from Campaign_Performance
								order by average_conversion desc;
								
/* Social media campaign with foodies targeting audience has the highest conversion rate with a return on investment 
of 4.979 percent.Email ads converts better with targeting tech enthusisasts and Influencer ads also work 
better with targeting Tech enthusiasts. */

--AUDIENCE PREFERENCES
--Which target audience yield the highest conversion rate and what is the engagement level?

select target_audiences, 
       avg(conversion_rate) as conversion_rate,
	   avg(engagement_score) as engagement_score
from campaigns 
group by target_audiences
order by 2 desc
/* Targeting the Men between 18-24 converts the most and also has the highest engagemnt level. */

--2. What type of type campaign are most appealing to specific customer segment

select campaign_type,
       customer_segment, 
	   avg(engagement_score) as engagement_score
from campaigns
group by campaign_type,
         customer_segment
order by 3 desc;

/* Display ads are more appealing to the outdoor adventurers audience(People who are passionate about
outdoor activities). Whereas, Email ads are more appealing to Health & Wellness audience. */


--3. Does the language of a campaign have a significant impact on engagement_score in specific location?

select language, 
       avg(engagement_score) as engagement_score
from campaigns 
group by language
order by 2 desc;
--As you can see, German and Mandarin are more appealing to the audience generally. But let's deep dive and see which location.


SELECT                                        
    language, 
	 location,
    AVG(engagement_score) AS avg_engagement_score,   
    AVG(conversion_rate) AS avg_conversion_rate    
FROM 
    campaigns
GROUP BY 
    language,
	 location
ORDER BY 
    avg_engagement_score DESC; 
--A campaign in English performs better in terms of engagement in houston than spanish, french and mandarin. 	
	
--For easier comparison, let's order by both language and location
 SELECT                                        
    language, 
	 location,
    AVG(engagement_score) AS avg_engagement_score,   
    AVG(conversion_rate) AS avg_conversion_rate    
FROM 
    campaigns
GROUP BY 
    language,
	 location
ORDER BY 
    2 asc; 
/* From the results, we can see that Mandarin perfroms better in terms of engagement in Chicago than any other 
language. Spanish perfroms better in terms of engagement in Los Angeles than any other language. Germany performns 
better in terms of engagemnt in miami than any other language. Germany also performns better in terms of 
engagemnt in NewYork than any other language. */


--4. What is the relationship between audience location and campaign sucess?
 select location, 
        AVG(conversion_rate) AS avg_conversion_rate
 from campaigns 
 group by location
 order by 2 desc;
 /* NewYork has the highest conversion rate than any other location.*/
 
 --Let deepdive on which factors within NewYork contribute to its sucess
 SELECT 
    location, 
    campaign_type,
    AVG(conversion_rate) AS avg_conversion_rate,
    AVG(ROI) AS avg_roi
FROM 
    campaigns
	WHERE LOCATION = 'New York'
GROUP BY 
    location, campaign_type
ORDER BY 
    avg_conversion_rate DESC;

/* In New York, Social Media campaign type perform the most in terms of conversion but it does not result in the 
 highest return on investment. Display ads in New York has the highest return on investment.*/


--CHANNEL EFFECTIVESNESS
--1. Which channel are the most effective in driving conversion
select channel_used, 
       avg(conversion_rate) as average_conversion
from campaigns
group by 1
order by 2 desc

/*Email has the highest conversion rate. Now, let's compare it to the acquisition cost. Cost of 
acquiring a customer. We will also compare it with the ROI before making decision*/

--Channel Effectiveness Based on Acquisistion cost
select channel_used, 
       avg(conversion_rate) as average_conversion, 
       avg(acquisition_cost) as average_acquisition_cost,
	   avg(roi) as average_roi
from campaigns
group by channel_used
order by 3 desc;
/* Despite the fact that Email ads has the highest average conversion rate, the cost of acquiring 
 a new customer is high. Though, the return on investment is marginal in comparison to highest
 average conversion rate. Youtube ads has the lowest average cost per acquiring a new customer.*/


/* Let's check the channel performance overtime*/
 with ranked as(select date_trunc('month', date) as month,
                       channel_used,
		               avg(conversion_rate) as average_conversion,
				       Row_Number() over (partition by date_trunc('month', date) Order by avg(conversion_rate) Desc) as rank
                from campaigns
                group by 1, 2)
				select month, channel_used, average_conversion
				from ranked
				where rank <= 2
				order by month, average_conversion desc;
/* This shows the top 2 highest converting channel over the months. As at January, 
Google ads and Facebook ads converted the most*/
                
--What channel has the highest engagement score and how does it translate into conversion?

select channel_used, 
       avg(engagement_score) as average_engagement, 
	   avg(conversion_rate) as average_conversion
	   from campaigns
	   group by 1
	   order by 2 desc;
/* People engage more on the Website than any other channel. It also has an average conversion
 rate of about 8%, which is one of the top conversion rate per channel used.*/
 
-- To deepdive, do specific channels show better performance in particular segment or location in terms of engagement.
select channel_used, 
       customer_segment,
       avg(engagement_score) as average_engagement, 
	   avg(conversion_rate) as average_conversion
 from campaigns
 group by 1, 2
 order by 2, 3 desc;
 /* People engage more on facebook when targeting fashionistas segment. When targeting foodies, 
 people engage more on the website. When targeting health and wellness, People engage more on Youtube ads, 
 People engage more on the website, when targeting outdoors adventures. When targeting Tech 
 enthusiasts, people engage more on instagram compared to other channels.*/
 
 --Let's see if it has better performane in particular location
 select channel_used, 
       location,
       avg(engagement_score) as average_engagement, 
	   avg(conversion_rate) as average_conversion
 from campaigns
 group by 1, 2
 order by 2, 3 desc;
 /*People engage more on the website the most when targeting Chicago and Miami*/
 
 --ROI
 
-- Are campaigns with better engagement score correlated with better roi
select corr(engagement_score, roi)
from campaigns;
--This shows a positive correlation between the engagement of the audiences and the return on investment
--Now, we will check the campaign correlation with the two variables

select campaign_type, 
       corr(engagement_score, roi)
from campaigns 
group by 1
order by 2 desc;
/*Display ads and Influencer ads shows a very slight positive relationship between engagement level of the 
audiences and the return on investment*/

--How about the correlation between conversion rate and roi?

select corr(conversion_rate, roi)
from campaigns;
--This shows a negative correlation between the conversion rate and return on investment
--Now, we will check the campaign correlation with the two variables

select campaign_type, 
       corr(conversion_rate, roi)
from campaigns 
group by 1
order by 2 desc;

/*Display ads and Email ads shows a very slight positive relationship between engagement level of the 
audiences and the return on investment*/

--How does ROI vary between customer segment and location?
select customer_segment, 
       location, 
	   avg(roi) as average_roi
from campaigns
group by 1, 2
order by 3 desc;
/*Foodies segment in Miami has the highest average return on investment followed by tech enthusiasts
in Los Angeles*/
--Let's check how ROI vary independently between customer segment and location

select customer_segment,  
	   avg(roi) as average_roi
from campaigns
group by 1
order by 2 desc;
--Foodies segment stil has the highest average return on investment in general. 

select location,  
	   avg(roi) as average_roi
from campaigns
group by 1
order by 2 desc;
--Miami stil has the highest average return on investment in general compared to all location.

/* How does ROI vary between short & long term campaigns*/
--First, i need the unique duration across all campaigns

select distinct(duration)
from campaigns
/*Now we should hold the fact based on this duration that any campaign that ran for 1-15 days is 
a short term campaign. While campaigns that ran for the 16 days to the 45 days is a mid-term
campaign. While campaigns that ran for 46 days above is a long term campaign.Though,
the maximum number of days a campaign has ran for on this data is 60 days, which is approximately 
2 months.*/

select case 
           when duration > 1 and duration <= 15  then 'Short-term'
		   when duration > 15 and duration <= 45 then 'Mid-term'
		   else 'Long-term'
		   End as Duration, 
		   avg(roi) as average_roi
		   from campaigns
		   group by 1
		   order by 2 desc
/* Short term campaigns has the lowest average return on investment. While Long-term campaigns 
has the highest return on investment. This is to say the longer the campaign, the higher return 
on investment marginally.*/

/*Let'compare the roi to the conversion rate. We are interested in seeing if long term 
duration also lead to higher conversion rate. To understand the impact of campaign duration  
to see if there is anytrade-off between ROI and conversion rate for different durations*/

select 
      case 
           when duration > 1 and duration <= 15  then 'Short-term'
		   when duration > 15 and duration <= 45 then 'Mid-term'
		   else 'Long-term'
		   End as Duration, 
		   avg(roi) as average_roi,
		   avg(conversion_rate) as average_conversion
		   from campaigns
		   group by 1
		   order by 2 desc;

/* Even with the fact that Short-term campaign has the lowest average return on investment, it
has the highest average conversion rate commpared to long and mid-term campaigns. It is shocking 
that the mid-term campaign has higher conversion rate than the long-term campaign.*/


select 
      case 
           when duration > 1 and duration <= 15  then 'Short-term'
		   when duration > 15 and duration <= 45 then 'Mid-term'
		   else 'Long-term'
		   End as Duration, 
		   avg(roi) as average_roi,
		   avg(conversion_rate) as average_conversion, 
		   avg(engagement_score) as avg_engagement
		   from campaigns
		   group by 1
		   order by 2 desc;
		   
/* Short-term campaigns is more engaging and more converting than both mid-term
and long term campaigns even with the fact that short-term campaigns has the lowest ROI	*/

