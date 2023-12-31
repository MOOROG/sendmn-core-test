USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranSendersOnBehalf]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranSendersOnBehalf](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tranId] [bigint] NOT NULL,
	[holdTranId] [bigint] NULL,
	[firstName] [varchar](100) NULL,
	[middleName] [varchar](100) NULL,
	[lastName1] [varchar](100) NULL,
	[lastName2] [varchar](100) NULL,
	[fullName] [varchar](200) NULL,
	[idType] [varchar](50) NULL,
	[idNumber] [varchar](50) NULL,
	[employmentType] [varchar](100) NULL,
	[country] [varchar](100) NULL,
	[address] [varchar](300) NULL,
	[town] [varchar](100) NULL,
	[state] [varchar](100) NULL,
	[postCode] [varchar](100) NULL,
	[telephoneNo] [varchar](50) NULL,
	[nationality] [varchar](100) NULL,
	[occupation] [varchar](100) NULL,
	[customerId] [int] NULL,
	[idExpiryDate] [datetime] NULL,
	[dob] [datetime] NULL,
	[mobile] [varchar](50) NULL,
	[companyName] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[tranId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
