USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TBL_CASH_REFERRAL]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_CASH_REFERRAL](
	[CONTROLNO] [varchar](100) NULL,
	[BRANCH_ID] [int] NULL,
	[ID] [bigint] NOT NULL
) ON [PRIMARY]
GO
