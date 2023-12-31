USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[KJ_AUTO_REFUND]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KJ_AUTO_REFUND](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[refundType] [varchar](20) NOT NULL,
	[customerId] [bigint] NOT NULL,
	[bankCode] [varchar](100) NULL,
	[bankAccountNo] [varchar](20) NULL,
	[customerSummary] [varchar](20) NULL,
	[requestAmount] [money] NOT NULL,
	[refundAmount] [money] NOT NULL,
	[balance] [money] NOT NULL,
	[action] [varchar](10) NULL,
	[actionDate] [datetime] NULL,
	[actionBy] [varchar](100) NULL,
 CONSTRAINT [PK_KJ_AUTO_REFUND] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
