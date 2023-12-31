USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetmodulewiseMenu]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_GetmodulewiseMenu]
@module VARCHAR(500),
@Isadmin	BIT = 0
as
set nocount on;
IF OBJECT_ID('tempdb..#temp') IS NOT NULL
    DROP TABLE #temp;

IF OBJECT_ID('tempdb..#parent') IS NOT NULL
    DROP TABLE #parent;

SET NOCOUNT ON;

--DECLARE @module VARCHAR(50)= 10;
--DECLARE @module VARCHAR(50)= 'Transaction';

SELECT  f.functionId ,
        f.parentFunctionId ,
        f.functionName ,
        menuName ,
        linkPage ,
        menuGroup ,
        Module ,
        groupPosition ,
        m.AgentMenuGroup
INTO    #temp
FROM    dbo.applicationMenus m
        INNER JOIN dbo.applicationFunctions f ON m.functionId = f.parentFunctionId
WHERE   menuGroup IN (SELECT VALUE FROM dbo.split(',',@module))
AND    ISNULL(AgentMenuGroup,'A') = CASE @Isadmin WHEN 0 THEN 'A' ELSE ISNULL(AgentMenuGroup,'') END
ORDER BY menuGroup;

--SELECT * FROM #temp

SELECT DISTINCT
        parentFunctionId ,
        menuName ,
        linkPage ,
        menuGroup ,
        Module ,
        groupPosition ,
        AgentMenuGroup
INTO    #parent
FROM    #temp;

ALTER TABLE #parent ADD id INT IDENTITY(1,1);
--SELECT * FROM #parent

DECLARE @cnt INT ,
    @num INT = 1;

SELECT  @cnt = COUNT(*)
FROM    #parent;

DECLARE @ViewFunctionId VARCHAR(500) ,
    @menuName VARCHAR(500) ,
    @menuDescription VARCHAR(500) ,
    @linkPage VARCHAR(500) ,
    @menuGroup VARCHAR(500) ,
    @AgentMenuGroup VARCHAR(500);

DECLARE @menuList VARCHAR(MAX)= '' ,
    @menuFunctionList VARCHAR(MAX)= '';

DECLARE @menus TABLE ( menus VARCHAR(MAX) );

WHILE @cnt >= @num
    BEGIN
		
        SELECT  @ViewFunctionId = parentFunctionId ,
				@module = Module,
                @menuName = menuName ,
                @menuDescription = 'Menu for: ' + menuName ,
                @linkPage = linkPage ,
                @menuGroup = menuGroup ,
                @AgentMenuGroup = AgentMenuGroup
        FROM    #parent
        WHERE   ID = @num;

        INSERT  INTO @menus
                SELECT  '  EXEC proc_addMenu ''' + @module + ''' ,'''
                        + @ViewFunctionId + ''',''' + @menuName + ''','''
                        + @menuDescription + ''',''' + @linkPage + ''','''
                        + @menuGroup + ''',''' + CAST(@num AS VARCHAR)
                        + ''',''' + 'Y'',''' + @module + ''','''
                        + ISNULL(@AgentMenuGroup,'') + '''';
	--SET @menuList += CHAR(13)+CHAR(10)+ '  EXEC proc_addMenu '''+@module+''' ,'''+ @ViewFunctionId+''','''+ @menuName+''','''+ @menuDescription+''','''+ @linkPage+''','''+ @menuGroup+''','''+ CAST(@num AS VARCHAR)+''','''+ 'Y'','+@module

        SET @num = @num + 1;
    END;

SELECT  *
FROM    @menus;
ALTER TABLE #temp ADD id INT IDENTITY(1,1);

SELECT  @cnt = COUNT(*) ,
        @num = 1
FROM    #temp;

DECLARE @FunctionId VARCHAR(100) ,
    @funcName VARCHAR(100);

DECLARE @menuFunction TABLE ( menus VARCHAR(MAX) );

WHILE @cnt >= @num
    BEGIN
        SELECT  @ViewFunctionId = parentFunctionId ,
                @FunctionId = functionId ,
                @funcName = functionName
        FROM    #temp
        WHERE   ID = @num;

        INSERT  INTO @menuFunction
                SELECT  ' EXEC proc_AddFunction''' + @FunctionId + ''','''
                        + @ViewFunctionId + ''',''' + @funcName + '''';
	--SET @menuFunctionList +=CHAR(13)+CHAR(10)+ ' EXEC proc_AddFunction'''+ @FunctionId+''','''+@ViewFunctionId+''','''+ @funcName+''''

        SET @num = @num + 1;
    END;

SELECT  *
FROM    @menuFunction;

--PRINT @menuFunctionList
GO
