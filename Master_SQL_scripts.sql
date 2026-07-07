-- ===================================
-- StreamPulse Churn Analysis Project
-- Author: D. V. Nihitha
-- Database: streampulse
-- Purpose:
-- Churn Analysis
-- Retention Analysis
-- CLV Analysis
-- High Risk User Identification
-- ===================================
USE streampulse_db;

SELECT
COUNT(*) AS total_rows,
COUNT(minutes_watched) AS non_null_minutes,
COUNT(*) - COUNT(minutes_watched) AS null_minutes
FROM fact_streampulse_activity_cleaned;

SELECT *
FROM fact_streampulse_activity_cleaned
WHERE minutes_watched IS NULL;

SELECT

ROUND(
100 *
(COUNT(*) - COUNT(minutes_watched))
/
COUNT(*),
2
) AS missing_percentage

FROM fact_streampulse_activity_cleaned;

SELECT *
FROM fact_streampulse_activity_cleaned
WHERE minutes_watched < 0;

SELECT *
FROM fact_streampulse_activity_cleaned
WHERE minutes_watched = 0;

SELECT

MIN(minutes_watched) AS min_watch,

MAX(minutes_watched) AS max_watch,

AVG(minutes_watched) AS avg_watch

FROM fact_streampulse_activity_cleaned;

SELECT *
FROM dim_date_cleaned
LIMIT 10;

DESCRIBE dim_date_cleaned;

CREATE VIEW dim_date_clean AS

SELECT

date_key,

STR_TO_DATE(
full_date,
'%Y-%m-%d'
) AS full_date,

day,
month,
month_name,
quarter,
year,
day_of_week,
week_number,
weekend_flag,
is_holiday

FROM dim_date_cleaned;


SELECT *
FROM dim_date_cleaned
LIMIT 5;

SELECT
activity_key,
COUNT(*)
FROM fact_streampulse_activity_cleaned
GROUP BY activity_key
HAVING COUNT(*) > 1;

CREATE VIEW fact_activity_clean AS
SELECT *
FROM fact_streampulse_activity_cleaned
WHERE
minutes_watched IS NOT NULL
AND engagement_score IS NOT NULL;

USE streampulse_db;

SELECT DISTINCT subscription_event_type
FROM fact_streampulse_activity_cleaned;

-- Monthly churn rate
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT f.user_key) AS churned_users

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key = d.date_key

WHERE f.subscription_event_type = 'Cancellation'

GROUP BY
    d.year,
    d.month,
    d.month_name

ORDER BY
    d.year,
    d.month;
    
    
-- Monthly new subscribers
SELECT

d.year,
d.month,
d.month_name,

COUNT(DISTINCT f.user_key) AS new_users

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key = d.date_key

WHERE f.subscription_event_type = 'Signup'

GROUP BY
d.year,
d.month,
d.month_name

ORDER BY
d.year,
d.month;

-- Monthly churned rate vs new users rate

WITH monthly_signup AS
(
SELECT

d.year,
d.month,

COUNT(DISTINCT f.user_key) signup_users

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key=d.date_key

WHERE subscription_event_type='Signup'

GROUP BY
d.year,
d.month
),

monthly_churn AS
(
SELECT

d.year,
d.month,

COUNT(DISTINCT f.user_key) churned_users

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key=d.date_key

WHERE subscription_event_type='Cancellation'

GROUP BY
d.year,
d.month
)

SELECT

s.year,
s.month,

s.signup_users,

COALESCE(c.churned_users,0) churned_users,

(s.signup_users -
COALESCE(c.churned_users,0))
AS net_growth

FROM monthly_signup s

LEFT JOIN monthly_churn c

ON s.year=c.year
AND s.month=c.month

ORDER BY
s.year,
s.month;

-- Monthly churn rate

WITH monthly_users AS
(
SELECT

d.year,
d.month,

COUNT(DISTINCT f.user_key)
AS total_users

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key=d.date_key

GROUP BY
d.year,
d.month
),

monthly_churn AS
(
SELECT

d.year,
d.month,

COUNT(DISTINCT f.user_key)
AS churned_users

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key=d.date_key

WHERE subscription_event_type='Cancellation'

GROUP BY
d.year,
d.month
)

SELECT

u.year,
u.month,

