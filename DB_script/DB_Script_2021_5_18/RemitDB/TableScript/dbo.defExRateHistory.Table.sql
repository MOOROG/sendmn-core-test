USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[defExRateHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[defExRateHistory](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[defExRateId] [int] NULL,
	[setupType] [char](2) NULL,
	[currency] [varchar](3) NULL,
	[country] [int] NULL,
	[agent] [int] NULL,
	[baseCurrency] [varchar](3) NULL,
	[tranType] [int] NULL,
	[factor] [char](1) NULL,
	[cRate] [float] NULL,
	[cMargin] [float] NULL,
	[cMax] [float] NULL,
	[cMin] [float] NULL,
	[pRate] [float] NULL,
	[pMargin] [float] NULL,
	[pMax] [float] NULL,
	[pMin] [float] NULL,
	[isEnable] [char](1) NULL,
	[modType] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_defExRateHistory] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[defExRateHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_2488D76C_2F75_4026_96E2_05A5AABB8419_817086347]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
