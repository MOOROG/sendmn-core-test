USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[seRate]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[seRate](
	[seRateId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[baseCurrency] [int] NULL,
	[localCurrency] [int] NULL,
	[sHub] [int] NULL,
	[sCountry] [int] NULL,
	[ssAgent] [int] NULL,
	[sAgent] [int] NULL,
	[sBranch] [int] NULL,
	[rHub] [int] NULL,
	[rCountry] [int] NULL,
	[rsAgent] [int] NULL,
	[rAgent] [int] NULL,
	[rBranch] [int] NULL,
	[state] [int] NULL,
	[zip] [varchar](20) NULL,
	[agentGroup] [int] NULL,
	[cost] [money] NULL,
	[margin] [decimal](26, 16) NULL,
	[agentMargin] [money] NULL,
	[ve] [money] NULL,
	[ne] [money] NULL,
	[spFlag] [char](1) NULL,
	[effectiveFrom] [datetime] NULL,
	[effectiveTo] [datetime] NULL,
	[isEnable] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__seRate__9E31F20760B3145E] PRIMARY KEY CLUSTERED 
(
	[seRateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[seRate] ADD  CONSTRAINT [MSrepl_tran_version_default_2F4E183B_3C45_4198_A6E9_2AB263B372C9_1806733589]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
