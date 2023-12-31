USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TempPromotionalCampaignTxn_MARCH]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempPromotionalCampaignTxn_MARCH](
	[TranId] [bigint] NOT NULL,
	[ApprovedDate] [datetime] NULL,
	[CustomerId] [bigint] NULL,
	[referelCode] [varchar](20) NULL,
	[IsFirstTxn] [bit] NULL,
	[IsPaid] [bit] NULL,
	[FirstTxnPay] [int] NULL,
	[RestTxnPay] [int] NULL
) ON [PRIMARY]
GO
