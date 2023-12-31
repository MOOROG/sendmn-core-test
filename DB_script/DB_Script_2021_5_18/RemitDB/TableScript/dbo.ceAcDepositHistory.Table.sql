USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ceAcDepositHistory]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ceAcDepositHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[beneficiaryAddress] [varchar](200) NULL,
	[beneficiaryBankAccountNumber] [varchar](100) NULL,
	[beneficiaryBankBranchCode] [varchar](100) NULL,
	[beneficiaryBankBranchName] [varchar](100) NULL,
	[beneficiaryBankCode] [varchar](100) NULL,
	[beneficiaryBankName] [varchar](200) NULL,
	[beneficiaryIdNo] [varchar](50) NULL,
	[beneficiaryName] [varchar](100) NULL,
	[beneficiaryPhone] [varchar](50) NULL,
	[customerAddress] [varchar](100) NULL,
	[customerIdDate] [varchar](20) NULL,
	[customerIdNo] [varchar](20) NULL,
	[customerIdType] [varchar](20) NULL,
	[customerName] [varchar](100) NULL,
	[customerNationality] [varchar](100) NULL,
	[customerPhone] [varchar](100) NULL,
	[destinationAmount] [varchar](100) NULL,
	[destinationCurrency] [varchar](100) NULL,
	[gitNo] [varchar](100) NULL,
	[paymentMode] [varchar](100) NULL,
	[purpose] [varchar](20) NULL,
	[settlementCurrency] [varchar](20) NULL,
	[transactionStatus] [varchar](100) NULL,
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
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL
) ON [PRIMARY]
GO
