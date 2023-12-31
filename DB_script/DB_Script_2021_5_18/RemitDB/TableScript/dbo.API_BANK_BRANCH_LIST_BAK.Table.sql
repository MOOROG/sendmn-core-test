USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[API_BANK_BRANCH_LIST_BAK]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[API_BANK_BRANCH_LIST_BAK](
	[BRANCH_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[BANK_ID] [bigint] NOT NULL,
	[BRANCH_NAME] [varchar](250) NULL,
	[BRANCH_CODE1] [varchar](100) NULL,
	[BRANCH_CODE2] [varchar](100) NULL,
	[BRANCH_STATE] [varchar](100) NULL,
	[BRANCH_DISTRICT] [varchar](100) NULL,
	[BRANCH_ADDRESS] [nvarchar](250) NULL,
	[BRANCH_PHONE] [nvarchar](50) NULL,
	[BRANCH_EMAIL] [nvarchar](150) NULL,
	[BRANCH_COUNTRY] [varchar](45) NOT NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[PAYMENT_TYPE_ID] [int] NULL
) ON [PRIMARY]
GO
