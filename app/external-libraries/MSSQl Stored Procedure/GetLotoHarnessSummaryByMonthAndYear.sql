
/****** Object:  StoredProcedure [dbo].[GetLotoHarnessBySite] Script Date: 17/12/2024 12:20:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:        Frank Ramos
-- Create date:   2024-12-17
-- Description:   Get LOTO/Harness Summary By Year. 
-- @Year: filter table by year If year is empty, select all data.               
-- @OtherCondition: we might use this in the future
-- =============================================
Create PROCEDURE [dbo].[GetLotoHarnessSummaryByMonthAndYear] 
    
    @OtherCondition VARCHAR(255) = ''
AS
BEGIN
     
        SELECT 
			site, 
			COUNT(EmployeeName) AS TotalCount, 
			CONCAT(YEAR(reportDate), '-', RIGHT('0' + CAST(MONTH(reportDate) AS VARCHAR), 2)) AS YearAndMonth
		FROM 
			[Loto-HarnessLive]
		GROUP BY 
			site, YEAR(reportDate), MONTH(reportDate);
END
GO

