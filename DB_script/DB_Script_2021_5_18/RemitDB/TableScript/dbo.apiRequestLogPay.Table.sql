USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[apiRequestLogPay]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiRequestLogPay](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[ACCESSCODE] [varchar](50) NULL,
	[USERNAME] [varchar](50) NULL,
	[PASSWORD] [varchar](50) NULL,
	[REFNO] [varchar](20) NULL,
	[AGENT_SESSION_ID] [varchar](150) NULL,
	[PAY_TOKEN_ID] [bigint] NULL,
	[requestedDate] [datetime] NULL,
	[errorCode] [varchar](10) NULL,
	[errorMsg] [varchar](max) NULL,
	[remarks] [varchar](30) NULL,
 CONSTRAINT [pk_idx_apiRequestLogPay_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
