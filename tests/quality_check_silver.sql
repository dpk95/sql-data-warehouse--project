--Check for Nulls or Duplicates in Bronze.crm_cst_id.
--Expectation: No Results.
SELECT 
	cst_id, 
	COUNT (*)
FROM Silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL;


-- Checking the basis on which the priority is given
SELECT *
FROM Bronze.crm_cust_info
WHERE cst_id = 29466;

--Solved through CTE
WITH cust_info AS(
				SELECT *,
					ROW_NUMBER()
					OVER(
						PARTITION BY cst_id
						ORDER BY cst_create_date DESC
					) ranking
				FROM Bronze.crm_cust_info
	)
DELETE 
FROM cust_info
where ranking>1 OR cst_id is null;

-- Solved through Sub-query
SELECT *
FROM(
	SELECT 
		*,
		ROW_NUMBER()
			OVER(
				PARTITION BY cst_id 
				ORDER BY cst_create_date DESC
				) Ranking
	FROM 
		Bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
	) AS info
WHERE Ranking = 1 
			
