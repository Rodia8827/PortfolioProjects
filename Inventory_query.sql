
-- checking if the database was uploaded 

SELECT*
FROM PortfolioProject..InventoryProject

-- Total cost of the actual inventory (STOCK)

SELECT SUM ([Costo del Stock])
FROM PortfolioProject..InventoryProject

-- Total qtys of actual stock

SELECT SUM (CAST ([Stock Actual] AS INT)) AS Total_stock
FROM PortfolioProject..InventoryProject

-- Total units in inventory per ItmsGroupName

SELECT [ItmsGrpNam] , [Sub-Gupo], SUM ([Stock Actual]) AS Total_qty
FROM PortfolioProject..InventoryProject
GROUP BY [ItmsGrpNam] , [Sub-Gupo]
ORDER BY Total_qty DESC


-- ROLLUP FUNCTION TO FIND OUT THE TOTAL ITEMS IN STOCK PER SUB GROUP  

SELECT 
COALESCE ([Sub-Gupo], 'TOTAL ARTICULOS STOCK') AS [Sub-Gupo] ,
--[ItmsGrpNam] , 
--[Sub-Gupo]
SUM (CAST ([Stock Actual] AS INT)) AS Total_qty --,( SUM (CAST ([Stock Actual] AS INT)) / COALESCE ([Sub-Gupo], 'TOTAL') )
FROM PortfolioProject..InventoryProject
--WHERE [ItmsGrpNam] = 'ACCES. PARA TABLEROS', you can change the ITMSGRPNAME to check the total per category
--GROUP BY --[ItmsGrpNam], 
--[Sub-Gupo]
GROUP BY rollup ([Sub-Gupo])--, --[ItmsGrpNam]
ORDER BY Total_qty DESC

-- Value of the stock

SELECT 
[ItmsGrpNam],
SUM([Stock Actual]*[Costo]) AS Total_stock_cost
FROM PortfolioProject..InventoryProject
--WHERE [ItmsGrpNam] = 'ACCES. PARA TABLEROS', SELECT THE FAMILY OF ITEMS AS YOUR INTEREST.
GROUP BY ROLLUP ([ItmsGrpNam])--, ([Sub-Gupo])
ORDER BY 1,2

-- SURPLUS INVENTORY PER SELECTED MONTH CTE

--CREATE VIEW


CREATE VIEW June_TotalCost 
AS
(SELECT 
[ItmsGrpNam],
SUM([Stock Actual]*[Costo]) AS Total_stock_cost_June
FROM PortfolioProject..InventoryProject
--WHERE [ItmsGrpNam] = 'ACCES. PARA TABLEROS'
WHERE [Última Entrada] BETWEEN ('2021-06-01') AND ('2021-06-30')
GROUP BY [ItmsGrpNam])

SELECT *
FROM June_TotalCost

--INNER JOIN 

SELECT 
A.[ItmsGrpNam],
SUM(A.[Stock Actual]*A.[Costo]) AS Total_stock_cost_May,
B.Total_stock_cost_June, ( SUM(A.[Stock Actual]*A.[Costo])  - B.Total_stock_cost_June) AS SurplusInventory
FROM PortfolioProject..InventoryProject AS A
INNER JOIN June_TotalCost AS B
ON A.[ItmsGrpNam] = B.[ItmsGrpNam]
WHERE A.[Última Entrada] BETWEEN ('2021-05-01') AND ('2021-05-31')
GROUP BY A.[ItmsGrpNam], B.Total_stock_cost_June

--CLASSIFICATION OF INVENTORY  IN STOCK 
--Case statement

SELECT 
[ItmsGrpNam],[Sub-Gupo],
(CASE
WHEN  [Antigüedad] BETWEEN 0 AND 30 THEN 'ShortTerm_inventory'
WHEN [Antigüedad] BETWEEN 31 AND 90 THEN 'Project_inventory'
WHEN [Antigüedad] BETWEEN 91 AND 180 THEN 'LongTerm_inventory'
ELSE 'Masiro'
END )AS TypeOfInventory
--Masiro Inventory is stock in the warehouse for more than 180 days.
--SUM([Stock Actual]*[Costo]) AS Total_stock_cost
FROM PortfolioProject..InventoryProject
WHERE [ItmsGrpNam] NOT IN ('CELDAS ORMAZABAL', 'SIVACON S8')
--GROUP BY([ItmsGrpNam]), ([Sub-Gupo])
ORDER BY 1,2


