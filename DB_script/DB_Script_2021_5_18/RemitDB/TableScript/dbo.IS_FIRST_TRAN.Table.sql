USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[IS_FIRST_TRAN]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IS_FIRST_TRAN](
	[ID] [bigint] NOT NULL,
	[isFirstTran] [char](1) NULL,
	[CUSTOMERID] [int] NULL,
	[CREATEDDATE] [datetime] NULL,
	[IS_GEN] [bit] NULL,
	[FIRST_TRAN] [bit] NULL,
	[CONTROLNO] [varchar](30) NULL
) ON [PRIMARY]
GO
