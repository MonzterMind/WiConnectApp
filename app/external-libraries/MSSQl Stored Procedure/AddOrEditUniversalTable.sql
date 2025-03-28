USE [WitronCentralDatabaseSQLServer]
GO
/****** Object:  StoredProcedure [dbo].[AddOrEditUniversalTable]    Script Date: 2025-03-28 6:43:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<FRANK RAMOS>
-- Create date: <2025-03-19>
-- Description:	<add or update data on the Universal Table>
-- Parameters :   @site, @reportDate,@uniqueReportName (this is the report group) ,@tabledata (defaulted to UniversalTableLive) ,@otherCondition (we use in the future)
-- ===============================How to use =============================================
--EXEC [AddOrEditUniversalTable] 
--    @site = 'CY',
--    @reportDate = '2025-02-25',
--	  @uniqueReportName= 'Test'
--	  @tabledata= 'Firstname:Frank;;LastName:Ramos;;Site:CY'  ---- note this is a ;; delimited string array
--	  @otherCondition= ''
-- =============================================
ALTER PROCEDURE [dbo].[AddOrEditUniversalTable]
    @site VARCHAR(10),    
    @reportDate VARCHAR(50),
    @uniqueReportName VARCHAR(50),
    @tabledata NVARCHAR(MAX),
    @otherCondition NVARCHAR(50)='',
    @tableName VARCHAR(50) = 'UniversalTableLive'  -- Fixed typo in default table name
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate @tableName (Avoid SQL Injection Risk)
    IF @tableName NOT IN ('UniversalTableLive', 'UniversalTableWiFaultRateLive') 
    BEGIN
        RAISERROR('Invalid table name.', 16, 1);
        RETURN;
    END
	


    DECLARE @EXISTS INT = 0;
    DECLARE @ID INT = NULL; -- Variable to store ID if record exists
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ConvertedReportDate DATE = TRY_CAST(@reportDate AS DATE);

	--forward saving 
	IF lower(@otherCondition)='append'
	Begin
		SET @SQL = '
            INSERT INTO ' + QUOTENAME(@tableName) + ' ([SITE], ReportDate, UniqueReportName, TableData, OtherCondition)
            VALUES (@site, @ConvertedReportDate, @uniqueReportName, @tabledata, @otherCondition)';

        EXEC sp_executesql @SQL,  
            N'@site VARCHAR(10), @ConvertedReportDate DATE, @uniqueReportName VARCHAR(50), @tabledata NVARCHAR(MAX), @otherCondition NVARCHAR(50)', 
            @site, @ConvertedReportDate, @uniqueReportName, @tabledata, @otherCondition;
		return;
	end;

    -- Check if record exists and get the ID
    SET @SQL = '
        SELECT @ID = ID FROM ' + QUOTENAME(@tableName) + '
        WHERE [SITE] = @site AND REPORTDATE = @ConvertedReportDate AND UniqueReportName = @uniqueReportName';

    EXEC sp_executesql @SQL,  
        N'@ConvertedReportDate DATE, @site VARCHAR(10), @uniqueReportName VARCHAR(50), @ID INT OUTPUT', 
        @ConvertedReportDate, @site, @uniqueReportName, @ID OUTPUT;

    -- If ID is NULL, insert new record
    IF @ID IS NULL  
    BEGIN
        SET @SQL = '
            INSERT INTO ' + QUOTENAME(@tableName) + ' ([SITE], ReportDate, UniqueReportName, TableData, OtherCondition)
            VALUES (@site, @ConvertedReportDate, @uniqueReportName, @tabledata, @otherCondition)';

        EXEC sp_executesql @SQL,  
            N'@site VARCHAR(10), @ConvertedReportDate DATE, @uniqueReportName VARCHAR(50), @tabledata NVARCHAR(MAX), @otherCondition NVARCHAR(50)', 
            @site, @ConvertedReportDate, @uniqueReportName, @tabledata, @otherCondition;
    END
    ELSE -- Update existing record
    BEGIN 
        SET @SQL = '
            UPDATE ' + QUOTENAME(@tableName) + ' 
            SET TableData = @tabledata 
            WHERE ID = @ID';

        EXEC sp_executesql @SQL,  
            N'@tabledata NVARCHAR(MAX), @ID INT', @tabledata, @ID;
    END
END;


