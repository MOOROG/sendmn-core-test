USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[eblPayHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eblPayHistory](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[payResponseCode] [varchar](10) NULL,
	[tokenId] [varchar](50) NULL,
	[radNo] [varchar](20) NULL,
	[benefName] [varchar](100) NULL,
	[benefTel] [varchar](30) NULL,
	[benefMobile] [varchar](30) NULL,
	[benefAddress] [varchar](100) NULL,
	[benefAccIdNo] [varchar](50) NULL,
	[benefIdType] [varchar](20) NULL,
	[senderName] [varchar](100) NULL,
	[senderAddress] [varchar](100) NULL,
	[senderTel] [varchar](30) NULL,
	[senderMobile] [varchar](30) NULL,
	[senderIdType] [varchar](20) NULL,
	[senderIdNo] [varchar](30) NULL,
	[remittanceEntryDt] [varchar](100) NULL,
	[remittanceAuthorizedDt] [varchar](100) NULL,
	[remarks] [varchar](100) NULL,
	[remitType] [varchar](10) NULL,
	[rCurrency] [varchar](5) NULL,
	[sCountry] [varchar](50) NULL,
	[pCurrency] [varchar](5) NULL,
	[pCommission] [money] NULL,
	[amount] [money] NULL,
	[localAmount] [money] NULL,
	[exchangeRate] [money] NULL,
	[dollarRate] [money] NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[pBranch] [int] NULL,
	[recordStatus] [varchar](30) NULL,
	[rIdType] [varchar](20) NULL,
	[rIdNumber] [varchar](30) NULL,
	[rIdPlaceOfIssue] [varchar](50) NULL,
	[rValidDate] [date] NULL,
	[rDob] [date] NULL,
	[rAddress] [varchar](50) NULL,
	[rCity] [varchar](50) NULL,
	[rOccupation] [varchar](50) NULL,
	[rContactNom] [varchar](20) NULL,
	[nativeCountry] [varchar](20) NULL,
	[relationType] [varchar](50) NULL,
	[relativeName] [varchar](50) NULL,
	[relWithSender] [varchar](50) NULL,
	[purposeOfRemit] [varchar](50) NULL,
	[rIssueDate] [date] NULL,
	[payResponseMsg] [varchar](50) NULL,
	[paidBy] [varchar](50) NULL,
	[paidDate] [datetime] NULL,
	[tranPayProcess] [varchar](50) NULL,
	[confirmationNo] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
