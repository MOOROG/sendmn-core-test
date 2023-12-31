USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[schemeSetup]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[schemeSetup](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[schemeCode] [varchar](50) NULL,
	[schemeName] [varchar](100) NULL,
	[sCountry] [varchar](50) NULL,
	[sAgent] [int] NULL,
	[sBranch] [int] NULL,
	[rCountry] [varchar](50) NULL,
	[rAgent] [int] NULL,
	[schemeStartDate] [datetime] NULL,
	[schemeEndDate] [datetime] NULL,
	[schemeFor] [varchar](50) NULL,
	[value] [money] NULL,
	[action] [varchar](50) NULL,
	[customerType] [varchar](50) NULL,
	[customerClass] [varchar](50) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[exRate] [money] NULL,
	[serviceFee] [money] NULL,
	[couponType] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[couponCode] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[schemeSetup] ADD  CONSTRAINT [MSrepl_tran_version_default_637F83F5_6E34_4978_BA70_4C98E267167F_1092563326]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
