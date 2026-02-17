/* =========================================================
   Velora Hotel Booking & Revenue Analytics – SQL Analysis
   ========================================================= */


/* ---------------------------------------------------------
   1. OVERALL KPI METRICS
--------------------------------------------------------- */

-- Total Bookings
SELECT COUNT(*) AS total_bookings
FROM hotel_bookings;

-- Cancellation Percentage
SELECT 
    ROUND(
        SUM(CASE WHEN is_cancelled = 1 THEN 1 ELSE 0 END) 
        / COUNT(*) * 100, 
    2) AS cancellation_pct
FROM hotel_bookings;

-- Total Revenue
SELECT SUM(revenue) AS total_revenue
FROM hotel_bookings;

-- Total Room Nights
SELECT SUM(room_nights) AS total_room_nights
FROM hotel_bookings;

-- Average Room Rate (ARR)
SELECT 
    ROUND(SUM(revenue) / SUM(room_nights), 2) AS avg_room_rate
FROM hotel_bookings;


/* ---------------------------------------------------------
   2. DAILY STAY TREND (Stays Per Day)
--------------------------------------------------------- */

SELECT 
    booking_date,
    COUNT(*) AS daily_bookings
FROM hotel_bookings
GROUP BY booking_date
ORDER BY booking_date;


/* ---------------------------------------------------------
   3. BOOKING CHANNEL ANALYSIS (Who Is Booking)
--------------------------------------------------------- */

SELECT 
    loyalty_level,
    booking_channel,
    COUNT(*) AS booking_count
FROM hotel_bookings
GROUP BY loyalty_level, booking_channel
ORDER BY loyalty_level;


/* ---------------------------------------------------------
   4. WEEKDAY VS WEEKEND ANALYSIS
--------------------------------------------------------- */

SELECT 
    CASE 
        WHEN DAYOFWEEK(booking_date) IN (1,7) 
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS booking_count
FROM hotel_bookings
GROUP BY day_type;


/* ---------------------------------------------------------
   5. ADVANCE BOOKING WINDOW (How Far Away Bucket)
--------------------------------------------------------- */

SELECT 
    CASE 
        WHEN DATEDIFF(checkin_date, booking_date) BETWEEN 0 AND 7 THEN '0-7 Days'
        WHEN DATEDIFF(checkin_date, booking_date) BETWEEN 8 AND 30 THEN '8-30 Days'
        WHEN DATEDIFF(checkin_date, booking_date) BETWEEN 31 AND 90 THEN '31-90 Days'
        ELSE '90+ Days'
    END AS booking_window_bucket,
    COUNT(*) AS booking_count
FROM hotel_bookings
GROUP BY booking_window_bucket;


/* ---------------------------------------------------------
   6. MULTI-NIGHT VS SINGLE NIGHT
--------------------------------------------------------- */

SELECT 
    CASE 
        WHEN room_nights = 1 THEN 'Single Night'
        ELSE 'Multi Night'
    END AS stay_type,
    COUNT(*) AS booking_count
FROM hotel_bookings
GROUP BY stay_type;


/* ---------------------------------------------------------
   7. REVENUE BY LOYALTY LEVEL
--------------------------------------------------------- */

SELECT 
    loyalty_level,
    COUNT(*) AS total_bookings,
    SUM(revenue) AS total_revenue,
    ROUND(SUM(revenue)/COUNT(*),2) AS avg_revenue_per_booking
FROM hotel_bookings
GROUP BY loyalty_level
ORDER BY total_revenue DESC;


/* ---------------------------------------------------------
   8. MONTH-OVER-MONTH REVENUE GROWTH
--------------------------------------------------------- */

WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(booking_date, '%Y-%m-01') AS month,
        SUM(revenue) AS total_revenue
    FROM hotel_bookings
    GROUP BY month
)

SELECT 
    month,
    total_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) 
            OVER (ORDER BY month)) 
        / LAG(total_revenue) 
            OVER (ORDER BY month) * 100,
    2) AS mom_growth_pct
FROM monthly_revenue;
