USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bankDepositAPIQueu]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bankDepositAPIQueu](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[controlNo] [varchar](30) NOT NULL,
	[rIdType] [nvarchar](30) NULL,
	[rIdNo] [nvarchar](30) NULL,
	[paidDate] [date] NULL,
	[txnStatus] [varchar](20) NULL,
	[apiResponseMsg] [varchar](200) NULL,
	[apiResponseCode] [varchar](10) NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[confirmedBy] [varchar](30) NULL,
	[confirmedDate] [datetime] NULL,
	[provider] [varchar](15) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[controlNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
