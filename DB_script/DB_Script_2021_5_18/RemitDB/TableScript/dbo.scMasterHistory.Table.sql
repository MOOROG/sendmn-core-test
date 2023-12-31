USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[scMasterHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scMasterHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[scMasterId] [int] NULL,
	[code] [varchar](100) NULL,
	[description] [varchar](200) NULL,
	[sAgent] [int] NULL,
	[sBranch] [int] NULL,
	[sState] [int] NULL,
	[sGroup] [int] NULL,
	[rAgent] [int] NULL,
	[rBranch] [int] NULL,
	[rState] [int] NULL,
	[rGroup] [int] NULL,
	[tranType] [int] NULL,
	[commissionBase] [int] NULL,
	[effectiveFrom] [datetime] NULL,
	[effectiveTo] [datetime] NULL,
	[isEnable] [char](1) NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_scMasterHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[scMasterHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_9DBB2C99_1764_4D82_B083_126DC56B7057_1805457706]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
