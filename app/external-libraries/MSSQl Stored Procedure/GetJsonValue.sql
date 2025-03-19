USE [WitronCentralDatabaseSQLServer]
GO

/****** Object:  UserDefinedFunction [dbo].[GetJsonValue]    Script Date: 2024-12-24 12:05:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<FRANK RAMOS>
-- Create date: <2024-12-24>
-- Description:	JSON_Value is not supported on SQLsever 2012 so we create our own function
-- Parameter: @json - the whole json string
-- Parameter: @key - search for json string

-- ===============================How to use =============================================
--DECLARE @json NVARCHAR(MAX) = '{"Nbr of Lost Time Accidents":"0","YTD nbr of LT Accidents":"14","Last LT accident date":"12:00:00 AM","Nbr of Days w/o LT Accidents":"10","Direct Headcount":"52","Indirect Headcount":"29","Sanitation":"0","Inactive Employees":"4","Mgmt/Salaried Headcount":"16","Total Headcount":"97","Production Work-Hours":"1778","Production Overtime Hrs":"221","Production Overtime %":"0.12429696287964"}';
--SELECT dbo.GetJsonValue(@json, 'Nbr of Lost Time Accidents') AS [Nbr of Lost Time Accidents],
--dbo.GetJsonValue(@json, 'YTD nbr of LT Accidents') AS [YTD nbr of LT Accidents],
-- =======================================================================================
-- =============================================

ALTER FUNCTION [dbo].[GetJsonValue]
(
    @json NVARCHAR(MAX),
    @key NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @value NVARCHAR(MAX);
    DECLARE @startIndex INT;
    DECLARE @endIndex INT;

    -- Locate the key in the JSON string
    SET @startIndex = CHARINDEX('"' + @key + '":', @json) +1;

    -- If the key exists
    IF @startIndex > 0
    BEGIN
        -- Move to the start of the value (after the key and the `":"`)
        SET @startIndex = @startIndex + LEN(@key) + 3;

        -- Locate the end of the value
        SET @endIndex = CHARINDEX('"', @json, @startIndex);

        -- Extract the value between the start and end positions
        SET @value = SUBSTRING(@json, @startIndex, @endIndex - @startIndex);
    END
    ELSE
    BEGIN
        SET @value = NULL; -- Key not found
    END

    RETURN @value;
END;
GO


