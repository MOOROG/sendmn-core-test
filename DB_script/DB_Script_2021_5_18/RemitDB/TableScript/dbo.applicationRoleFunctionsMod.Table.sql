USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[applicationRoleFunctionsMod]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[applicationRoleFunctionsMod](
	[rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[functionId] [varchar](10) NULL,
	[roleId] [int] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modType] [char](1) NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicationRoleFunctionsMod] ADD  CONSTRAINT [MSrepl_tran_version_default_CB39E90B_EAB9_40F6_8DC9_EAC64E2C854C_1152059190]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
