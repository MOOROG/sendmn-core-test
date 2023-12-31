USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[applicationRoleFunctions]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[applicationRoleFunctions](
	[rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[functionId] [varchar](10) NULL,
	[roleId] [int] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_applicationRoleFunctions_rowid] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicationRoleFunctions] ADD  CONSTRAINT [MSrepl_tran_version_default_8A061797_2F21_4137_99AC_6C46A99AD83F_501576825]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
