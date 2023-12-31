USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[xPressMoneyTxn]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xPressMoneyTxn](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[controlNo] [varchar](30) NULL,
	[beneIdNo] [varchar](50) NULL,
	[beneFName] [varchar](200) NULL,
	[beneMName] [varchar](200) NULL,
	[beneLName] [varchar](200) NULL,
	[beneContact] [varchar](50) NULL,
	[beneCountry] [varchar](100) NULL,
	[beneAddress] [varchar](200) NULL,
	[sendFName] [varchar](200) NULL,
	[sendMName] [varchar](200) NULL,
	[sendLName] [varchar](200) NULL,
	[sendContact] [varchar](50) NULL,
	[sendAddress] [varchar](200) NULL,
	[sendCountry] [varchar](100) NULL,
	[payoutAmount] [money] NULL,
	[commission] [money] NULL,
	[agentXchgRate] [money] NULL,
	[sendingAgentName] [varchar](100) NULL,
	[sendingCountry] [varchar](100) NULL,
	[msgFromSender] [varchar](200) NULL,
	[TrnSessionID] [varchar](50) NULL,
	[fetchUser] [varchar](50) NULL,
	[fetchDate] [datetime] NULL,
 CONSTRAINT [pk_idx_xPressMoneyTxn_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
