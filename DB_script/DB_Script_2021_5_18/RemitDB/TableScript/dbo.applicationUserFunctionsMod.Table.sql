USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[applicationUserFunctionsMod]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[applicationUserFunctionsMod](
	[rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[userId] [varchar](50) NULL,
	[functionId] [varchar](10) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modType] [char](1) NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_applicationUserFunctionsMod_rowid] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicationUserFunctionsMod] ADD  CONSTRAINT [MSrepl_tran_version_default_9267B092_E760_4977_BE72_CACEC29295BE_812581983]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
