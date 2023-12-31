USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranSendersTemp]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranSendersTemp](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tranId] [bigint] NOT NULL,
	[customerId] [int] NULL,
	[membershipId] [varchar](50) NULL,
	[firstName] [varchar](200) NULL,
	[middleName] [varchar](50) NULL,
	[lastName1] [varchar](50) NULL,
	[lastName2] [varchar](50) NULL,
	[fullName] [varchar](500) NULL,
	[country] [varchar](50) NULL,
	[address] [varchar](max) NULL,
	[STATE] [varchar](50) NULL,
	[district] [varchar](50) NULL,
	[zipCode] [varchar](50) NULL,
	[city] [varchar](200) NULL,
	[email] [varchar](150) NULL,
	[homePhone] [varchar](50) NULL,
	[workPhone] [varchar](50) NULL,
	[mobile] [varchar](50) NULL,
	[nativeCountry] [varchar](50) NULL,
	[dob] [datetime] NULL,
	[placeOfIssue] [varchar](50) NULL,
	[customerType] [varchar](50) NULL,
	[occupation] [varchar](500) NULL,
	[idType] [varchar](50) NULL,
	[idNumber] [varchar](50) NULL,
	[idPlaceOfIssue] [varchar](50) NULL,
	[issuedDate] [datetime] NULL,
	[validDate] [datetime] NULL,
	[extCustomerId] [varchar](50) NULL,
	[cwPwd] [varchar](10) NULL,
	[ttName] [nvarchar](200) NULL,
	[isFirstTran] [char](1) NULL,
	[customerRiskPoint] [float] NULL,
	[countryRiskPoint] [float] NULL,
	[gender] [varchar](10) NULL,
	[salary] [varchar](50) NULL,
	[companyName] [varchar](200) NULL,
	[address2] [varchar](max) NULL,
	[dcInfo] [varchar](100) NULL,
	[ipAddress] [varchar](20) NULL,
	[notifySms] [char](1) NULL,
	[txnTestQuestion] [varchar](500) NULL,
	[txnTestAnswer] [varchar](500) NULL,
	[RBA] [money] NULL,
 CONSTRAINT [pk_idx_tranSendersTemp_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
