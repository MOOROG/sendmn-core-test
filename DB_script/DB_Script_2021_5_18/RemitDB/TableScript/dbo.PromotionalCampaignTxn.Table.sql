USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[PromotionalCampaignTxn]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PromotionalCampaignTxn](
	[TranId] [bigint] NOT NULL,
	[ApprovedDate] [datetime] NULL,
	[CustomerId] [bigint] NULL,
	[referelCode] [varchar](20) NULL,
	[IsFirstTxn] [bit] NULL,
	[IsPaid] [bit] NULL,
	[FirstTxnPay] [int] NULL,
	[RestTxnPay] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[SchemeType] [char](1) NULL,
	[RegdCustomer] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[TranId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PromotionalCampaignTxn] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
