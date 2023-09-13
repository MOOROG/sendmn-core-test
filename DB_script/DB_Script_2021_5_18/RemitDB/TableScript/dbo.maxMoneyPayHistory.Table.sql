USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[maxMoneyPayHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[maxMoneyPayHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[refNo] [varchar](100) NULL,
	[tokenId] [varchar](100) NULL,
	[benefName] [varchar](100) NULL,
	[benefAddress] [varchar](100) NULL,
	[benefMobile] [varchar](100) NULL,
	[benefCity] [varchar](100) NULL,
	[benefCountry] [varchar](100) NULL,
	[benefIdType] [varchar](100) NULL,
	[benefIdNo] [varchar](100) NULL,
	[benefAccIdNo] [varchar](100) NULL,
	[senderName] [varchar](100) NULL,
	[senderAddress] [varchar](100) NULL,
	[senderCity] [varchar](100) NULL,
	[senderMobile] [varchar](100) NULL,
	[senderCountry] [varchar](100) NULL,
	[senderIdType] [varchar](100) NULL,
	[senderIdNo] [varchar](100) NULL,
	[pCCY] [varchar](100) NULL,
	[pCommission] [varchar](100) NULL,
	[pCurrency] [varchar](100) NULL,
	[pAgent] [varchar](100) NULL,
	[pBranch] [int] NULL,
	[pUser] [varchar](100) NULL,
	[payemntType] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[paidDate] [datetime] NULL,
	[paidBy] [varchar](30) NULL,
	[message] [varchar](500) NULL,
	[txnDate] [varchar](100) NULL,
	[status] [varchar](100) NULL,
	[payResponseCode] [varchar](20) NULL,
	[payResponseMsg] [varchar](100) NULL,
	[recordStatus] [varchar](50) NULL,
	[remittanceEntryDt] [varchar](100) NULL,
	[remittanceAuthorizedDt] [varchar](100) NULL,
	[remitType] [varchar](100) NULL,
	[rCurrency] [varchar](100) NULL,
	[amount] [varchar](100) NULL,
	[localAmount] [varchar](100) NULL,
	[exchangeRate] [varchar](100) NULL,
	[dollarRate] [varchar](100) NULL,
	[confirmationNo] [varchar](100) NULL,
	[apiStatus] [varchar](50) NULL,
	[tranPayProcess] [varchar](20) NULL,
	[rContactNo] [varchar](50) NULL,
	[nativeCountry] [varchar](100) NULL,
	[rIdType] [varchar](30) NULL,
	[rIdNumber] [varchar](30) NULL,
	[rIdPlaceOfIssue] [varchar](50) NULL,
	[rValidDate] [datetime] NULL,
	[rDob] [datetime] NULL,
	[rAddress] [varchar](100) NULL,
	[rCity] [varchar](100) NULL,
	[rOccupation] [varchar](100) NULL,
	[relationType] [varchar](50) NULL,
	[relativeName] [varchar](100) NULL,
	[remarks] [varchar](500) NULL,
	[tpAgentId] [varchar](50) NULL,
	[tpAgentName] [varchar](200) NULL,
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
	[tranMode] [varchar](100) NULL,
	[tranNo] [varchar](50) NULL,
	[bankName] [varchar](150) NULL,
	[bankBranch] [varchar](150) NULL,
	[bankAccNo] [varchar](150) NULL,
	[totalComm] [varchar](100) NULL
) ON [PRIMARY]
GO
