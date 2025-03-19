USE [WitronCentralDatabaseSQLServer]
GO
/****** Object:  StoredProcedure [dbo].[GetUniversalTableBySite]    Script Date: 2025-03-19 8:39:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Frank Ramos>
-- Create date: < 205-03-18>
-- Description:	<Stored Procedure to get GetUniversalTableBySite >
-- =============================================
Create PROCEDURE [dbo].[GetUniversalTableBySite]
	@siteName VARCHAR(10),
    @uniqueReportName VARCHAR(10),	
	@OtherCondition varchar (255) ='', -- New parameter for additional filtering
	@TableName varchar(50)='UniversalTableLive' -- we can use this in the future to switch table or archiving
AS
BEGIN
    SET NOCOUNT ON;
	 -- Validate @tableName (Avoid SQL Injection Risk)
	 -- IF @TableName NOT IN ('UniversalTableLive', 'UniversalTableLive2004') 
    IF @TableName NOT IN ('UniversalTableLive') 
    BEGIN
        RAISERROR('Invalid table name.', 16, 1);
        RETURN;
    END
    -- Temporary table for storing parsed key-value pairs
    CREATE TABLE #tbl (
        RecordID INT,  
        FieldName NVARCHAR(100), 
        FieldValue NVARCHAR(100)
    );

    -- Temporary table for storing original data
    CREATE TABLE #OriginalData (
        RecordID INT,
        Site NVARCHAR(100),
        ReportDate DATETIME,
        UpdateDate DATETIME
    );

    DECLARE @SQL NVARCHAR(MAX);
	DECLARE @WhereCondition NVARCHAR(50) = ''; -- Variable to hold year condition

    -- Check if @OtherCondition contains "year" and extract the year value dynamically
-----------------------------------------------------------------------------------------------------------------------------------------------------------
    IF CHARINDEX('year=', LOWER(@OtherCondition)) > 0
    BEGIN
        SET @WhereCondition = ' AND YEAR(ReportDate) = ' + 
            STUFF(@OtherCondition, 1, CHARINDEX('=', @OtherCondition), '');
    END
	-- else if 
	--we can use other condition to add more condition here
------------------------------------------------------------------------------------------------------------------------------------------------------------

    -- Construct dynamic SQL for inserting into #OriginalData
	
    SET @SQL = '
        INSERT INTO #OriginalData (RecordID, Site, ReportDate, UpdateDate)
        SELECT ID, Site, ReportDate, UpdateDate
        FROM '+ QUOTENAME(@TableName) +' 
        WHERE UniqueReportName = @ReportName ' +
        CASE WHEN LOWER(@siteName) <> 'all' 
             THEN 'AND Site = @SiteName' 
             ELSE '' 
        END 
		 + @WhereCondition +';';
		
		

    -- Execute dynamic SQL with parameters to prevent SQL injection
    EXEC sp_executesql @SQL, 
        N'@ReportName VARCHAR(10), @SiteName VARCHAR(10)', 
        @uniqueReportName, @siteName;

    -- Construct dynamic SQL for ParsedData
    SET @SQL = '
        WITH ParsedData AS (
            SELECT 
                ID AS RecordID,
                CAST(''<X>'' + REPLACE(tabledata, '';;'', ''</X><X>'') + ''</X>'' AS XML) AS DataXML
            FROM '+ QUOTENAME(@TableName) +' 
            WHERE UniqueReportName = @ReportName ' +
            CASE WHEN LOWER(@siteName) <> 'all' 
                 THEN 'AND Site = @SiteName' 
                 ELSE '' 
            END + @WhereCondition + '
        )
        INSERT INTO #tbl (RecordID, FieldName, FieldValue)
        SELECT 
            p.RecordID,
            LEFT(x.value(''.'', ''NVARCHAR(MAX)''), CHARINDEX('':'', x.value(''.'', ''NVARCHAR(MAX)'')) - 1) AS FieldName,
            SUBSTRING(x.value(''.'', ''NVARCHAR(MAX)''), CHARINDEX('':'', x.value(''.'', ''NVARCHAR(MAX)'')) + 1, LEN(x.value(''.'', ''NVARCHAR(MAX)''))) AS FieldValue
        FROM ParsedData p
        CROSS APPLY p.DataXML.nodes(''/X'') AS SplitData(x);';

    -- Execute dynamic SQL for parsing tabledata
    EXEC sp_executesql @SQL, 
        N'@ReportName VARCHAR(10), @SiteName VARCHAR(10)', 
        @uniqueReportName, @siteName;

    -- Generate dynamic column list for pivot
    DECLARE @Columns NVARCHAR(MAX);
    SELECT @Columns = STUFF((
        SELECT DISTINCT ',' + QUOTENAME(FieldName)
        FROM #tbl
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

    -- Construct dynamic pivot SQL
    SET @SQL = '
        SELECT Site, ReportDate, UpdateDate, ' + @Columns + '
        FROM 
        (
            SELECT 
                od.Site,
                od.ReportDate,
                od.UpdateDate,
                t.FieldName,
                t.FieldValue,
                t.RecordID
            FROM #OriginalData od
            INNER JOIN #tbl t ON od.RecordID = t.RecordID
        ) AS SourceData
        PIVOT (
            MAX(FieldValue) FOR FieldName IN (' + @Columns + ')
        ) AS PivotTable
        ORDER BY Site, ReportDate, UpdateDate;';

    -- Execute the dynamic pivot query
    EXEC sp_executesql @SQL;

    -- Clean up temporary tables
    DROP TABLE #tbl;
    DROP TABLE #OriginalData;
END;
