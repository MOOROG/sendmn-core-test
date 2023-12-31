USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[DealBankSetting]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DealBankSetting](
	[RowId] [int] IDENTITY(1,1) NOT NULL,
	[BankName] [varchar](100) NOT NULL,
	[SellAcNo] [varchar](15) NOT NULL,
	[BuyAcNo] [varchar](15) NOT NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[CreatedDate] [datetime] NULL,
	[ModifyBy] [varchar](50) NULL,
	[ModifyDate] [datetime] NULL,
	[Settle_PayCurr] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DealBankSetting] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
