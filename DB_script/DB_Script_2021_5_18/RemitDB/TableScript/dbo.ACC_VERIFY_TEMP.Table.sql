USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ACC_VERIFY_TEMP]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ACC_VERIFY_TEMP](
	[REF_NUM] [varchar](20) NULL,
	[FIELD1] [varchar](50) NULL,
	[ACCT_TYPE_CODE] [varchar](20) NULL
) ON [PRIMARY]
GO
