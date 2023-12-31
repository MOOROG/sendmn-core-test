USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[exRateBranchWiseHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[exRateBranchWiseHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[exRateBranchWiseId] [int] NULL,
	[exRateTreasuryId] [int] NULL,
	[cBranch] [int] NULL,
	[premium] [float] NULL,
	[isActive] [char](1) NULL,
	[modType] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[treasuryHistoryId] [bigint] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_exRateBranchWiseHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exRateBranchWiseHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_16C1572D_14B0_4E80_8331_97C4A306F0AC_769086176]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
