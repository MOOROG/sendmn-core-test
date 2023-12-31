USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[VOUCHER_TRANSIT_CASH_MANAGE]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VOUCHER_TRANSIT_CASH_MANAGE](
	[ROW_ID] [int] IDENTITY(1,1) NOT NULL,
	[REFERRAL_CODE] [varchar](50) NOT NULL,
	[RECEIVER_ACC_NUM] [varchar](30) NULL,
	[AMOUNT] [varchar](8) NOT NULL,
	[DT] [varchar](10) NOT NULL,
	[IS_GEN] [int] NULL
) ON [PRIMARY]
GO
