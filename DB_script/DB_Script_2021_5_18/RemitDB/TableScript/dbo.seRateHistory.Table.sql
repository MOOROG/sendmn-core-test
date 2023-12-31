USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[seRateHistory]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[seRateHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[seRateId] [bigint] NULL,
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
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__seRateHi__4B58DB806483A542] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[seRateHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_E3CBB302_9BBE_421C_8796_8DFB53607402_2046734444]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
