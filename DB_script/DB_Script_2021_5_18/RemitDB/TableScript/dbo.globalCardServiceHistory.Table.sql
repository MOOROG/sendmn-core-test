USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[globalCardServiceHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[globalCardServiceHistory](
	[id] [int] IDENTITY(10001,1) NOT NULL,
	[controlNo] [varchar](50) NULL,
	[remitCardNo] [varchar](16) NULL,
	[refNo] [varchar](50) NULL,
	[sAgent] [int] NULL,
	[sAgentName] [varchar](200) NULL,
	[sSuperAgent] [int] NULL,
	[sSuperAgentName] [varchar](200) NULL,
	[sBranch] [int] NULL,
	[sBranchName] [varchar](200) NULL,
	[benefName] [varchar](200) NULL,
	[benefAddress] [varchar](500) NULL,
	[benefMobile] [varchar](50) NULL,
	[benefIdType] [varchar](50) NULL,
	[benefIdNo] [varchar](50) NULL,
	[benefAcNo] [varchar](100) NULL,
	[senderName] [varchar](200) NULL,
	[senderAddress] [varchar](500) NULL,
	[senderMobile] [varchar](50) NULL,
	[senderIdType] [varchar](50) NULL,
	[senderIdNo] [varchar](50) NULL,
	[collCurr] [varchar](3) NULL,
	[payoutCurr] [varchar](3) NULL,
	[tAmt] [money] NULL,
	[cAmt] [money] NULL,
	[serviceCharge] [money] NULL,
	[sAgentComm] [money] NULL,
	[dollarRate] [float] NULL,
	[purposeOfRemit] [varchar](200) NULL,
	[sourceOfFund] [varchar](200) NULL,
	[remarks] [varchar](max) NULL,
	[paymentMethod] [varchar](50) NULL,
	[tranType] [varchar](30) NULL,
	[tranStatus] [varchar](50) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[createdDateLocal] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[approvedDateLocal] [datetime] NULL,
	[paidBy] [varchar](50) NULL,
	[paidDate] [datetime] NULL,
	[paidDateLocal] [datetime] NULL,
	[cancelBy] [varchar](50) NULL,
	[cancelDate] [datetime] NULL,
	[cancelDateLocal] [datetime] NULL,
	[dcInfo] [varchar](100) NULL,
	[ipAddress] [varchar](100) NULL,
	[senderRemitCardNo] [varchar](16) NULL,
	[apiResponseCode] [varchar](100) NULL,
	[apiResponseMsg] [varchar](max) NULL,
 CONSTRAINT [PK_globalCardServiceHistory] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
