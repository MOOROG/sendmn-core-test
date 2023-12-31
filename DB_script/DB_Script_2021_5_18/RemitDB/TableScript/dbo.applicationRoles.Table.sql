USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[applicationRoles]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[applicationRoles](
	[roleId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[roleName] [varchar](50) NULL,
	[roleType] [char](1) NULL,
	[isActive] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_applicationRoles_roleId] PRIMARY KEY CLUSTERED 
(
	[roleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicationRoles] ADD  CONSTRAINT [MSrepl_tran_version_default_EC9DDF2A_A9AC_4F9E_9E14_CC63C4CE3B0E_1271935853]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
