USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempGblApi]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempGblApi](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[radNo] [varchar](100) NULL,
	[tokenId] [varchar](100) NULL,
	[benefName] [varchar](100) NULL,
	[benefTel] [varchar](100) NULL,
	[benefMobile] [varchar](100) NULL,
	[benefAddress] [varchar](100) NULL,
	[benefAccIdNo] [varchar](100) NULL,
	[benefIdType] [varchar](100) NULL,
	[senderName] [varchar](100) NULL,
	[senderAddress] [varchar](100) NULL,
	[senderTel] [varchar](100) NULL,
	[senderMobile] [varchar](100) NULL,
	[senderIdType] [varchar](100) NULL,
	[senderIdNo] [varchar](100) NULL,
	[remittanceEntryDt] [varchar](100) NULL,
	[remittanceAuthorizedDt] [varchar](100) NULL,
	[remitType] [varchar](100) NULL,
	[rCurrency] [varchar](100) NULL,
	[pCurrency] [varchar](100) NULL,
	[pCommission] [varchar](100) NULL,
	[amount] [varchar](100) NULL,
	[localAmount] [varchar](100) NULL,
	[exchangeRate] [varchar](100) NULL,
	[dollarRate] [varchar](100) NULL,
	[confirmationNo] [varchar](100) NULL,
	[apiStatus] [varchar](50) NULL,
	[payResponseCode] [varchar](20) NULL,
	[payResponseMsg] [varchar](100) NULL,
	[recordStatus] [varchar](50) NULL,
	[tranPayProcess] [varchar](20) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[paidDate] [datetime] NULL,
	[paidBy] [varchar](30) NULL,
	[rContactNo] [varchar](50) NULL,
	[nativeCountry] [varchar](100) NULL,
	[pBranch] [int] NULL,
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
	[remarks] [varchar](500) NULL
) ON [PRIMARY]
GO
