USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[PAYER_BANK_DETAILS]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PAYER_BANK_DETAILS](
	[PAYER_ID] [int] IDENTITY(1,1) NOT NULL,
	[PAYER_NAME] [varchar](100) NULL,
	[BANK_ID] [int] NULL,
	[BANK_COUNTRY] [varchar](50) NULL,
	[PAYER_CODE] [varchar](30) NULL,
	[PAYER_BRANCH_NAME] [varchar](200) NULL,
	[PAYER_BRANCH_CODE] [varchar](30) NULL,
	[BRANCH_ADDRESS] [varchar](250) NULL,
	[BRANCH_CITY_ID] [varchar](30) NULL,
	[BRANCH_STATE_ID] [varchar](30) NULL,
	[BRANCH_COUNTRY] [varchar](50) NULL,
	[PAYMENT_MODE] [int] NULL,
	[BANK_CODE] [varchar](30) NULL,
	[PARTNER_ID] [int] NULL,
	[creaeteddate] [date] NULL
) ON [PRIMARY]
GO
