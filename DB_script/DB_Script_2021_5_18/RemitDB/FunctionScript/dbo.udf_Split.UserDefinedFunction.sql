USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[udf_Split]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[udf_Split]
(   
     @DelimitedList nvarchar(max)
    ,@Delimiter nvarchar(2) = ','
)
RETURNS TABLE 
AS
RETURN 
    (
    With CorrectedList As
        (
        Select Case When Left(@DelimitedList, Len(@Delimiter)) <> @Delimiter Then @Delimiter Else '' End
            + @DelimitedList
            + Case When Right(@DelimitedList, Len(@Delimiter)) <> @Delimiter Then @Delimiter Else '' End
            As List
            , Len(@Delimiter) As DelimiterLen
        )
        , Numbers As 
        (
        Select TOP( Coalesce(DataLength(@DelimitedList)/2,0) ) Row_Number() Over ( Order By c1.object_id ) As Value
        From sys.columns As c1
            Cross Join sys.columns As c2
        )
    Select CharIndex(@Delimiter, CL.list, N.Value) + CL.DelimiterLen As Position
        , Substring (
                    CL.List
                    , CharIndex(@Delimiter, CL.list, N.Value) + CL.DelimiterLen     
                    , CharIndex(@Delimiter, CL.list, N.Value + 1)                           
                        - ( CharIndex(@Delimiter, CL.list, N.Value) + CL.DelimiterLen ) 
                    ) As Value
    From CorrectedList As CL
        Cross Join Numbers As N
    Where N.Value <= DataLength(CL.List) / 2
        And Substring(CL.List, N.Value, CL.DelimiterLen) = @Delimiter
    )

GO
