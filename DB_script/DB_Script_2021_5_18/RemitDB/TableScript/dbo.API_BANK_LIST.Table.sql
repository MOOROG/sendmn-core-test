USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[API_BANK_LIST]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[API_BANK_LIST](
	[BANK_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[API_PARTNER_ID] [int] NOT NULL,
	[BANK_NAME] [nvarchar](200) NULL,
	[BANK_CODE1] [varchar](25) NULL,
	[BANK_CODE2] [varchar](25) NULL,
	[BANK_STATE] [varchar](100) NULL,
	[BANK_DISTRICT] [varchar](100) NULL,
	[BANK_ADDRESS] [nvarchar](250) NULL,
	[BANK_PHONE] [nvarchar](50) NULL,
	[BANK_EMAIL] [nvarchar](150) NULL,
	[SUPPORT_CURRENCY] [varchar](5) NULL,
	[BANK_COUNTRY] [varchar](45) NOT NULL,
	[PAYMENT_TYPE_ID] [int] NOT NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[JME_BANK_CODE] [varchar](30) NULL,
	[BANK_ID_OLD] [int] NULL
) ON [PRIMARY]
GO
