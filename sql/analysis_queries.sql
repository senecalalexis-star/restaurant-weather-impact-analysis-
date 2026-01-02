-- =============================================
-- ANALYSIS: THE RAIN EFFECT
-- Objective: Quantify impact of rain on restaurant operations
-- =============================================

-- ---------------------------------------------
-- MASTER QUERY 
-- Use for :
-- SECTION 1: DINNER RUSH TIME ANALYSIS
-- Question: Does rain shift the peak dinner rush?

-- SECTION 2: BILLS ANALYSIS
-- Question: Does rain affect the volume of bill?

-- SECTION 4: WEEK BY WEEK DEVIATIONS ANALYSIS
-- Question: What is the median deviation of rainy day? 
-- ---------------------------------------------

WITH hourly_bins AS (
    SELECT
        date,
        bill_id,
		--Normalize timestamps to the start of the hour
        DATE_TRUNC('hour', time) AS hour_bin
    FROM bill_id bi
	    --FILTER: Keep only restaurant opening hour
    WHERE time BETWEEN '16:00:00' AND '21:00:00'
)

SELECT
    hb.hour_bin,
    hb.bill_id,
	date,
	--Boolean Flag: Returns TRUE if the weather table shows any rain for this date
    EXISTS (
        SELECT 1
        FROM weather w
        WHERE w.date = hb.date
          AND w.precip > 0
    ) AS had_precip
FROM hourly_bins hb
JOIN bill_total AS bt ON bt.bill_id = hb.bill_id
WHERE 
	-- FILTER: Comparison Period (August 2024 vs August 2025)
(
      hb.date BETWEEN '2025-08-01' AND '2025-08-31'
   OR hb.date BETWEEN '2024-08-01' AND '2024-08-31'
)
	-- FILTER: Exclude voided bills and staff meals ($0.00)
AND bt.total > 0
ORDER BY date,hb.hour_bin;

-- ---------------------------------------------
-- SECTION 3: AVERAGE TICKET SIZE (ATS) ANALYSIS
-- Question: Does rain affect the average ticket size?
-- ---------------------------------------------
WITH hourly_bins AS (
    SELECT
        date,
        bill_id,
        DATE_TRUNC('hour', time) AS hour_bin
    FROM bill_id bi
    WHERE time BETWEEN '16:00:00' AND '21:00:00'
)

SELECT
	total,
	date,
    EXISTS (
        SELECT 1
        FROM weather w
        WHERE w.date = hb.date
          AND w.precip > 0
    ) AS had_precip
FROM hourly_bins hb
JOIN bill_total AS bt ON bt.bill_id  = hb.bill_id
WHERE 
(
      hb.date BETWEEN '2025-08-01' AND '2025-08-31'
   OR hb.date BETWEEN '2024-08-01' AND '2024-08-31'
)
AND bt.total > 0
ORDER BY date,hb.hour_bin;
-- ---------------------------------------------
-- SECTION 5: TABLE DISTRIBUTION ANALYSIS
-- Question: Does rain affect the table distribution?
-- ---------------------------------------------

WITH hourly_bins AS (
    SELECT
        date,
		table_id,
        bill_id,
        DATE_TRUNC('hour', time) AS hour_bin
    FROM bill_id bi
    WHERE time BETWEEN '16:00:00' AND '21:00:00'
)

SELECT
	hb.bill_id,
	table_id,
	date,
    EXISTS (
        SELECT 1
        FROM weather w
        WHERE w.date = hb.date
          AND w.precip > 0
    ) AS had_precip
FROM hourly_bins hb
JOIN bill_total AS bt ON bt.bill_id  = hb.bill_id
WHERE 
(
      hb.date BETWEEN '2025-08-01' AND '2025-08-31'
   OR hb.date BETWEEN '2024-08-01' AND '2024-08-31'
)
AND bt.total > 0
ORDER BY date,hb.hour_bin;


