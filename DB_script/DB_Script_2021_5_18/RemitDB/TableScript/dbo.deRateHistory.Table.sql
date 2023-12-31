USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[deRateHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[deRateHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[deRateId] [bigint] NULL,
	[hub] [int] NULL,
	[country] [int] NULL,
	[baseCurrency] [int] NULL,
	[localCurrency] [int] NULL,
	[cost] [money] NULL,
	[margin] [money] NULL,
	[ve] [money] NULL,
	[ne] [money] NULL,
	[spFlag] [char](1) NULL,
	[isEnable] [char](1) NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__deRateHi__4B58DB804322B177] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[deRateHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_64B48F57_7244_41C2_9553_703F48946141_705489642]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
