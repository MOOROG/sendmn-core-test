USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[userGroupMapping]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userGroupMapping](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[userId] [int] NULL,
	[userName] [varchar](50) NULL,
	[groupCat] [int] NULL,
	[groupDetail] [int] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modefiedBy] [varchar](50) NULL,
	[modefiedDate] [datetime] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_userGroupMapping_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userGroupMapping] ADD  CONSTRAINT [MSrepl_tran_version_default_0F6DDDEC_9C63_4510_B221_12D148331BA1_1222503634]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
