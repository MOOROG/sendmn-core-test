USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customerSetup]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customerSetup](
	[cid] [int] IDENTITY(1000,1) NOT NULL,
	[cName] [varchar](100) NULL,
	[cAddress] [varchar](150) NULL,
	[gender] [varchar](10) NULL,
	[country] [int] NULL,
	[idType] [int] NULL,
	[idNumber] [varchar](50) NULL,
	[dob] [varchar](10) NULL,
	[postalCode] [varchar](50) NULL,
	[contact] [varchar](20) NULL,
	[email] [varchar](100) NULL,
	[cType] [int] NULL,
	[occupation] [int] NULL,
	[branchId] [int] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifyBy] [varchar](50) NULL,
	[modifyDate] [datetime] NULL,
	[town] [varchar](100) NULL,
	[custState] [varchar](100) NULL,
	[nativCountry] [varchar](50) NULL,
	[businessType] [varchar](100) NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[chkId] [varchar](50) NULL,
	[RBA] [money] NULL,
	[GWLstatus] [varchar](10) NULL,
	[RBASTATUS] [varchar](10) NULL,
	[isActive] [char](1) NULL
) ON [PRIMARY]
GO
