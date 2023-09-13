USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[cePayHistory_v2]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cePayHistory_v2](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[ceNumber] [varchar](256) NULL,
	[originatingAgentRefNum] [varchar](256) NULL,
	[senderName] [varchar](256) NULL,
	[senderCountry] [varchar](256) NULL,
	[senderAgentCode] [varchar](256) NULL,
	[senderAgentName] [varchar](256) NULL,
	[senderMobileNumber] [varchar](256) NULL,
	[senderMessageToBeneficiary] [varchar](256) NULL,
	[txnCreatedDate] [varchar](256) NULL,
	[receiverName] [varchar](256) NULL,
	[receiverMobile] [varchar](256) NULL,
	[payoutCurrencyCode] [varchar](256) NULL,
	[payoutCurrencyName] [varchar](256) NULL,
	[sentAmount] [varchar](256) NULL,
	[charges] [varchar](256) NULL,
	[finalPayoutAmount] [varchar](256) NULL,
	[receiverAccountNumber] [varchar](256) NULL,
	[receiverIbanNumber] [varchar](256) NULL,
	[senderAddress] [varchar](256) NULL,
	[receiverAddress] [varchar](256) NULL,
	[senderIdType] [varchar](256) NULL,
	[senderIdNumber] [varchar](256) NULL,
	[senderIdDateType] [varchar](256) NULL,
	[senderIdDate] [varchar](256) NULL,
	[districtId] [varchar](256) NULL,
	[districtName] [varchar](256) NULL,
	[serviceId] [varchar](256) NULL,
	[benBankCode] [varchar](256) NULL,
	[benBankName] [varchar](256) NULL,
	[benBranchCode] [varchar](256) NULL,
	[benBranchName] [varchar](256) NULL,
	[benAccountType] [varchar](256) NULL,
	[benEftCode] [varchar](256) NULL,
	[agentCode] [varchar](256) NULL,
	[responseCode] [varchar](256) NULL,
	[responseDesc] [varchar](256) NULL,
	[userId] [varchar](256) NULL,
	[recordStatus] [varchar](20) NULL,
	[tranPayProcess] [varchar](20) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[paidBy] [varchar](30) NULL,
	[paidDate] [varchar](30) NULL,
	[pBranch] [int] NULL,
	[rIdType] [varchar](256) NULL,
	[rIdNumber] [varchar](256) NULL,
	[rIdPlaceOfIssue] [varchar](256) NULL,
	[rValidDate] [varchar](256) NULL,
	[rDob] [varchar](256) NULL,
	[rAddress] [varchar](256) NULL,
	[rCity] [varchar](256) NULL,
	[rOccupation] [varchar](256) NULL,
	[rContactNo] [varchar](256) NULL,
	[nativeCountry] [varchar](256) NULL,
	[relationType] [varchar](256) NULL,
	[relativeName] [varchar](256) NULL,
	[remarks] [varchar](500) NULL,
	[payResponseCode] [varchar](20) NULL,
	[payResponseMsg] [varchar](100) NULL,
	[rBank] [varchar](50) NULL,
	[rBankBranch] [varchar](100) NULL,
	[rAccountNo] [varchar](50) NULL,
	[rChequeNo] [varchar](50) NULL,
	[topupMobileNo] [varchar](20) NULL,
	[customerId] [bigint] NULL,
	[membershipId] [varchar](50) NULL,
	[relWithSender] [varchar](50) NULL,
	[purposeOfRemit] [varchar](500) NULL,
	[rIssueDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
