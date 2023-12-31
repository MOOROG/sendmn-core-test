USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[commissionGroup]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[commissionGroup](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[groupId] [int] NOT NULL,
	[packageId] [int] NOT NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[isLocked] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_commissionGroup_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commissionGroup] ADD  CONSTRAINT [MSrepl_tran_version_default_6DBB0959_1125_4842_AFCB_16CC065FC6D7_980458817]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
