USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[creditLimitHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[creditLimitHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[crLimitId] [int] NULL,
	[agentId] [int] NULL,
	[currency] [int] NULL,
	[limitAmt] [money] NULL,
	[perTopUpAmt] [money] NULL,
	[maxLimitAmt] [money] NULL,
	[expiryDate] [datetime] NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[status] [varchar](50) NULL,
	[todaysAddedMaxLimit] [money] NULL,
	[perToupRequest] [money] NULL,
	[maxTopupRequest] [money] NULL,
 CONSTRAINT [pk_idx_creditLimitHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
