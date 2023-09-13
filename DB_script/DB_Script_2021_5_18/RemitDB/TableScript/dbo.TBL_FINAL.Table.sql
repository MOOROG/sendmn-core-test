USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TBL_FINAL]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_FINAL](
	[CONTROLNO] [varchar](100) NULL,
	[BRANCH_ID] [int] NULL,
	[ID] [bigint] NOT NULL,
	[field1] [varchar](50) NULL,
	[ref_num] [varchar](20) NULL,
	[TRAN_ID] [int] NOT NULL,
	[ACC_NUM] [varchar](30) NULL
) ON [PRIMARY]
GO
