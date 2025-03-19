USE [WitronCentralDatabaseSQLServer]
GO
/****** Object:  StoredProcedure [dbo].[GetProductionMetricsBySite]    Script Date: 2025-02-26 7:41:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:        Frank Ramos
-- Create date:   2025-02-26
-- Description:   Get ProductionMetrics data by site. 
-- @Site: filter table by site If site is empty, select all data.               
-- @OtherCondition: filter by specific date
-- =============================================
CREATE PROCEDURE [dbo].[GetProductionMetricsBySite] 
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
            FROM ProductionMetricsLive;
        END
        ELSE IF CHARINDEX('date', LOWER(@OtherCondition)) > 0
        BEGIN
            -- Extract the last 4 characters and convert to integer for the year
            SELECT * 
            FROM ProductionMetricsLive 
            WHERE ReportDate = TRY_CAST (RIGHT(@OtherCondition, 9) AS date);
        END
    END
    ELSE
    BEGIN
        IF @OtherCondition = ''
        BEGIN
            SELECT * 
            FROM ProductionMetricsLive 
            WHERE site = @Site;
        END
        ELSE IF CHARINDEX('year', LOWER(@OtherCondition)) > 0
        BEGIN
            -- Extract the last 4 characters and convert to integer for the year
            SELECT * 
            FROM ProductionMetricsLive 
            WHERE site = @Site 
            AND ReportDate = TRY_CAST (RIGHT(@OtherCondition, 9) AS date);
        END
    END
END;

