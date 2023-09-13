

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