u.total_users,

COALESCE(c.churned_users,0)
AS churned_users,

ROUND(
100 *
COALESCE(c.churned_users,0)
/
u.total_users,
2
)
AS churn_rate

FROM monthly_users u

LEFT JOIN monthly_churn c

ON u.year=c.year
AND u.month=c.month

ORDER BY
u.year,
u.month;

-- Export for Power BI

CREATE VIEW monthly_churn_trend AS

WITH monthly_users AS
(
SELECT
d.year,
d.month,
d.month_name,

COUNT(DISTINCT f.user_key)
total_users

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key=d.date_key

GROUP BY
d.year,
d.month,
d.month_name
),

monthly_churn AS
(
SELECT
d.year,
d.month,

COUNT(DISTINCT f.user_key)
churned_users

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key=d.date_key

WHERE subscription_event_type='Cancellation'

GROUP BY
d.year,
d.month
)

SELECT

u.year,
u.month,
u.month_name,

u.total_users,

COALESCE(c.churned_users,0)
AS churned_users,

ROUND(
100 *
COALESCE(c.churned_users,0)
/
u.total_users,
2
)
AS churn_rate

FROM monthly_users u

LEFT JOIN monthly_churn c

ON u.year=c.year
AND u.month=c.month;

USE streampulse_db;

-- Isolate Users actuve for more than 6 months

SELECT

user_key,
signup_date,

TIMESTAMPDIFF(
MONTH,
signup_date,
CURDATE()
) AS tenure_months

FROM dim_user_cleaned

WHERE TIMESTAMPDIFF(
MONTH,
signup_date,
CURDATE()
) > 6;

-- Reusable view

CREATE VIEW active_6_month_users AS

SELECT

user_key,
signup_date,

TIMESTAMPDIFF(
MONTH,
signup_date,
CURDATE()
) AS tenure_months

FROM dim_user_cleaned

WHERE TIMESTAMPDIFF(
MONTH,
signup_date,
CURDATE()
) > 6;

-- Aggregate minutes watched by Users

SELECT

f.user_key,

c.genre,

SUM(f.minutes_watched)
AS total_minutes_watched

FROM fact_streampulse_activity_cleaned f

JOIN dim_content_cleaned c
ON f.content_key = c.content_key

GROUP BY

f.user_key,
c.genre

ORDER BY

f.user_key,
total_minutes_watched DESC;

-- Top 3 most watched genre report

SELECT

c.genre,

SUM(f.minutes_watched)
AS total_minutes_watched

FROM fact_streampulse_activity_cleaned f

JOIN dim_content_cleaned c
ON f.content_key = c.content_key

GROUP BY c.genre

ORDER BY total_minutes_watched DESC

LIMIT 3;

-- Genre view for Power BI

CREATE VIEW top_genres_report AS

SELECT

c.genre,

SUM(f.minutes_watched)
AS total_minutes_watched

FROM fact_streampulse_activity_cleaned f

JOIN dim_content_cleaned c
ON f.content_key=c.content_key

GROUP BY c.genre

ORDER BY total_minutes_watched DESC

LIMIT 3;

USE streampulse_db;

-- Inactive user identification(30 days)

SELECT

f.user_key,

MAX(
STR_TO_DATE(d.full_date,'%Y-%m-%d')
) AS last_activity_date

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key = d.date_key

GROUP BY f.user_key;

SELECT

f.user_key,

MAX(
STR_TO_DATE(d.full_date,'%Y-%m-%d')
) AS last_activity_date,

DATEDIFF(
CURDATE(),
MAX(
STR_TO_DATE(d.full_date,'%Y-%m-%d')
)
) AS inactive_days

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key = d.date_key

GROUP BY f.user_key

HAVING inactive_days > 30;

-- Inactive users by subscription plan

WITH inactive_users AS
(
SELECT

f.user_key,
f.subscription_key,

DATEDIFF(
CURDATE(),
MAX(
STR_TO_DATE(d.full_date,'%Y-%m-%d')
)
) AS inactive_days

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key=d.date_key

GROUP BY
f.user_key,
f.subscription_key

HAVING inactive_days > 30
)

SELECT

s.plan_name,

COUNT(DISTINCT i.user_key)
AS inactive_users

