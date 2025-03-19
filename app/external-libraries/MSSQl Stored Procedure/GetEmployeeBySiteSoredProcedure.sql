USE [WitronCentralDatabaseSQLServer]
GO
/****** Object:  StoredProcedure [dbo].[GetEmployeeBySite]    Script Date: 2025-01-16 12:52:31 PM ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Frank Ramos>
-- Create date: <2024-11-29>
-- Description:	<Filter employees in the headcount database>
-- =============================================
ALTER PROCEDURE [dbo].[GetEmployeeBySite] 
    @Site VARCHAR(255),
    @Category VARCHAR(255),
	@OtherCondition varchar (255) =''
AS
BEGIN
    -- Prevent extra result sets from interfering with SELECT statements
    SET NOCOUNT ON;

    DECLARE @sqlStatement NVARCHAR(MAX);

    SET @sqlStatement = 
        CASE 
            WHEN @Category = 'AllNames' THEN 
                N'SELECT EmployeeName, Position,Zone, Site 
                  FROM dbo.HeadcountLive 
                  WHERE Site = @Site 
                  AND Status = ''Active'' 
                  AND Position <> ''''
                  ORDER BY EmployeeName ASC'
            WHEN @Category = 'Management' THEN 
                N'SELECT EmployeeName, Position, Zone , Site 
                  FROM HeadcountLive 
                  WHERE Site = @Site 
                  AND Position IN (''Local Control Center'', ''Production Supervisor'',
				 ''Site Manager'',
				 ''Prodution Manager'',
				 ''Maintenance Manager'',
				 ''Maintenance Team Lead'',
				 ''HR/Admin'',''HR / Admin'',
				 ''Operations Supervisor'',
				 ''Maintenance Supervisor'',
				 ''HR Coordinator'',
				 ''Operations Support'',
				 ''Parts Manager'',
				 ''Continuous Improvement'',
				 ''Health and Safety Specialist'',
				''Regional PLC Leader'',
				''Director of Operation'',
				''National HR Manager'',
				''Director of Operational Excellence'',
				''Regional Maintenance Coordinator'',
				''Maintenance Director for Canada'',
				''Team Lead IT '',
				''Team Lead Commissioning'',
				''Quality Assurance Manager'',
				''Human Resources Coordinator'') 
                  AND Status = ''Active'' 
                  AND Position <> ''''
                  ORDER BY EmployeeName ASC'
			WHEN @Category = 'Technicians' THEN 
                N'SELECT EmployeeName, Position,Zone , Site 
                  FROM HeadcountLive 
                  WHERE Site = @Site                  
			      AND Category LIKE ''Technicians%'' 
                  AND NOT Category = ''Operators'' 
                  AND Status = ''Active'' 
                  ORDER BY EmployeeName ASC'
			WHEN @Category = 'Operators' THEN 
                N'SELECT EmployeeName, Position,Zone , Site 
                  FROM HeadcountLive 
                  WHERE Site = @Site 
                  AND Category Like ''Operator%''					
                  AND Status = ''Active'' 
                  ORDER BY EmployeeName ASC'
			WHEN @Category = 'Supervisors' THEN 
                N'SELECT EmployeeName, Position,Zone  , Site 
                  FROM HeadcountLive 
                  WHERE Site = @Site 
                  AND Category Like ''Supervis%''					
                  AND Status = ''Active'' 
                  OR (Position Like ''%Back%'' AND Site = @Site)
                  ORDER BY EmployeeName ASC'
        END;		 

        

		if lower(@Site)='all' --remove site filter if all
			Begin
				set @sqlStatement = replace(@sqlStatement,'Site =','not Site =')   ;
			end
		 
			 

				EXEC sp_executesql 
				@sqlStatement,
				N'@Site VARCHAR(255)',
				@Site;
			 
    END
    ELSE
    BEGIN
        PRINT 'Invalid category specified.';
    END
END
