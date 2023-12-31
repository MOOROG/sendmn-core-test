USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[regionalBranchAccessSetup]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[regionalBranchAccessSetup](
	[regionalBranchAccessSetupId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[memberAgentId] [int] NULL,
	[isDeleted] [char](1) NULL,
	[isActive] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_regionalBranchAccessSetup_id] PRIMARY KEY CLUSTERED 
(
	[regionalBranchAccessSetupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[regionalBranchAccessSetup] ADD  CONSTRAINT [MSrepl_tran_version_default_6DA953A3_C409_40F1_953F_D3A300953C53_1229963458]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
