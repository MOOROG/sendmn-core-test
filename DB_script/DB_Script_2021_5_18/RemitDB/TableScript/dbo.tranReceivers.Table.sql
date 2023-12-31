USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranReceivers]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranReceivers](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tranId] [bigint] NOT NULL,
	[customerId] [int] NULL,
	[membershipId] [varchar](20) NULL,
	[firstName] [varchar](500) NULL,
	[middleName] [varchar](50) NULL,
	[lastName1] [varchar](50) NULL,
	[lastName2] [varchar](50) NULL,
	[country] [varchar](100) NULL,
	[address] [varchar](500) NULL,
	[state] [varchar](100) NULL,
	[district] [varchar](100) NULL,
	[zipCode] [varchar](50) NULL,
	[city] [varchar](150) NULL,
	[email] [varchar](150) NULL,
	[homePhone] [varchar](100) NULL,
	[workPhone] [varchar](100) NULL,
	[mobile] [varchar](100) NULL,
	[nativeCountry] [varchar](100) NULL,
	[dob] [datetime] NULL,
	[placeOfIssue] [varchar](100) NULL,
	[customerType] [varchar](50) NULL,
	[occupation] [varchar](50) NULL,
	[idType] [varchar](50) NULL,
	[idNumber] [varchar](50) NULL,
	[idPlaceOfIssue] [varchar](50) NULL,
	[issuedDate] [datetime] NULL,
	[validDate] [datetime] NULL,
	[idType2] [varchar](50) NULL,
	[idNumber2] [varchar](50) NULL,
	[idPlaceOfIssue2] [varchar](50) NULL,
	[issuedDate2] [datetime] NULL,
	[validDate2] [datetime] NULL,
	[relationType] [varchar](50) NULL,
	[relativeName] [varchar](200) NULL,
	[stdName] [varchar](200) NULL,
	[stdLevel] [varchar](200) NULL,
	[stdRollRegNo] [varchar](50) NULL,
	[stdSemYr] [varchar](50) NULL,
	[stdCollegeId] [int] NULL,
	[feeTypeId] [bigint] NULL,
	[accountName] [varchar](200) NULL,
	[gender] [varchar](50) NULL,
	[fullName] [varchar](200) NULL,
	[holdTranId] [bigint] NULL,
	[address2] [varchar](max) NULL,
	[ipAddress] [varchar](200) NULL,
	[dcInfo] [varchar](200) NULL,
	[bankName] [varchar](50) NULL,
	[branchName] [varchar](100) NULL,
	[chequeNo] [varchar](50) NULL,
	[accountNo] [varchar](50) NULL,
	[relWithSender] [varchar](50) NULL,
	[purposeOfRemit] [varchar](500) NULL,
	[isNewAc] [char](1) NULL,
 CONSTRAINT [PK__tranRece__9A58821B54782602] PRIMARY KEY CLUSTERED 
(
	[tranId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
