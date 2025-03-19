
/****** Object:  StoredProcedure [dbo].[GetLotoHarnessBySite] Script Date: 17/12/2024 12:20:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:        Frank Ramos
-- Create date:   2024-12-17
-- Description:   Get LOTO/Harness data by site. 
-- @Site: filter table by site If site is empty, select all data.               
-- @OtherCondition: we might use this in the future
-- =============================================
ALTER PROCEDURE [dbo].[GetLotoHarnessBySite] 
    @Site VARCHAR(255),
    @OtherCondition VARCHAR(255) = ''
AS
BEGIN
    SET NOCOUNT ON;
    SET ROWCOUNT 0;
    IF lower(@Site) = 'all' 
    BEGIN
        SELECT * 
        FROM [Loto-HarnessLive];
    END
    ELSE
    BEGIN
        SELECT * 
        FROM [Loto-HarnessLive] 
        WHERE [Site] = @Site;
    END
END
GO

