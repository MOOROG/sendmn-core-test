USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[NEW_COMM]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NEW_COMM](
	[PAGENTCOMM] [money] NULL,
	[DIFF_AMT] [money] NULL,
	[DR_AMT] [money] NULL,
	[CR_AMT] [money] NULL,
	[REF_NUM] [varchar](20) NULL,
	[FIELD1] [varchar](50) NULL,
	[CONTROLNO] [varchar](30) NULL,
	[IS_GEN] [bit] NULL
) ON [PRIMARY]
GO
