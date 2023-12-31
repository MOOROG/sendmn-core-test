USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentGroupMaping]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentGroupMaping](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[groupCat] [int] NULL,
	[groupDetail] [int] NULL,
	[createdBy] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[isActive] [char](10) NULL,
	[isDeleted] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
 CONSTRAINT [pk_idx_agentGroupMaping_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentGroupMaping] ADD  CONSTRAINT [MSrepl_tran_version_default_4A4EE51E_7C69_44C6_8DCE_61F556FFFA17_564405280]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
