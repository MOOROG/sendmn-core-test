USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[applicationUserRolesMod]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[applicationUserRolesMod](
	[rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[userId] [varchar](30) NULL,
	[roleId] [int] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modType] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_applicationUserRolesMod_rowid] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicationUserRolesMod] ADD  CONSTRAINT [MSrepl_tran_version_default_C2DE43A1_62F7_4FDF_ADC2_44BA4781D623_1159011210]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
