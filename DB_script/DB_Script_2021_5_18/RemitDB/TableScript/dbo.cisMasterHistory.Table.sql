USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[cisMasterHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisMasterHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[cisMasterId] [int] NULL,
	[sCountry] [int] NULL,
	[sAgent] [int] NULL,
	[sState] [int] NULL,
	[sZip] [int] NULL,
	[sGroup] [int] NULL,
	[sCustType] [int] NULL,
	[rCountry] [int] NULL,
	[rAgent] [int] NULL,
	[rState] [int] NULL,
	[rZip] [int] NULL,
	[rGroup] [int] NULL,
	[rCustType] [int] NULL,
	[isEnable] [char](1) NULL,
	[collMode] [int] NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_cisMasterHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cisMasterHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_5142D9AD_A62C_4A6A_92E9_CAAF435FDA94_1444968274]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
