USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tbl_calendar]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_calendar](
	[eng_date] [datetime] NOT NULL,
	[nep_date] [varchar](20) NOT NULL
) ON [PRIMARY]
GO
