USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[apiRequestLog_GetExRate]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiRequestLog_GetExRate](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[AGENT_CODE] [varchar](50) NULL,
	[USER_ID] [varchar](50) NULL,
	[PASSWORD] [varchar](50) NULL,
	[AGENT_SESSION_ID] [varchar](50) NULL,
	[TRANSFERAMOUNT] [varchar](50) NULL,
	[PAYMENTMODE] [varchar](50) NULL,
	[CALC_BY] [varchar](50) NULL,
	[LOCATION_ID] [varchar](50) NULL,
	[PAYOUT_COUNTRY] [varchar](50) NULL,
	[errorCode] [varchar](10) NULL,
	[errorMsg] [varchar](max) NULL,
	[requestedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
