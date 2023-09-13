USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TEMP_PAID]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_PAID](
	[TRANID] [bigint] NOT NULL,
	[PAIDDATE] [datetime] NULL,
	[CONTROLNO] [varchar](30) NULL,
	[NEWDATE] [datetime] NULL,
	[IS_UPDATED] [bit] NULL
) ON [PRIMARY]
GO
