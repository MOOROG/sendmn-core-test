USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[applicationUserFunctions]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[applicationUserFunctions](
	[rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[userId] [int] NULL,
	[functionId] [varchar](10) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_applicationUserFunctions_rowid] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicationUserFunctions] ADD  CONSTRAINT [MSrepl_tran_version_default_8AA1919D_1A49_47F1_B3BC_D841F3528ECB_908582325]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
