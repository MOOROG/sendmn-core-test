USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[TRANSIT_CASH_SETTLEMENT_BAK]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TRANSIT_CASH_SETTLEMENT_BAK](
	[ROW_ID] [int] IDENTITY(1,1) NOT NULL,
	[REFERRAL_CODE] [varchar](50) NOT NULL,
	[RECEIVING_MODE] [varchar](2) NULL,
	[TRAN_DATE] [datetime] NOT NULL,
	[CREATED_BY] [varchar](50) NOT NULL,
	[CREATED_DATE] [datetime] NOT NULL,
	[RECEIVING_ACCOUNT] [varchar](30) NULL,
	[IN_AMOUNT] [money] NULL,
	[OUT_AMOUNT] [money] NULL,
	[REFERENCE_ID] [bigint] NULL,
	[branch_id] [int] NULL
) ON [PRIMARY]
GO
