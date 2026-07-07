# StreamPulse Churn Analysis Project
## Data Dictionary

---

## Dataset Name

**fact_streampulse_activity_final**

### Description

This dataset is the final analytical dataset created after cleaning, transforming, and integrating multiple SQL tables. It combines user demographics, subscription information, content consumption, device details, engagement metrics, revenue information, and churn indicators. The dataset is designed for:

- Exploratory Data Analysis (EDA)
- KPI Calculation
- Power BI Dashboard Development
- Machine Learning Churn Prediction

---

## Dataset Information

| Property | Value |
|----------|-------|
| Dataset Name | fact_streampulse_activity_final |
| Project | StreamPulse SVOD Churn Prediction |
| Domain | Entertainment / Streaming Services |
| Source | SQL Data Warehouse |
| Record Level | One Activity Record per User Session |
| Target Variable | churn_flag |

---

# Data Dictionary

| Column Name | Data Type | Description | Business Meaning | Example |
|-------------|-----------|-------------|------------------|---------|
| activity_key | Integer | Unique identifier for each activity record | Primary key used to uniquely identify an activity session | 10235 |
| user_key | Integer | Unique identifier of a subscriber | Links activity to a specific customer | 100145 |
| date_key | Integer | Foreign key from Date Dimension | Used to join activity with calendar information | 20230115 |
| content_key | Integer | Foreign key from Content Dimension | Identifies the content being watched | 4502 |
| device_key | Integer | Foreign key from Device Dimension | Identifies viewing device | 14 |
| subscription_key | Integer | Foreign key from Subscription Dimension | Identifies user's subscription plan | 3 |
| activity_date | Date | Date when activity occurred | Used for trend analysis and time-series reporting | 2023-08-21 |
| age | Integer | Age of subscriber | Used for customer segmentation | 28 |
| gender | Text | Subscriber gender | Demographic analysis | Female |
| country | Text | Subscriber country | Geographic segmentation | India |
| user_segment | Text | Customer segment | Business-defined customer category | Loyal |
| plan_name | Text | Subscription plan | Determines pricing tier | Premium |
| monthly_price | Decimal | Monthly subscription fee | Revenue analysis | 19.99 |
| genre | Text | Content genre | Used for content preference analysis | Drama |
| content_type | Text | Type of content | Movie or Series analysis | Movie |
| device_type | Text | Viewing device | Device usage analysis | Smart TV |
| operating_system | Text | Device operating system | Technical platform analysis | Android TV |
| minutes_watched | Decimal | Total minutes watched | Measures user engagement | 240.5 |
| session_duration_mins | Decimal | Total viewing session duration | Indicates viewing behavior | 265 |
| completion_rate | Decimal | Percentage of content completed | Measures content completion | 87.50 |
| login_count | Integer | Number of platform logins | Indicates platform activity | 6 |
| pause_count | Integer | Number of pauses during playback | Viewing behavior analysis | 4 |
| buffering_events | Integer | Number of buffering incidents | Streaming quality indicator | 2 |
| stream_quality | Text | Streaming resolution | Service quality analysis | HD |
| engagement_score | Decimal | Composite engagement metric | Overall user engagement score | 82.4 |
| watch_efficiency | Decimal | Ratio of completed viewing to session time | Indicates viewing efficiency | 0.91 |
| revenue_attributed_usd | Decimal | Revenue generated from activity | Revenue contribution analysis | 19.99 |
| lifetime_value_usd | Decimal | Estimated customer lifetime value | Measures long-term customer worth | 425.80 |
| subscription_event_type | Text | Subscription event performed | Signup, Renewal, Upgrade, Downgrade, Cancellation | Renewal |
| cancellation_reason | Text | Reason for cancellation | Business insight into churn drivers | Too Expensive |
| churn_flag | Integer | Target variable for machine learning | 1 = Churned, 0 = Active | 1 |

---

# Target Variable

## churn_flag

| Value | Meaning |
|-------|---------|
| 0 | Active Subscriber |
| 1 | Churned Subscriber |

### Business Purpose

The **churn_flag** is the target variable used to train machine learning models that predict whether a customer is likely to cancel their subscription.

---

# Key Business Metrics

## Engagement Score

Measures the overall engagement level of a subscriber using viewing activity, login frequency, watch completion, and interaction metrics.

Higher Score = More Engaged User

---

## Watch Efficiency

Measures how efficiently a subscriber consumes content.

Formula:

Watch Efficiency = Minutes Watched ÷ Session Duration

Higher values indicate stronger viewing behavior.

---

## Revenue Attributed

Revenue generated from an individual user's subscription activity.

Used in:

- Revenue Analysis
- Customer Lifetime Value (CLV)
- Executive Dashboard KPIs

---

## Lifetime Value (CLV)

Estimated total revenue expected from a customer throughout their relationship with StreamPulse.

Used for:

- Customer Segmentation
- Marketing Budget Allocation
- Retention Strategy

---

# SQL Tables Used

| Table | Purpose |
|--------|---------|
| fact_activity | Streaming activity records |
| dim_user | User demographic information |
| dim_subscription | Subscription plan details |
| dim_content | Content metadata |
| dim_device | Device information |
| dim_date | Calendar dimension |

---

# Dashboard KPIs

The following KPIs are calculated using this dataset:

- Monthly Churn Rate
- Average Retention Rate by Plan
- Viewer Engagement Score (VES)
- Customer Lifetime Value (CLV)
- Average Watch Time
- Revenue by Subscription Plan
- Top Genres
- High-Risk Users

---

# Machine Learning Features

## Target Variable

- churn_flag

## Numerical Features

- age
- monthly_price
- minutes_watched
- session_duration_mins
- completion_rate
- login_count
- pause_count
- buffering_events
- engagement_score
- watch_efficiency
- revenue_attributed_usd
- lifetime_value_usd

## Categorical Features

- gender
- country
- user_segment
- plan_name
- genre
- content_type
- device_type
- operating_system
- stream_quality

---

# Notes

- Primary Key: activity_key
- Foreign Keys: user_key, date_key, content_key, device_key, subscription_key
- Missing values in **cancellation_reason** indicate users who have not cancelled.
- Missing values in **subscription_event_type** indicate no subscription event occurred during that activity.
- **subscription_event_type** and **cancellation_reason** are retained for business reporting but excluded from machine learning to prevent target leakage.

---

**Author:** Dampanaboina Venkata Nihitha  
**Project:** StreamPulse SVOD Churn Analysis & Prediction  
**Tools Used:** MySQL, Python, Pandas, Scikit-learn, Power BI, Jupyter Notebook, VS Code