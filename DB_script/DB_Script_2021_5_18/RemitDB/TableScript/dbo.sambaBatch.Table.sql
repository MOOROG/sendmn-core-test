USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[sambaBatch]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sambaBatch](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[controlNo] [varchar](20) NULL,
	[senderName] [varchar](500) NULL,
	[receiverName] [varchar](500) NULL,
	[sCountry] [varchar](100) NULL,
	[sSuperAgent] [int] NULL,
	[sSuperAgentName] [varchar](100) NULL,
	[sAgent] [int] NULL,
	[sAgentName] [varchar](100) NULL,
	[sBranch] [int] NULL,
	[sBranchName] [varchar](100) NULL,
	[paymentMethod] [varchar](50) NULL,
	[tAmt] [money] NULL,
	[cAmt] [money] NULL,
	[pAmt] [money] NULL,
	[customerRate] [decimal](15, 9) NULL,
	[payoutCurr] [varchar](3) NULL,
	[pCountry] [varchar](100) NULL,
	[pBank] [int] NULL,
	[pBankName] [varchar](100) NULL,
	[pBankBranch] [int] NULL,
	[pBankBranchName] [varchar](100) NULL,
	[pBankType] [varchar](50) NULL,
	[accountNo] [varchar](200) NULL,
	[tranStatus] [varchar](20) NULL,
	[payStatus] [varchar](20) NULL,
	[collCurr] [varchar](3) NULL,
	[tranType] [char](1) NULL,
	[serviceCharge] [money] NULL,
	[sCurrCostRate] [float] NULL,
	[pMessage] [varchar](400) NULL,
	[createdDate] [datetime] NULL,
	[createdDateLocal] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[senName] [varchar](200) NULL,
	[senAddress] [varchar](max) NULL,
	[senCity] [varchar](200) NULL,
	[senCountry] [varchar](50) NULL,
	[senNativeCountry] [varchar](50) NULL,
	[senEmail] [varchar](150) NULL,
	[senCompanyName] [varchar](200) NULL,
	[senIdType] [varchar](50) NULL,
	[senIdNumber] [varchar](50) NULL,
	[recName] [varchar](200) NULL,
	[recAddress] [varchar](max) NULL,
	[recHomePhone] [varchar](50) NULL,
	[recWorkPhone] [varchar](50) NULL,
	[recCity] [varchar](50) NULL,
	[recCountry] [varchar](50) NULL,
	[recIdType] [varchar](50) NULL,
	[recIdNumber] [varchar](50) NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[pAgent] [int] NULL,
	[pBranch] [int] NULL,
	[pAgentName] [varchar](200) NULL,
 CONSTRAINT [PK_sambaBatch_1] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
