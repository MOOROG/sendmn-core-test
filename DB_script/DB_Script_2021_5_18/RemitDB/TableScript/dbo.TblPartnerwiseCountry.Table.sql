USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TblPartnerwiseCountry]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TblPartnerwiseCountry](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[CountryId] [int] NOT NULL,
	[AgentId] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[CreatedDate] [datetime] NULL,
	[PaymentMethod] [int] NULL,
	[ModifiedBy] [varchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[isRealTime] [bit] NULL,
	[minTxnLimit] [money] NULL,
	[maxTxnLimit] [money] NULL,
	[LimitCurrency] [varchar](3) NULL,
	[exRateCalByPartner] [bit] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[isACValidateSupport] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TblPartnerwiseCountry] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
