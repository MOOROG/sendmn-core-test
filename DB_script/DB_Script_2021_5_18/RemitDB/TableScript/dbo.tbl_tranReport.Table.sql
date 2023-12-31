USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tbl_tranReport]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_tranReport](
	[rowId] [int] NOT NULL,
	[reportType] [varchar](2) NULL,
	[date] [datetime] NULL,
	[controlNo] [varchar](500) NULL,
	[trnAmt] [money] NULL,
	[serviceCharge] [money] NULL,
	[sendingAgent] [varchar](200) NULL,
	[senderName] [varchar](200) NULL,
	[senderAddress] [varchar](200) NULL,
	[receiverName] [varchar](200) NULL,
	[receiverAddress] [varchar](200) NULL,
	[tranStatus] [varchar](20) NULL,
	[sessionId] [varchar](60) NULL,
	[fromDate] [datetime] NULL,
	[toDate] [datetime] NULL,
	[agentId] [int] NULL
) ON [PRIMARY]
GO
