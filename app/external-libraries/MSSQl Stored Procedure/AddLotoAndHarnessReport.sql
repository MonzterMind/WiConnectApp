USE [WitronCentralDatabaseSQLServer]
GO
/****** Object:  StoredProcedure [dbo].[AddLotoAndHarnessReport]    Script Date: 17/12/2024 2:48:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<FRANK RAMOS>
-- Create date: <2024-12-06>
-- Description:	<ADDS OR LOTO AND HARNESS REPORT>
-- Parameter: @site - include the site on the insert sql statement
-- Parameter: @supervisorName - nclude the site on the insert sql statement
-- Parameter: @reportDate - nclude the site on the insert sql statement
-- Parameter: @shift - include the site on the sql statemnt
-- Parameter: @json - Jsonstring response from our node JS server. the string should contains the "data:" 
-- Parameter: @showfields - optional , filter fields to show
-- ===============================How to use =============================================
-- exec AddLotoAndHarnessReport   'CY','Frank','2024-12-17','Day', '"data":[[{"EMPLOYEE":"Abdelaal, Amer","LOCATION":"STREMA","LOTO or HARNESS":"LOTO","YES/NO":"YES/OUI","COMMENTS":"HELLO WORLD TEST","ROWID":"10-Ahogle, Brayan45618"},{"EMPLOYEE":"Araujo Medina, Robert","LOCATION":"COMS","LOTO or HARNESS":"BOTH/LES DEUX","YES/NO":"YES/OUI","COMMENTS":"HELLO WORLD TEST","ROWID":"11-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"12-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"13-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"14-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"15-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"16-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"17-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":
-- "","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"18-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"19-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"20-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"21-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"22-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"23-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"24-Ahogle, Brayan45618"},{"EMPLOYEE":"","LOCATION":"","LOTO or HARNESS":"","YES/NO":"","COMMENTS":"","ROWID":"25-Ahogle, Brayan45618"}],0]
--' ,'RowIndex,employee,location,loto / harness,yes/no,comments,rowid'
-- =======================================================================================
-- =============================================
ALTER PROCEDURE [dbo].[AddLotoAndHarnessReport]
    @site VARCHAR(5),
    @supervisorName VARCHAR(255),
    @reportDate VARCHAR(50),
    @shift VARCHAR(50),
    @json NVARCHAR(MAX),
    @fieldstoshow VARCHAR(MAX)
AS
BEGIN
    -- Prevent extra result sets
    SET NOCOUNT ON;

    -- Temporary table to hold parsed JSON data
    CREATE TABLE #TAB
    (
        RowIndex INT,
        [employee] NVARCHAR(MAX),
        [location] NVARCHAR(MAX),
        [LOTO / HARNESS] NVARCHAR(MAX),
        [yes/no] NVARCHAR(MAX),
        [comments] NVARCHAR(MAX),
        [rowid] NVARCHAR(MAX)
    );

    -- Parse JSON data into the temporary table
    INSERT INTO #TAB
    EXEC ParseDynamicJSONArrayAsTable @json, @fieldstoshow;

    -- Declare variables for row counts
    DECLARE @InsertedRecord INT, @UpdatedRecord INT;

    -- Start a transaction
    BEGIN TRANSACTION;

    -- Update existing records in the target table
    UPDATE [Loto-HarnessLive]
    SET 
        [site] = @site,
        [supervisorname] = @supervisorName,
        [reportdate] = CAST(@reportDate AS DATE),
        [employeename] = t.[employee],
        [location] = t.[location],
        [lotoharness] = t.[LOTO / HARNESS],
        [yesno] = t.[yes/no],
        [comments] = t.[comments],
        [DateUpdated] = GETDATE(),
        [shift] = @shift
    FROM 
        [Loto-HarnessLive] l
    INNER JOIN 
        #TAB t
    ON 
        l.[rowid] = t.[rowid];

    -- Capture the number of rows updated
    SET @UpdatedRecord = @@ROWCOUNT;

    -- Insert new records into the target table
    INSERT INTO [Loto-HarnessLive] 
        ([site], [supervisorname], [reportdate], [employeename], [location], [lotoharness], [yesno], [comments], [rowid], [DateUpdated], [shift])
    SELECT 
        @site, 
        @supervisorName, 
        CAST(@reportDate AS DATE), 
        [employee], 
        [location], 
        [LOTO / HARNESS], 
        [yes/no], 
        [comments], 
        [rowid], 
        GETDATE(), 
        @shift
    FROM 
        #TAB
    WHERE 
        [employee] <> ''
        AND [rowid] NOT IN (
            SELECT [rowid] 
            FROM [Loto-HarnessLive] 
            WHERE [rowid] IS NOT NULL
        );

    -- Capture the number of rows inserted
    SET @InsertedRecord = @@ROWCOUNT;
	-- delete record if employee is empty. This scenario is due to an update with the report on the same date and supervisor
	--we are assuming that the supervisor made a correction and the new data has less rows
	Delete from [Loto-HarnessLive] where [employeename] is null or LTRIM(RTRIM(EmployeeName))=''

    -- Commit the transaction
    COMMIT;

    -- Clean up temporary table
    DROP TABLE #TAB;

    -- Return the number of inserted and updated records
    SELECT 
        @InsertedRecord AS NoOfInsertedRecords,
        @UpdatedRecord AS NoOfUpdatedRecords;
END;

