USE [WitronCentralDatabaseSQLServer]
GO
/****** Object:  StoredProcedure [dbo].[AddProductionMetrics]    Script Date: 2025-03-05 7:43:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<FRANK RAMOS>
-- Create date: <2025-02-26>
-- Description:	<ADDS Production metrics for CAN - President Dashboard>
-- Parameters :  @SITE, @ConvertedReportDate, @COMHours, @Volume, @CustomerDownTime, @PercentageProductiveHours, @NonConformanceCount, @LateRoutes, @ScratchRate, @UpdatedBy fielrs
-- ===============================How to use =============================================
--EXEC AddProductionMetrics 
--    @site = 'CAN',
--    @reportDate = '2025-02-25',
--    @COMHours = Null, -- Skipped
--    @Volume = 0, -- Skipped
--    @CustomerDownTime = NULL, -- Skipped
--    @PercentageProductiveHours = 95.5, -- Will be updated
--    @NonConformanceCount = 0, -- Skipped
--    @LateRoutes = 1, -- Will be updated
--    @ScratchRate = 0.2, -- Will be updated
--    @UpdatedBy = 'Frank'; -- Will be updated
-- =============================================
ALTER PROCEDURE [dbo].[AddProductionMetrics]
    @site VARCHAR(10),    
    @reportDate VARCHAR(50),
    @COMHours int,
	@Volume int,
	@CustomerDownTime int,
	@PercentageProductiveHours float,
	@NonConformanceCount int,
	@LateRoutes int,
	@ScratchRate float,
	@UpdatedBy varchar(50)


AS
BEGIN
   DECLARE @EXISTS INT
   DECLARE @ConvertedReportDate DATE = TRY_CAST(@reportDate AS DATE);
   SELECT @EXISTS=COUNT(*) FROM ProductionMetricsLive WHERE [SITE]=@SITE AND REPORTDATE=@ConvertedReportDate;
  
   IF @EXISTS = 0  
   BEGIN
	--  SNAPSHOT OF THE HEADCOUNT FOR THAT CU
	DECLARE @OPERATORS INT;
	SELECT @OPERATORS = COUNT(*) FROM HEADCOUNTLIVE WHERE [SITE]=@SITE AND CATEGORY IN('OPERATION','OPERATORS','PRODUCTION') and [status]='Active';
	INSERT INTO  ProductionMetricsLive  ([SITE],REPORTDATE,UPDATEDBY,HeadCountDirect) VALUES (@SITE,@ConvertedReportDate,@UPDATEDBY,@OPERATORS);
   END
    --UPDATE FIELDS DYNAMICALLY
	  DECLARE @SQL NVARCHAR(MAX)='UPDATE ProductionMetricsLive SET ';
	  DECLARE @Params NVARCHAR(MAX) = '';
	IF @COMHours IS NOT NULL  SET @SQL = @SQL + 'COMHours = @COMHours, ';
    IF @Volume IS NOT NULL SET @SQL = @SQL + 'Volume = @Volume, ';
    IF @CustomerDownTime IS NOT NULL  SET @SQL = @SQL + 'CustomerDownTime = @CustomerDownTime, ';
    IF @PercentageProductiveHours IS NOT NULL  SET @SQL = @SQL + 'PercentageProductiveHours = @PercentageProductiveHours, ';
    IF @NonConformanceCount IS NOT NULL  SET @SQL = @SQL + 'NonConformanceCount = @NonConformanceCount, ';
    IF @LateRoutes IS NOT NULL  SET @SQL = @SQL + 'LateRoutes = @LateRoutes, ';
    IF @ScratchRate IS NOT NULL  SET @SQL = @SQL + 'ScratchRate = @ScratchRate, '; 
	IF @UpdatedBy IS NOT NULL  SET @SQL = @SQL + 'UpdatedBy = @UpdatedBy, ';     
	 -- Remove last comma **only if columns were added**
	  
    IF CHARINDEX('=', @SQL) > 0
    BEGIN
	 
        SET @SQL = LEFT(@SQL, LEN(@SQL) - 1); -- Remove last comma
        SET @SQL = @SQL + ' WHERE [SITE] = @SITE AND REPORTDATE = @ConvertedReportDate;';
		--PRINT @SQL; -- Debugging: Print SQL before execution
        -- Execute dynamic SQL
       
        EXEC sp_executesql @SQL, 
            N'@SITE VARCHAR(10), @ConvertedReportDate DATE, @COMHours INT, @Volume INT, 
              @CustomerDownTime INT, @PercentageProductiveHours FLOAT, @NonConformanceCount INT, 
              @LateRoutes INT, @ScratchRate FLOAT, @UpdatedBy VARCHAR(50)',
            @SITE, @ConvertedReportDate, @COMHours, @Volume, @CustomerDownTime, 
            @PercentageProductiveHours, @NonConformanceCount, @LateRoutes, @ScratchRate, @UpdatedBy;
    END
    
END;