FROM inactive_users i

JOIN dim_subscription s
ON i.subscription_key=s.subscription_key

GROUP BY s.plan_name

ORDER BY inactive_users DESC;

-- High risk viewers

CREATE VIEW high_risk_users AS

SELECT

f.user_key,

s.plan_name,

MAX(
STR_TO_DATE(d.full_date,'%Y-%m-%d')
) AS last_activity_date,

DATEDIFF(
CURDATE(),
MAX(
STR_TO_DATE(d.full_date,'%Y-%m-%d')
)
) AS inactive_days,

AVG(f.engagement_score)
AS avg_engagement,

SUM(f.minutes_watched)
AS total_watch_time,

SUM(f.login_count)
AS total_logins

FROM fact_streampulse_activity_cleaned f

JOIN dim_date_cleaned d
ON f.date_key=d.date_key

JOIN dim_subscription s
ON f.subscription_key=s.subscription_key

GROUP BY

f.user_key,
s.plan_name

HAVING

inactive_days > 30

AND

avg_engagement < 30;

SELECT *
FROM high_risk_users;

USE streampulse_db;

-- Calculate Average Retention Rate by Plan Using SQL Window Functions

WITH plan_stats AS
(
SELECT

s.plan_name,

COUNT(DISTINCT f.user_key) total_users,

COUNT(
DISTINCT CASE
WHEN f.subscription_event_type <> 'Cancellation'
THEN f.user_key
END
) retained_users

FROM fact_streampulse_activity_cleaned f

JOIN dim_subscription s
ON f.subscription_key=s.subscription_key

GROUP BY s.plan_name
)

SELECT

plan_name,
total_users,
retained_users,

ROUND(
100.0 * retained_users
/
total_users,
2
) retention_rate

FROM plan_stats;

WITH retention_data AS
(
SELECT

s.plan_name,

ROUND(
100.0 *
COUNT(
DISTINCT CASE
WHEN f.subscription_event_type <> 'Cancellation'
THEN f.user_key
END
)
/
COUNT(DISTINCT f.user_key),
2
) retention_rate

FROM fact_streampulse_activity_cleaned f

JOIN dim_subscription s
ON f.subscription_key=s.subscription_key

GROUP BY s.plan_name
)

SELECT

plan_name,

retention_rate,

ROUND(
AVG(retention_rate)
OVER(),
2
) overall_avg_retention

FROM retention_data;

-- Verify Viewer engagement score
-- Watch time vd Engagement
SELECT

ROUND(
AVG(minutes_watched),
2
) avg_watch_time,

ROUND(
AVG(engagement_score),
2
) avg_engagement

FROM fact_streampulse_activity_cleaned;

-- Segment Engagement Levels

	SELECT

CASE

WHEN engagement_score >= 80
THEN 'High'

WHEN engagement_score >= 50
THEN 'Medium'

ELSE 'Low'

END engagement_group,

COUNT(*) users,

ROUND(
AVG(minutes_watched),
2
) avg_watch_time

FROM fact_streampulse_activity_cleaned

GROUP BY engagement_group;

-- Validate by Subscription Plan

SELECT

s.plan_name,

ROUND(
AVG(f.engagement_score),
2
) avg_ves,

ROUND(
AVG(f.minutes_watched),
2
) avg_watch_time

FROM fact_streampulse_activity_cleaned f

JOIN dim_subscription s
ON f.subscription_key=s.subscription_key

GROUP BY s.plan_name;

-- peer review SQL logic against schema

SELECT COUNT(*)
FROM fact_streampulse_activity_cleaned
WHERE user_key IS NULL;

SELECT COUNT(*)
FROM fact_streampulse_activity_cleaned
WHERE subscription_key IS NULL;

SELECT COUNT(*)

FROM fact_streampulse_activity_cleaned f

LEFT JOIN dim_user_cleaned u
ON f.user_key=u.user_key

WHERE u.user_key IS NULL;

SELECT COUNT(*)

FROM fact_streampulse_activity_cleaned f

LEFT JOIN dim_subscription s
ON f.subscription_key=s.subscription_key

WHERE s.subscription_key IS NULL;

SELECT COUNT(*)

FROM fact_streampulse_activity_cleaned f

