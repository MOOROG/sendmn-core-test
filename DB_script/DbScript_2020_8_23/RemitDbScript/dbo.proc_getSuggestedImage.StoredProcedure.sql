USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_getSuggestedImage]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*

S.N.	Actual File Size 	Image resolution (%)	file size
1		2048 KB				15%						222 KB
2		1670 KB 			10%						203 KB
3		900 KB				5%						233 KB
4		890 KB				10%						244 KB
5		879 KB				15%						45 KB
6		845 KB				20%						119 KB
7		807 KB				15%						134 KB
8		775 KB				20%						154 KB
9		730 KB				20%						177 KB
10		718 KB				20%						95 KB
11		711 KB				20%						88 KB
12		599 KB				20%						167 KB
13		566 KB				70%						194 KB
14		514 KB				15%						179 KB
15		458 KB				20%						148 KB
16		438 KB				65%						120 KB
17		432 KB				20%						90 KB
18		424 KB				20%						52 KB
19		404 KB				25%						156 KB
20		267 KB				20%						130 KB
21		204 KB				85%						98 KB
22		157 KB				80%						124 KB
23		154 KB				80%						113 KB

*/
-- exec proc_getSuggestedImage @flag='si',@imgActualSize=879,@imgActualHight=900, @imgActualWidth=900

CREATE proc [dbo].[proc_getSuggestedImage]
(
	@flag				VARCHAR(15) =	NULL
	,@imgActualSize		INT			=	NULL
	,@imgActualHight	INT			=	NULL
	,@imgActualWidth	INT			=	NULL
)
AS

IF @flag='si' -- Suggested Image
BEGIN

-- 0 
	IF @imgActualSize > 2048
	BEGIN
		SELECT 0 errorCode, '222' msg, 10 id
		RETURN	
	END
	
-- 1		2048 KB				15%						222 KB

	IF @imgActualSize BETWEEN 1670 AND 2048
	BEGIN
		SELECT 0 errorCode, '222' msg, 15 id
		RETURN	
	END
		
-- 2		1670 KB 			10%						203 KB

	ELSE IF @imgActualSize BETWEEN 900 AND 1670
	BEGIN
		SELECT 0 errorCode,'203' msg,10 id
		RETURN	
	END
		
-- 3		900 KB				5%						233 KB

	ELSE IF @imgActualSize BETWEEN 890 AND 900
		BEGIN
			SELECT 0 errorCode,'233' msg,5 id
			RETURN	
		END
-- 4		890 KB				10%						244 KB

	ELSE IF @imgActualSize BETWEEN 879 AND 890
		BEGIN
			SELECT 0 errorCode,'244' msg,10 id
			RETURN	
		END
-- 5		879 KB				15%						45 KB

	ELSE IF @imgActualSize BETWEEN 845 AND 879
		BEGIN
			SELECT 0 errorCode,'45' msg,15 id
			RETURN	
		END
-- 6		845 KB				20%						119 KB

	ELSE IF @imgActualSize BETWEEN 807 AND 845
		BEGIN
			SELECT 0 errorCode,'119' msg,20 id
			RETURN	
		END
-- 7		807 KB				15%						134 KB

	ELSE IF @imgActualSize BETWEEN 775 AND 807
		BEGIN
			SELECT 0 errorCode,'134' msg,15 id
			RETURN	
		END
		
-- 8		775 KB				20%						154 KB
	ELSE IF @imgActualSize BETWEEN 730 AND 775
		BEGIN
			SELECT 0 errorCode,'154' msg,20 id
			RETURN	
		END
-- 9		730 KB				20%						177 KB

	ELSE IF @imgActualSize BETWEEN 718 AND 730
		BEGIN
			SELECT 0 errorCode,'177' msg,20 id
			RETURN	
		END
-- 10		718 KB				20%						95 KB
	ELSE IF @imgActualSize BETWEEN 711 AND 718
		BEGIN
			SELECT 0 errorCode,'95' msg,20 id
			RETURN	
		END
-- 11		711 KB				20%						88 KB
	ELSE IF @imgActualSize BETWEEN 599 AND 711
		BEGIN
			SELECT 0 errorCode,'88' msg,20 id
			RETURN	
		END
-- 12		599 KB				20%						167 KB
	ELSE IF @imgActualSize BETWEEN 566 AND 599
		BEGIN
			SELECT 0 errorCode,'167' msg,20 id	
		END
-- 13		566 KB				70%						194 KB
	ELSE IF @imgActualSize BETWEEN 514 AND 566
		BEGIN
			SELECT 0 errorCode,'194' msg,70 id	
		END
-- 14		514 KB				15%						179 KB
	ELSE IF @imgActualSize BETWEEN 458 AND 514
		BEGIN
			SELECT 0 errorCode,'179' msg,15 id	
		END
-- 15		458 KB				20%						148 KB
	ELSE IF @imgActualSize BETWEEN 438 AND 458
		BEGIN
			SELECT 0 errorCode,'148' msg,20 id	
		END
-- 16		438 KB				65%						120 KB
	ELSE IF @imgActualSize BETWEEN 432 AND 438
		BEGIN
			SELECT 0 errorCode,'120' msg,65 id	
		END
-- 17		432 KB				20%						90 KB
	ELSE IF @imgActualSize BETWEEN 424 AND 432
		BEGIN
			SELECT 0 errorCode,'90' msg,20 id	
		END
-- 18		424 KB				20%						52 KB
	ELSE IF @imgActualSize BETWEEN 404 AND 424
		BEGIN
			SELECT 0 errorCode,'52' msg,20 id	
		END
-- 19		404 KB				25%						156 KB
	ELSE IF @imgActualSize BETWEEN 267 AND 404
		BEGIN
			SELECT 0 errorCode,'156' msg,25 id	
		END
-- 20		267 KB				20%						130 KB
	ELSE IF @imgActualSize BETWEEN 204 AND 267
		BEGIN
			SELECT 0 errorCode,'130' msg,20 id	
		END
-- 21		204 KB				85%						98 KB
	ELSE IF @imgActualSize BETWEEN 157 AND 204
		BEGIN
			SELECT 0 errorCode,'98' msg,85 id	
		END
-- 22		157 KB				80%						124 KB
	ELSE IF @imgActualSize BETWEEN 154 AND 157
		BEGIN
			SELECT 0 errorCode,'124' msg,80 id	
		END
-- 23		154 KB				80%						113 KB
	ELSE IF @imgActualSize BETWEEN 1 AND 154
		BEGIN
			SELECT 0 errorCode,'113' msg,80 id	
		END
END




GO
