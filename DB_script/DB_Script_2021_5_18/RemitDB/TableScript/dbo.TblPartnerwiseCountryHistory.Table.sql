USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TblPartnerwiseCountryHistory]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TblPartnerwiseCountryHistory](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[partnerWiseCountryRowId] [int] NOT NULL,
	[CountryId] [int] NOT NULL,
	[AgentId] [bigint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[PaymentMethod] [int] NULL,
	[ModifiedBy] [varchar](50) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[isRealTime] [bit] NULL,
	[minTxnLimit] [money] NULL,
	[maxTxnLimit] [money] NULL,
	[LimitCurrency] [varchar](3) NULL,
	[exRateCalByPartner] [bit] NULL,
	[isACValidateSupport] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