LEFT JOIN dim_content_cleaned c
ON f.content_key=c.content_key

WHERE c.content_key IS NULL;

CREATE VIEW retention_analysis AS

SELECT

s.plan_name,

COUNT(DISTINCT f.user_key)
AS total_users,

COUNT(
DISTINCT CASE
WHEN f.subscription_event_type <> 'Cancellation'
THEN f.user_key
END
)
AS retained_users,

ROUND(
100.0 *
COUNT(
DISTINCT CASE
WHEN f.subscription_event_type <> 'Cancellation'
THEN f.user_key
END
)
/
COUNT(DISTINCT f.user_key),
2
)
AS retention_rate,

ROUND(
AVG(f.engagement_score),
2
)
AS avg_ves

FROM fact_streampulse_activity_cleaned f

JOIN dim_subscription s
ON f.subscription_key=s.subscription_key

GROUP BY s.plan_name;

USE streampulse_db;

-- Draft Customer Lifetime Value (CLV) Calculation
-- Average CLV
SELECT

ROUND(
AVG(lifetime_value_usd),
2
) AS avg_clv

FROM dim_user_cleaned;

-- CLV by subscription Plan

SELECT

s.plan_name,

ROUND(
AVG(u.lifetime_value_usd),
2
) AS avg_clv

FROM fact_streampulse_activity_cleaned f

JOIN dim_user_cleaned u
ON f.user_key=u.user_key

JOIN dim_subscription s
ON f.subscription_key=s.subscription_key

GROUP BY s.plan_name

ORDER BY avg_clv DESC;

-- Top 20 highest CLV users

SELECT

user_key,

lifetime_value_usd

FROM dim_user_cleaned

ORDER BY lifetime_value_usd DESC

LIMIT 20;


-- Detect outliers

SELECT

MIN(minutes_watched) min_watch,

MAX(minutes_watched) max_watch,

AVG(minutes_watched) avg_watch,

STDDEV(minutes_watched) std_watch

FROM fact_streampulse_activity_cleaned;

-- Find extreme watch records

SELECT *

FROM fact_streampulse_activity_cleaned

WHERE minutes_watched >

(
SELECT

AVG(minutes_watched)

+

3 * STDDEV(minutes_watched)

FROM fact_streampulse_activity_cleaned
);

-- Top watchers

SELECT

user_key,

SUM(minutes_watched)
AS total_watch_time

FROM fact_streampulse_activity_cleaned

GROUP BY user_key

ORDER BY total_watch_time DESC

LIMIT 20;

-- Outliers by user

WITH user_watch_time AS
(
SELECT

user_key,

SUM(minutes_watched)
AS total_watch_time

FROM fact_streampulse_activity_cleaned

GROUP BY user_key
)

SELECT *

FROM user_watch_time

WHERE total_watch_time >

(
SELECT

AVG(total_watch_time)

+

3 * STDDEV(total_watch_time)

FROM user_watch_time
);

-- Final SQL dataset for Python EDA
CREATE VIEW fact_streampulse_activity_final AS

SELECT

u.user_key,

u.age,
u.gender,
u.country,
u.user_segment,
u.lifetime_value_usd,

s.plan_name,
s.monthly_price,

c.genre,
c.content_type,

dv.device_type,
dv.operating_system,

STR_TO_DATE(d.full_date,'%Y-%m-%d') AS activity_date,
d.month_name,
d.year,

f.minutes_watched,
f.session_duration_mins,
f.completion_rate,

f.login_count,

f.pause_count,
f.buffering_events,
f.stream_quality,

f.engagement_score,
f.watch_efficiency,

f.revenue_attributed_usd,

f.subscription_event_type,
f.cancellation_reason,

CASE
    WHEN f.subscription_event_type = 'Cancellation'
    THEN 1
    ELSE 0
END AS churn_flag

FROM fact_streampulse_activity_cleaned f

JOIN dim_user_cleaned u
ON f.user_key = u.user_key

JOIN dim_subscription s
ON f.subscription_key = s.subscription_key

JOIN dim_content_cleaned c
ON f.content_key = c.content_key

JOIN dim_device dv
ON f.device_key = dv.device_key

JOIN dim_date_cleaned d
ON f.date_key = d.date_key;

SELECT * FROM fact_streampulse_activity_final;