USE [WitronCentralDatabaseSQLServer]
GO
/****** Object:  StoredProcedure [dbo].[AddManagementKPIData]    Script Date: 2025-03-20 10:54:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<FRANK RAMOS>
-- Create date: <2024-12-06>
-- Description:	<ADDS MANAGEMENT KPI REPORT>
-- Parameter: @site -  use as condition to filter site  
-- Parameter: @yearweek -  use as condition to filter yearweek 
-- Parameter: @updatedBy -  user who sent the data post 
-- Parameter: @month -  month where the data belongs to 
-- Parameter: @json - Jsonstring response from our node JS server. the string should contains the "data:" 
 
-- ===============================How to use =============================================
-- exec AddManagementKPIData     
-- =======================================================================================
--Declare @json nvarchar(max)='{"Nbr of Lost Time Accidents":"0","YTD nbr of LT Accidents":"14","Last LT accident date":"12:00:00 AM","Nbr of Days withour LT Accidents":"10","Direct Headcount":"52","Indirect Headcount":"29","Sanitation":"0","Inactive Employees":"4","Mgmt or Salaried Headcount":"16","Total Headcount":"97","Production Work-Hours":"1778","Production Overtime Hrs":"221","Production Overtime Percent":"0.12429696287964","Maintenance Work-Hours":"879","Maintenance Overtime Hrs":"17","Maintenance Overtime Percent":"1.93401592718999E-02","Nbr of Planned Direct Shifts":"179","Nbr of Planned Indirect Shifts":"114","Nbr of Unplanned Absences":"4","Controllable Absenteeism":"1.36518771331058E-02","Employee Turnover":"0","Total COM Cases":"768050","Total FBR Cases":"60601","Total OPM Cases (COM and FBR)":"828651","COL Productivity Rate (COM)":"0.79","COL Avg of Productive Hours (COM)":"5681","FRZ Productivity Rate (COM)":"0.76","FRZ Avg of Productive Hours (COM)":"4054","Cases per Direct Work-Hour":"466.057930258718","Cases per Indirect Work-Hour":"942.720136518771","Downtime or Maintenance Availability":"52","Fault Durations (Daily KPI)":"0.464285714285714","Fault Durations point for  50Percent":"0.464285714285714","Production Training Hrs":"120","Nbr Planned Repairs and Tech. Support":"174","Nbr of Unplanned Repairs":"2","Unplanned Repair Downtime":"270","EM Efficiency (Average)":"0.816077947616577","Nbr of Scheduled PMs":"0","Nbr of Completed PMs":"0","PM Schedule Adherence":"1","Nbr of Trendline Analyses Performed":"6","Trendline Analyses Success Rate":"0.84","Nbr of Completed PM Audits":"6","PM Compliance Rate":"0.92","YTD Completed PMs":"658","Fault Rates (Daily KPI)":"0.785714285714286","Fault Rates point for  50Percent":"0","Maintenance Training Hrs":"11","Spare Parts Value or COM":"170264.23","Spare Parts Value Used":"23218.51","Maintenance Expenses":"4227.55","General or Admin Expenses":"0","Payroll Expenses":"160031.56","Total Expenses":"187477.62","Total Cost per Case":"0.2262"}'
--exec AddManagementKPIData 'WCC','2024-52','Frank','12', @json
-- =============================================
ALTER PROCEDURE [dbo].[AddManagementKPIData]
    @site VARCHAR(10),
    @yearWeek VARCHAR(255), 
    @updatedBy VARCHAR(50),
    @month VARCHAR(2),
    @json NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete existing data first
    DELETE FROM ManagementKPILive
    WHERE site = @site AND YearWeek = @yearWeek;

    -- Insert new data
    INSERT INTO ManagementKPILive (
        [Site],
        [YearWeek],
        [Month],
        [Year],
        [Week],
        [Nbr of Lost Time Accidents],
        [YTD nbr of LT Accidents],
        [Last LT accident date],
        [Nbr of Days without LT Accidents],
        [Direct Headcount],
        [Indirect Headcount],
        [Mgmt or Salaried Headcount],
        [Total Headcount],
        [Production Work-Hours],
        [Production Overtime Hrs],
        [Production Overtime Percent],
        [Maintenance Work-Hours],
        [Maintenance Overtime Hrs],
        [Maintenance Overtime Percent],
        [Nbr of Planned Direct Shifts],
        [Nbr of Planned Indirect Shifts],
        [Nbr of Unplanned Absences],
        [Controllable Absenteeism],
        [Employee Turnover],
        [Total COM Cases],
        [Total FBR Cases],
        [Total OPM Cases (COM and FBR)],
        [Productivity Rate (COM)],
        [Avg of Productive Hours (COM)],
        [COL Productivity Rate (COM)],
        [COL Avg of Productive Hours (COM)],
        [FRZ Productivity Rate (COM)],
        [FRZ Avg of Productive Hours (COM)],
		[Fresh Productivity Rate (COM)],
        [Fresh Avg of Productive Hours (COM)],
		[Produce Productivity Rate (COM)],
        [Produce Avg of Productive Hours (COM)],
        [Cases per Direct Work-Hour],
        [Cases per Indirect Work-Hour],
        [Cases per Total Work-Hour],
        [Downtime or Maintenance Availability],
        [Fault Durations (Daily KPI)],
        [Fault Durations point for  50Percent],
        [Fault Duration Notes],
        [Production Training Hrs],
        [Nbr of Prio 1-3 Tickets Opened],
        [Percent of Prio 1-3 Tickets Closed on Time],
        [Nbr Planned Repairs and Tech. Support],
        [Nbr of Unplanned Repairs],
        [Unplanned Repair Downtime],
        [EM Efficiency (Average)],
        [Nbr of Scheduled PMs],
        [Nbr of Completed PMs],
        [PM Schedule Adherence],
        [Nbr of Trendline Analyses Performed],
        [Trendline Analyses Success Rate],
        [Nbr of Completed PM Audits],
        [PM Compliance Rate],
        [YTD Completed PMs],
        [Fault Rates (Daily KPI)],
        [Fault Rates point for  50Percent],
        [Fault Rate Notes],
        [Maintenance Training Hrs],
        [Spare Parts Value or COM],
        [Spare Parts Value Used],
        [Maintenance Expenses],
        [General or Admin Expenses],
        [Payroll Expenses],
        [Total Expenses],
        [Total Cost per Case],
        [Overall KPI Score],
        [Sanitation],
        [Inactive Employees],
        [DateUpdated],
        [UpdatedBy],
		[Employee Exit]
    )
    SELECT
        @site,
        @yearWeek,
        @month,
        LEFT(@yearWeek, 4),
        RIGHT(@yearWeek, 2),
        TRY_CAST(dbo.GetJsonValue(@json, 'Nbr of Lost Time Accidents') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'YTD nbr of LT Accidents') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Last LT accident date') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Nbr of Days without LT Accidents') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Direct Headcount') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Indirect Headcount') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Mgmt or Salaried Headcount') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Total Headcount') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Production Work-Hours') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Production Overtime Hrs') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Production Overtime Percent') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Maintenance Work-Hours') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Maintenance Overtime Hrs') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Maintenance Overtime Percent') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Nbr of Planned Direct Shifts') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Nbr of Planned Indirect Shifts') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Nbr of Unplanned Absences') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Controllable Absenteeism') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Employee Turnover') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Total COM Cases') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Total FBR Cases') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Total OPM Cases (COM and FBR)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Productivity Rate (COM)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Avg of Productive Hours (COM)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'COL Productivity Rate (COM)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'COL Avg of Productive Hours (COM)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'FRZ Productivity Rate (COM)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'FRZ Avg of Productive Hours (COM)') AS FLOAT),
		TRY_CAST(dbo.GetJsonValue(@json, 'Fresh Productivity Rate (COM)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Fresh Avg of Productive Hours (COM)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Produce Productivity Rate (COM)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Produce Avg of Productive Hours (COM)') AS FLOAT),		
		TRY_CAST(dbo.GetJsonValue(@json, 'Cases per Direct Work-Hour') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Cases per Indirect Work-Hour') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Cases per Total Work-Hour') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Downtime or Maintenance Availability') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Fault Durations (Daily KPI)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Fault Durations point for  50Percent') AS FLOAT),
        dbo.GetJsonValue(@json, 'Fault Duration Notes'),
        TRY_CAST(dbo.GetJsonValue(@json, 'Production Training Hrs') AS FLOAT),
        dbo.GetJsonValue(@json, 'Nbr of Prio 1-3 Tickets Opened'),
        dbo.GetJsonValue(@json, 'Percent of Prio 1-3 Tickets Closed on Time'),
        TRY_CAST(dbo.GetJsonValue(@json, 'Nbr Planned Repairs and Tech. Support') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Nbr of Unplanned Repairs') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Unplanned Repair Downtime') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'EM Efficiency (Average)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Nbr of Scheduled PMs') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Nbr of Completed PMs') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'PM Schedule Adherence') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Nbr of Trendline Analyses Performed') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Trendline Analyses Success Rate') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Nbr of Completed PM Audits') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'PM Compliance Rate') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'YTD Completed PMs') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Fault Rates (Daily KPI)') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Fault Rates point for  50Percent') AS FLOAT),
        dbo.GetJsonValue(@json, 'Fault Rate Notes'),
        TRY_CAST(dbo.GetJsonValue(@json, 'Maintenance Training Hrs') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Spare Parts Value or COM') AS MONEY),
        TRY_CAST(dbo.GetJsonValue(@json, 'Spare Parts Value Used') AS MONEY),
        TRY_CAST(dbo.GetJsonValue(@json, 'Maintenance Expenses') AS MONEY),
        TRY_CAST(dbo.GetJsonValue(@json, 'General or Admin Expenses') AS MONEY),
        TRY_CAST(dbo.GetJsonValue(@json, 'Payroll Expenses') AS MONEY),
        TRY_CAST(dbo.GetJsonValue(@json, 'Total Expenses') AS MONEY),
        TRY_CAST(dbo.GetJsonValue(@json, 'Total Cost per Case') AS MONEY),
        TRY_CAST(dbo.GetJsonValue(@json, 'Overall KPI Score') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Sanitation') AS FLOAT),
        TRY_CAST(dbo.GetJsonValue(@json, 'Inactive Employees') AS FLOAT),
        GETDATE(),
        @updatedBy,
		TRY_CAST(dbo.GetJsonValue(@json, 'Employee Exit') AS FLOAT)	;
END;

