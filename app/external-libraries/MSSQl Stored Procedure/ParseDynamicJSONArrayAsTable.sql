-- =============================================
-- Author:		<Ramos , Frank>
-- Create date: <2024-12-04>
-- Description:	<MSSQL2012 doesn't have the OPENJSON() function so we have to create a store procedure >
-- Parameter: @json - Jsonstring response from our node JS server. the string should contains the "data:" 
-- Parameter: @showfields - optional , filter fields to show
-- ===============================How to use =============================================
-- DECLARE @json NVARCHAR(MAX) = '{"status":true,"data":[[{"EmployeeName":"Adelakun, Isaac","Position":"Local Control Center","Zone":"DRY"},{"EmployeeName":"Belaou, Salek","Position":"Production Manager","Zone":"DRY"},{"EmployeeName":"Boulet, Mike","Position":"Maintenance Manager","Zone":"DRY"},{"EmployeeName":"Gilberg, Shianne","Position":"HR/Admin","Zone":"DRY"},{"EmployeeName":"Hussain, Alam","Position":"Production Supervisor","Zone":"DRY"},{"EmployeeName":"Idowu, Seeni","Position":"Production Supervisor","Zone":"DRY"},{"EmployeeName":"Javier, Christian","Position":"Site Manager","Zone":"DRY"},{"EmployeeName":"Leinweber, Lane","Position":"Local Control Center","Zone":"DRY"},{"EmployeeName":"Manalo, Jerome","Position":"Production Supervisor","Zone":"DRY"},{"EmployeeName":"Olaniyi, Chris","Position":"Production Supervisor","Zone":"DRY"},{"EmployeeName":"Rivas, Juan","Position":"Production Supervisor","Zone":"DRY"},{"EmployeeName":"Virrey, Jose ","Position":"Production Supervisor","Zone":"DRY"}],0],"message":"Employees masterdata found successfully for site CY."}';
-- EXEC dbo.ParseDynamicJSONArrayAsTable @json;
-- =======================================================================================
CREATE PROCEDURE [dbo].[ParseDynamicJSONArrayAsTable]
(
    @json NVARCHAR(MAX),
    @ShowFields NVARCHAR(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Sanitize JSON: Remove encoded carriage returns (&#x0D;) and line feeds (&#x0A;)
    SET @json = REPLACE(@json, '&#x0D;', '');
    SET @json = REPLACE(@json, '&#x0A;', '');

    -- Create a temporary table to store parsed data
    CREATE TABLE #ParsedTable
    (
        [RowIndex] INT,
        [Key] NVARCHAR(MAX),
        [Value] NVARCHAR(MAX)
    );

    DECLARE @pos INT = 1;
    DECLARE @length INT = LEN(@json);
    DECLARE @rowID INT = 0;
    DECLARE @key NVARCHAR(MAX);
    DECLARE @value NVARCHAR(MAX);

    -- Check if 'data' section exists
    IF CHARINDEX('"data":', @json) > 0
    BEGIN
        -- Extract 'data' section from JSON
        SET @json = SUBSTRING(@json, CHARINDEX('"data":', @json) + 7, LEN(@json));

        -- Check if 'data' is an array or an object
        IF SUBSTRING(@json, 1, 1) = '['
        BEGIN
            -- 'data' is an array, continue as before
            SET @json = SUBSTRING(@json, 1, CHARINDEX(']', @json) + 1); -- Extract up to closing ]
        END
        ELSE
        BEGIN
            -- 'data' is a single object, treat it as an array with one element
            SET @json = '[' + @json + ']';
        END;
    END;

    -- Parse the JSON array
    WHILE @pos <= LEN(@json)
    BEGIN
        IF SUBSTRING(@json, @pos, 1) = '{'
        BEGIN
            -- Parse object in array
            SET @rowID = @rowID + 1;

            DECLARE @object NVARCHAR(MAX);
            SET @object = SUBSTRING(@json, @pos, CHARINDEX('}', @json, @pos) - @pos + 1);
            SET @pos = CHARINDEX('}', @json, @pos) + 1;

            -- Parse key-value pairs in the object
            DECLARE @innerPos INT = 1;
            DECLARE @innerLength INT = LEN(@object);

            WHILE @innerPos < @innerLength
            BEGIN
                -- Extract key
                SET @key = LTRIM(RTRIM(REPLACE(REPLACE(
                    SUBSTRING(@object, CHARINDEX('"', @object, @innerPos) + 1,
                              CHARINDEX('"', @object, CHARINDEX('"', @object, @innerPos) + 1) 
                              - CHARINDEX('"', @object, @innerPos) - 1),
                    CHAR(13), ''), CHAR(10), ''))); -- Remove any CR or LF

                SET @innerPos = CHARINDEX(':', @object, @innerPos) + 1;

                -- Extract value
                IF SUBSTRING(@object, @innerPos, 1) = '"'
                BEGIN
                    SET @value = SUBSTRING(@object, @innerPos + 1, CHARINDEX('"', @object, @innerPos + 1) - @innerPos - 1);
                    SET @innerPos = CHARINDEX('"', @object, @innerPos + 1) + 1;
                END
                ELSE
                BEGIN
                    SET @value = SUBSTRING(@object, @innerPos, CHARINDEX(',', @object + ',', @innerPos) - @innerPos);
                    SET @innerPos = CHARINDEX(',', @object + ',', @innerPos) + 1;
                END;

                IF @ShowFields IS NULL
                BEGIN
                    -- Insert parsed data into the temporary table
                    INSERT INTO #ParsedTable ([RowIndex], [Key], [Value])
                    VALUES (@rowID, @key, @value);
                END
                ELSE
                BEGIN
                    -- Check if @ShowFields contains @key
                    IF CHARINDEX(@key, @ShowFields) > 0
                    BEGIN
                        -- Insert parsed data into the temporary table
                        INSERT INTO #ParsedTable ([RowIndex], [Key], [Value])
                        VALUES (@rowID, @key, @value);
                    END
                END
            END;
        END
        ELSE
        BEGIN
            -- Move to the next JSON element
            SET @pos = @pos + 1;
        END;
    END;

    -- Build Dynamic Pivot Query using FOR XML PATH (for SQL Server 2012 compatibility)
    DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX);
    DECLARE @sortedColumns NVARCHAR(MAX);

    -- Get distinct keys to use as column names (sanitize and trim keys)
    SELECT @columns = STUFF(( 
        SELECT ',' + QUOTENAME(LTRIM(RTRIM(REPLACE(REPLACE([Key], CHAR(13), ''), CHAR(10), ''))))
        FROM (SELECT DISTINCT [Key] FROM #ParsedTable) AS Keys
        FOR XML PATH('') 
    ), 1, 1, '');

    -- If @ShowFields is provided, order the columns based on it
    IF @ShowFields IS NOT NULL
    BEGIN
        -- Create a sorted list of columns based on @ShowFields
        SET @sortedColumns = '';
        DECLARE @field NVARCHAR(MAX);
        DECLARE @start INT = 1;
        DECLARE @end INT;

        WHILE @start <= LEN(@ShowFields)
        BEGIN
            SET @end = CHARINDEX(',', @ShowFields + ',', @start);
            SET @field = LTRIM(RTRIM(SUBSTRING(@ShowFields, @start, @end - @start)));

            IF CHARINDEX(@field, @columns) > 0
            BEGIN
                SET @sortedColumns = @sortedColumns + QUOTENAME(@field) + ',';
            END

            SET @start = @end + 1;
        END

        -- Remove the last comma
        SET @sortedColumns = LEFT(@sortedColumns, LEN(@sortedColumns) - 1);
    END
    ELSE
    BEGIN
        -- Use the default column order (from the query)
        SET @sortedColumns = @columns;
    END

    -- Create dynamic SQL for pivot
    SET @sql = '
        SELECT RowIndex, ' + @sortedColumns + '
        FROM (
            SELECT RowIndex, [Key], [Value]
            FROM #ParsedTable
        ) AS SourceTable
        PIVOT (
            MAX([Value])
            FOR [Key] IN (' + @sortedColumns + ')
        ) AS PivotTable
        ORDER BY RowIndex;
    ';

    -- Execute the dynamic SQL
    EXEC sp_executesql @sql;

    -- Drop the temporary table after use
    DROP TABLE #ParsedTable;
END;


GO


