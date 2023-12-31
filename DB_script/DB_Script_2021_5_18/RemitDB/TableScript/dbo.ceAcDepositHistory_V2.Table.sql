USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ceAcDepositHistory_V2]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ceAcDepositHistory_V2](
	[rowid] [bigint] IDENTITY(1,1) NOT NULL,
	[ceNumber] [varchar](20) NULL,
	[originatingAgentRefNum] [varchar](20) NULL,
	[senderName] [varchar](50) NULL,
	[senderCountry] [varchar](50) NULL,
	[senderAgentCode] [varchar](50) NULL,
	[senderAgentName] [varchar](50) NULL,
	[senderMobileNumber] [varchar](50) NULL,
	[senderMessageToBeneficiary] [varchar](50) NULL,
	[txnCreatedDate] [varchar](50) NULL,
	[receiverName] [varchar](50) NULL,
	[receiverMobile] [varchar](50) NULL,
	[payoutCurrencyCode] [varchar](50) NULL,
	[payoutCurrencyName] [varchar](50) NULL,
	[sentAmount] [varchar](50) NULL,
	[charges] [varchar](50) NULL,
	[finalPayoutAmount] [varchar](50) NULL,
	[receiverAccountNumber] [varchar](50) NULL,
	[receiverIbanNumber] [varchar](50) NULL,
	[senderAddress] [varchar](50) NULL,
	[receiverAddress] [varchar](50) NULL,
	[senderIdType] [varchar](50) NULL,
	[senderIdNumber] [varchar](50) NULL,
	[senderIdDateType] [varchar](50) NULL,
	[senderIdDate] [varchar](50) NULL,
	[districtId] [varchar](50) NULL,
	[districtName] [varchar](50) NULL,
	[serviceId] [varchar](50) NULL,
	[benBankCode] [varchar](50) NULL,
	[benBankName] [varchar](50) NULL,
	[benBranchCode] [varchar](50) NULL,
	[benBranchName] [varchar](50) NULL,
	[benAccountType] [varchar](50) NULL,
	[benEftCode] [varchar](50) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[recordStatus] [varchar](50) NULL,
	[tranPayProcess] [varchar](20) NULL,
	[apiStatus] [varchar](50) NULL,
	[payResponseCode] [varchar](20) NULL,
	[payResponseMsg] [varchar](100) NULL,
	[paidDate] [datetime] NULL,
	[paidBy] [varchar](30) NULL,
	[pBranch] [int] NULL,
	[pAgent] [int] NULL,
	[pBankType] [char](1) NULL,
	[pBankBranchName] [varchar](100) NULL,
	[pBank] [varchar](30) NULL,
	[pBankBranch] [varchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
