USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranReceiversTemp]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranReceiversTemp](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tranId] [bigint] NOT NULL,
	[customerId] [bigint] NULL,
	[membershipId] [varchar](20) NULL,
	[firstName] [varchar](200) NULL,
	[middleName] [varchar](50) NULL,
	[lastName1] [varchar](50) NULL,
	[lastName2] [varchar](50) NULL,
	[fullName] [varchar](500) NULL,
	[country] [varchar](50) NULL,
	[address] [varchar](500) NULL,
	[STATE] [varchar](50) NULL,
	[district] [varchar](50) NULL,
	[zipCode] [varchar](50) NULL,
	[city] [varchar](50) NULL,
	[email] [varchar](150) NULL,
	[homePhone] [varchar](50) NULL,
	[workPhone] [varchar](50) NULL,
	[mobile] [varchar](50) NULL,
	[nativeCountry] [varchar](50) NULL,
	[dob] [datetime] NULL,
	[placeOfIssue] [varchar](50) NULL,
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
	[relativeName] [varchar](100) NULL,
	[gender] [varchar](10) NULL,
	[address2] [varchar](200) NULL,
	[dcInfo] [varchar](100) NULL,
	[ipAddress] [varchar](20) NULL,
	[bankName] [varchar](50) NULL,
	[branchName] [varchar](100) NULL,
	[accountNo] [varchar](50) NULL,
	[chequeNo] [varchar](50) NULL,
	[isNewAc] [char](1) NULL,
	[oldSysCustId] [int] NULL,
 CONSTRAINT [pk_idx_tranReceiversTemp_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
