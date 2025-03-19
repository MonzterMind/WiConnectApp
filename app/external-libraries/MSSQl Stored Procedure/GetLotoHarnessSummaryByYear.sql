
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
Create PROCEDURE [dbo].[GetLotoHarnessSummaryByYear] 
    @Year int,
    @OtherCondition VARCHAR(255) = ''
AS
BEGIN
    SET NOCOUNT ON;

    IF @Year = '' 
    BEGIN
        SELECT site, count( EmployeeName) as TotalCount
        FROM [Loto-HarnessLive]   group by site
    END
    ELSE
    BEGIN
        SELECT site, count( EmployeeName) as TotalCount
        FROM [Loto-HarnessLive]  where year(reportdate)=@Year group by site
    END
END
GO

