USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[DATE_UPDATE]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DATE_UPDATE](
	[OLD_DATE] [datetime] NULL,
	[NEW_DATE] [datetime] NULL,
	[CONTROLNO] [varchar](30) NULL
) ON [PRIMARY]
GO
