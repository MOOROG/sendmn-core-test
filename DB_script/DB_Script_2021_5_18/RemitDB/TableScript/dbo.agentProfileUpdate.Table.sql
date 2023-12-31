USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentProfileUpdate]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentProfileUpdate](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[agentid] [int] NULL,
	[authorizePerson] [varchar](150) NULL,
	[contactperson] [varchar](150) NULL,
	[phone1] [varchar](100) NULL,
	[phone2] [varchar](100) NULL,
	[mobile1] [varchar](100) NULL,
	[mobile2] [varchar](100) NULL,
	[fax1] [varchar](100) NULL,
	[fax2] [varchar](100) NULL,
	[email1] [varchar](100) NULL,
	[email2] [varchar](100) NULL,
	[latitude] [varchar](100) NULL,
	[longitude] [varchar](100) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[address1] [varchar](500) NULL,
	[address2] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
