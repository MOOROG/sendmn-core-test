USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranSenders]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranSenders](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tranId] [bigint] NOT NULL,
	[customerId] [int] NULL,
	[membershipId] [varchar](20) NULL,
	[firstName] [varchar](300) NULL,
	[middleName] [varchar](50) NULL,
	[lastName1] [varchar](50) NULL,
	[lastName2] [varchar](50) NULL,
	[country] [varchar](100) NULL,
	[address] [varchar](200) NULL,
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
	[placeOfIssue] [varchar](50) NULL,
	[customerType] [varchar](50) NULL,
	[occupation] [varchar](500) NULL,
	[idType] [varchar](50) NULL,
	[idNumber] [varchar](50) NULL,
	[idPlaceOfIssue] [varchar](100) NULL,
	[issuedDate] [datetime] NULL,
	[validDate] [datetime] NULL,
	[extCustomerId] [varchar](50) NULL,
	[gender] [varchar](50) NULL,
	[fullName] [varchar](200) NULL,
	[holdTranId] [bigint] NULL,
	[ipAddress] [varchar](200) NULL,
	[address2] [varchar](max) NULL,
	[dcInfo] [varchar](200) NULL,
	[cwPwd] [varchar](10) NULL,
	[ttName] [nvarchar](200) NULL,
	[isFirstTran] [char](1) NULL,
	[customerRiskPoint] [float] NULL,
	[countryRiskPoint] [float] NULL,
	[salary] [varchar](50) NULL,
	[companyName] [varchar](100) NULL,
	[notifySms] [char](1) NULL,
	[txnTestQuestion] [varchar](500) NULL,
	[txnTestAnswer] [varchar](500) NULL,
	[RBA] [money] NULL,
 CONSTRAINT [PK__tranSend__9A58821B50A7951E] PRIMARY KEY CLUSTERED 
(
	[tranId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
