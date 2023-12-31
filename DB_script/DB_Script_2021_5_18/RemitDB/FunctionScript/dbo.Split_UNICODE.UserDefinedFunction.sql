USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[Split_UNICODE]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[Split_UNICODE] (@delimeter CHAR(1), @list NVARCHAR(4000))
RETURNS TABLE
AS
RETURN (
    WITH Pieces(pn, start, stop) AS (
      SELECT 1, 1, CHARINDEX(@delimeter, @list)
      UNION ALL
      SELECT pn + 1, stop + 1, CHARINDEX(@delimeter, @list, stop + 1)
      FROM Pieces
      WHERE stop > 0
    )
    SELECT pn id,
      SUBSTRING(@list, start, CASE WHEN stop > 0 THEN stop-start ELSE 8000 END) AS value
    FROM Pieces
  )


GO
