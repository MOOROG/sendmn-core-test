USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[branch]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[branch](
	[branch_id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agent_id] [int] NOT NULL,
	[branch_short_name] [varchar](20) NULL,
	[branch_name] [varchar](100) NULL,
	[branch_address] [varchar](200) NULL,
	[branch_address2] [varchar](200) NULL,
	[branch_city] [varchar](100) NULL,
	[branch_phone] [varchar](50) NULL,
	[branch_fax] [varchar](50) NULL,
	[branch_contact_person] [varchar](50) NULL,
	[branch_create_date] [datetime] NULL,
	[branch_create_by] [varchar](50) NULL,
	[branch_modify_by] [varchar](50) NULL,
	[branch_modify_date] [datetime] NULL,
	[branch_status] [varchar](1) NULL,
	[map_branchcode] [varchar](20) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_branch_branch_id] PRIMARY KEY CLUSTERED 
(
	[branch_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[branch] ADD  CONSTRAINT [MSrepl_tran_version_default_DDB5A2FF_2155_4CCE_8CC6_91B32F250848_386100416]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
