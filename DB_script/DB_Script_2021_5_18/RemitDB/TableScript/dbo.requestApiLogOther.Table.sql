USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[requestApiLogOther]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[requestApiLogOther](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AGENT_CODE] [varchar](50) NULL,
	[USER_ID] [varchar](50) NULL,
	[PASSWORD] [varchar](50) NULL,
	[AGENT_SESSION_ID] [varchar](50) NULL,
	[AGENT_TXN_REF_ID] [varchar](50) NULL,
	[PAYMENTTYPE] [varchar](50) NULL,
	[PAYOUT_COUNTRY] [varchar](50) NULL,
	[PAYOUT_AGENT_ID] [varchar](50) NULL,
	[REMIT_AMOUNT] [varchar](50) NULL,
	[CALC_BY] [varchar](50) NULL,
	[REPORT_TYPE] [varchar](50) NULL,
	[FROM_DATE] [varchar](10) NULL,
	[TO_DATE] [varchar](10) NULL,
	[REFNO] [varchar](50) NULL,
	[CANCEL_REASON] [varchar](500) NULL,
	[SHOW_INCREMENTAL] [char](1) NULL,
	[REQUEST_DATE] [datetime] NULL,
	[errorCode] [varchar](10) NULL,
	[errorMsg] [varchar](500) NULL,
	[METHOD_NAME] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
