/****** Object:  StoredProcedure [dbo].[AddmMasterdataReport]    Script Date: 2025-02-18 8:42:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<FRANK RAMOS>
-- Create date: <2024-12-06>
-- Description:	<ADDS Masterdata report>
-- Parameter: @site -  use as condition to filter site  
-- Parameter: @reportDate -  use as condition to filter date 
-- Parameter: @json - Jsonstring response from our node JS server. the string should contains the "data:" 
-- ===============================How to use =============================================
-- declare @json nvarchar(max)
--DECLARE @DateParam DATE = '2025-02-28'
--set @json ='"data":{"OP43COMAlignmentStationProblems":"0", "OP43NoReads":"0", "PR04DepalTrayMergeFaults":"0", "PR04DepalSTPNotClear":"0", "OP33TrayLoadingCorrections":"0", "OP33SentToClearing":"0", "OP34TrayLoadingIssues":"0", "TiHiIssues":"0", "CreateSupplierVersion":"0", "DamagedCases":"0", "DifferentPackaging":"0", "DimensionAdjustment":"0", "FaultyCorrectionTrayMerge":"0", "OpenFlaps":"0", "ProductTipsOver":"0", "WrongOrientation":"0", "WrongProduct":"0", "WrongVersion":"0"}'
--Exec AddmMasterdataReport 'Test', @DateParam,@json   
-- =======================================================================================


ALTER PROCEDURE [dbo].[AddmMasterdataReport]
    @site VARCHAR(10),
    @reportDate varchar(15), 
    @json NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
	Declare @rdate date
	set @rdate=CAST(@reportDate AS DATE)
    -- Delete existing data first
    DELETE FROM MasterDataLive
    WHERE site = @site AND reportdate = @rdate;

    -- Insert new data
    INSERT INTO MasterDataLive (
       [Site]
      ,[ReportDate]
      ,[AdminName]
      ,[OP43COMAlignmentStationProblems]
      ,[OP43NoReads]
      ,[PR04DepalTrayMergeFaults]
      ,[PR04DepalSTPNotClear]
      ,[OP33TrayLoadingCorrections]
      ,[OP33SentToClearing]
      ,[OP34TrayLoadingIssues]
      ,[TiHiIssues]
      ,[CreateSupplierVersion]
      ,[DamagedCases]
      ,[DifferentPackaging]
      ,[DimensionAdjustment]
      ,[FaultyCorrectionTrayMerge]
      ,[OpenFlaps]
      ,[ProductTipsOver]
      ,[WrongOrientation]
      ,[WrongProduct]
      ,[WrongVersion]
    )
    SELECT
        @site,
        @rdate, 
		dbo.GetJsonValue(@json, 'AdminName'),    
        TRY_CAST(dbo.GetJsonValue(@json, 'OP43COMAlignmentStationProblems') AS INT),
        TRY_CAST(dbo.GetJsonValue(@json, 'OP43NoReads') AS INT),
		TRY_CAST(dbo.GetJsonValue(@json, 'PR04DepalTrayMergeFaults') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'PR04DepalSTPNotClear') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'OP33TrayLoadingCorrections') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'OP33SentToClearing') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'OP34TrayLoadingIssues') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'TiHiIssues') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'CreateSupplierVersion') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'DamagedCases') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'DifferentPackaging') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'DimensionAdjustment') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'FaultyCorrectionTrayMerge') AS INT) ,	
		TRY_CAST(dbo.GetJsonValue(@json, 'OpenFlaps') AS INT) ,			 
		TRY_CAST(dbo.GetJsonValue(@json, 'ProductTipsOver') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'WrongOrientation') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'WrongProduct') AS INT) ,
		TRY_CAST(dbo.GetJsonValue(@json, 'WrongVersion') AS INT) 		 
		 ;
END;

