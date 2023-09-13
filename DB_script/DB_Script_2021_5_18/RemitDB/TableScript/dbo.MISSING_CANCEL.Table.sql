USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[MISSING_CANCEL]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MISSING_CANCEL](
	[ID] [bigint] NOT NULL,
	[CONTROLNO] [varchar](100) NULL,
	[CREATEDDATE] [datetime] NULL,
	[CANCELAPPROVEDDATE] [datetime] NULL,
	[IS_CANCEL] [int] NOT NULL,
	[HAVE_COMM] [int] NOT NULL
) ON [PRIMARY]
GO
