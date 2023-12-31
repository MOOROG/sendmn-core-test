USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[API_BANK_BRANCH_LIST_LOG]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[API_BANK_BRANCH_LIST_LOG](
	[ROW_ID] [int] IDENTITY(1,1) NOT NULL,
	[BANK_ID] [bigint] NOT NULL,
	[BRANCH_ID] [bigint] NOT NULL,
	[OLD_BRANCH_CODE1] [bigint] NULL,
	[NEW_BRANCH_CODE1] [bigint] NULL,
	[MODIFIED_BY] [varchar](30) NULL,
	[MODIFIED_DATE] [datetime] NULL
) ON [PRIMARY]
GO
