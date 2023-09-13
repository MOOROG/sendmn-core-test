USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TP_API_RATE_SETUP_HISTORY]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TP_API_RATE_SETUP_HISTORY](
	[ROW_ID] [int] IDENTITY(1,1) NOT NULL,
	[API_RATE_SETUP_ROW_ID] [int] NOT NULL,
	[SENDING_COUNTRY] [int] NOT NULL,
	[PAYOUT_COUNTRY] [int] NOT NULL,
	[SENDING_CURRENCY] [varchar](50) NOT NULL,
	[PAYOUT_CURRENCY] [varchar](50) NOT NULL,
	[PAYOUT_PARTNER] [int] NULL,
	[PARTNER_CUSTOMER_RATE] [float] NULL,
	[PARTNER_SETTLEMENT_RATE] [float] NULL,
	[RATE_MARGIN_OVER_PARTNER_RATE] [float] NULL,
	[JME_MARGIN] [float] NULL,
	[OVERRIDE_CUSTOMER_RATE] [float] NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[CREATED_BY] [varchar](50) NULL,
	[CREATED_DATE] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ROW_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
