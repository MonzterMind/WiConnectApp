USE [WitronCentralDatabaseSQLServer]
GO
/****** Object:  StoredProcedure [dbo].[GetUniversalTableBySite]    Script Date: 2025-03-28 5:45:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetUniversalTableBySite]
    @siteName VARCHAR(255),
    @uniqueReportName VARCHAR(50),    
    @OtherCondition VARCHAR(255) = '', -- Optional filter
    @TableName VARCHAR(50) = 'UniversalTableLive' -- Target table
AS
BEGIN
    SET NOCOUNT ON;
	
    -- Validate @TableName (Avoid SQL Injection Risk)
    IF @TableName NOT IN ('UniversalTableLive', 'UniversalTableWiFaultRateLive') 
    BEGIN
        RAISERROR('Invalid table name.', 16, 1);
        RETURN;
    END

    -- Temporary table for storing parsed key-value pairs
    CREATE TABLE #tbl (
        RecordID INT,  
        FieldName NVARCHAR(MAX), 
        FieldValue NVARCHAR(MAX),
        ReportDate DATE,
		[Site] varchar (10)
    );
	
    -- Temporary table for storing original data
    CREATE TABLE #OriginalData (
        RecordID INT,
        Site NVARCHAR(255),
        ReportDate DATE,
        UpdateDate DATE
    );

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @WhereCondition NVARCHAR(255) = '';
	 
    -- Check if @OtherCondition contains "year" and extract the year dynamically
    IF CHARINDEX('year=', LOWER(@OtherCondition)) > 0
    BEGIN
        SET @WhereCondition = ' AND YEAR(ReportDate) = ' + 
            STUFF(@OtherCondition, 1, CHARINDEX('=', @OtherCondition), '');
    END
	
	ELSE IF CHARINDEX('reportdate>=', LOWER(@OtherCondition)) > 0 
    AND CHARINDEX('reportdate<=', LOWER(@OtherCondition)) > 0  -- between condition
	BEGIN
		SET @WhereCondition = ' AND ' + @OtherCondition
		
	END
	
	--- add more condition in the future if needed
    -- Construct dynamic SQL for inserting into #OriginalData
    SET @SQL = '
    INSERT INTO #OriginalData (RecordID, Site, ReportDate, UpdateDate)
    SELECT ID, Site, ReportDate, UpdateDate
    FROM ' + QUOTENAME(@TableName) + ' 
    WHERE UniqueReportName = @ReportName ' +
    CASE 
        WHEN LOWER(@siteName) <> 'all'
            THEN 
                CASE 
                    WHEN CHARINDEX(',', @siteName) > 0 
                        THEN ' AND Site IN (' + '''' + REPLACE(@siteName, ',', ''',''') + '''' + ')'
                        ELSE ' AND Site = @SiteName'
                END
        ELSE ''
    END + 
       @WHERECONDITION + ';';
	 

    EXEC sp_executesql @SQL, 
        N'@ReportName VARCHAR(50), @SiteName VARCHAR(255)', 
        @uniqueReportName, @siteName;

    -- Construct dynamic SQL for parsing data and inserting into #tbl
    SET @SQL = '
        WITH ParsedData AS (
            SELECT 
                ID AS RecordID,
                CAST(''<X>'' + REPLACE(tabledata, '';;'', ''</X><X>'') + ''</X>'' AS XML) AS DataXML,
                ReportDate,
				Site
            FROM ' + QUOTENAME(@TableName) + '
            WHERE UniqueReportName = @ReportName ' +
            CASE 
                WHEN LOWER(@siteName) <> 'all'
                    THEN 
                        CASE 
                            WHEN CHARINDEX(',', @siteName) > 0 
                                THEN ' AND Site IN (' + '''' + REPLACE(@siteName, ',', ''',''') + '''' + ')'
                                ELSE ' AND Site = @SiteName'
                        END
                ELSE ''
            END + @WhereCondition + '
        )
        INSERT INTO #tbl (RecordID, FieldName, FieldValue, ReportDate,Site)
        SELECT  
            p.RecordID,
            LEFT(x.value(''.'', ''NVARCHAR(MAX)''), CHARINDEX('':'', x.value(''.'', ''NVARCHAR(MAX)'')) - 1) AS FieldName,
            SUBSTRING(x.value(''.'', ''NVARCHAR(MAX)''), CHARINDEX('':'', x.value(''.'', ''NVARCHAR(MAX)'')) + 1, LEN(x.value(''.'', ''NVARCHAR(MAX)''))) AS FieldValue,
            ReportDate,
			Site
        FROM ParsedData p
        CROSS APPLY p.DataXML.nodes(''/X'') AS SplitData(x);';

    EXEC sp_executesql @SQL, 
        N'@ReportName VARCHAR(50), @SiteName VARCHAR(255)', 
        @uniqueReportName, @siteName;

    -- Generate dynamic column list for the pivot
    DECLARE @Columns NVARCHAR(MAX);
    SELECT @Columns = STUFF((SELECT DISTINCT ',' + QUOTENAME(FieldName)
                            FROM #tbl
                            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

    -- Construct dynamic pivot SQL to combine all rows by report date
    -- Construct dynamic pivot SQL to combine all rows by report date without extra GROUP BY
SET @SQL = '
    SELECT ReportDate,Site as Site, ''' + @uniqueReportName +''' as FaultIdent, '+ @Columns + '
    FROM (
        SELECT 
            t.ReportDate,
            t.FieldName,
            t.FieldValue,
			t.Site
        FROM #tbl t
    ) AS SourceData
    PIVOT (
        MAX(FieldValue) FOR FieldName IN (' + @Columns + ')
    ) AS PivotTable
    ORDER BY ReportDate;';  -- Removed GROUP BY and kept ordering


    EXEC sp_executesql @SQL;

    -- Clean up temporary tables
    DROP TABLE #tbl;
    DROP TABLE #OriginalData;
END;
