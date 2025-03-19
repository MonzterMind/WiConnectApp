USE [WitronCentralDatabaseSQLServer]
GO
/****** Object:  StoredProcedure [dbo].[GetManagementKPIBySite]    Script Date: 2025-03-14 6:53:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:        Frank Ramos
-- Create date:   2024-12-17
-- Description:   Get ManagementKPI data by site. 
-- @Site: filter table by site If site is empty, select all data.               
-- @OtherCondition: we might use this in the future
-- =============================================
ALTER PROCEDURE [dbo].[GetManagementKPIBySite] 
    @Site VARCHAR(255),
    @OtherCondition VARCHAR(255) = ''
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if 'year' exists in @OtherCondition
    IF LOWER(@Site) = 'all'
    BEGIN
        IF @OtherCondition = ''
        BEGIN
            SELECT * 
            FROM ManagementKPILive;
        END
        ELSE IF CHARINDEX('year', LOWER(@OtherCondition)) > 0
        BEGIN
            -- Extract the last 4 characters and convert to integer for the year
            SELECT * 
            FROM ManagementKPILive 
            WHERE [year] = CAST(RIGHT(@OtherCondition, 4) AS INT);
        END
		ELSE IF CHARINDEX('PreviousMonth', LOWER(@OtherCondition)) > 0
        BEGIN
			DECLARE @StartDate  as date;
			set @StartDate = CAST(RIGHT(@OtherCondition, 10) AS date);

            -- added this for the CAN President Dashboard (2025-03-14)
            SELECT * 
            FROM ManagementKPILive 
            WHERE [year] = YEAR(@StartDate) AND cast([month] as int)= Month(@StartDate);
        END
    END
    ELSE
    BEGIN
        IF @OtherCondition = ''
        BEGIN
            SELECT * 
            FROM ManagementKPILive 
            WHERE site = @Site;
        END
        ELSE IF CHARINDEX('year', LOWER(@OtherCondition)) > 0
        BEGIN
            -- Extract the last 4 characters and convert to integer for the year
            SELECT * 
            FROM ManagementKPILive 
            WHERE site = @Site 
            AND [year] = CAST(RIGHT(@OtherCondition, 4) AS INT);
        END
		
    END
END;

