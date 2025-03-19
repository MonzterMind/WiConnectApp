/****** Object:  StoredProcedure [dbo].[GetMasterDataReportBySite]    Script Date: 2025-02-18 9:03:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:        Frank Ramos
-- Create date:   2025-02-14
-- Description:   Get Masterdata data by site. 
-- @Site: filter table by site If site is empty, select all data.               
-- @OtherCondition: we might use this in the future
-- =============================================
ALTER PROCEDURE [dbo].[GetMasterDataReportBySite] 
    @Site VARCHAR(255),
    @OtherCondition VARCHAR(255) = ''
AS
BEGIN
    SET NOCOUNT ON;
	SET ROWCOUNT 0;
    IF lower(@Site) = 'all' 
    BEGIN
        SELECT * 
        FROM MasterDataLive;
    END
    ELSE
    BEGIN
        SELECT * 
        FROM MasterDataLive 
        WHERE [Site] = @Site;
    END
END
