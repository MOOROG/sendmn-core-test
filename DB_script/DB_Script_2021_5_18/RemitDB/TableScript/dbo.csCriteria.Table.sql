USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[csCriteria]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[csCriteria](
	[csCriteriaId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[csDetailId] [bigint] NULL,
	[criteriaId] [int] NULL,
	[isActive] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_csCriteria_csCriteriaId] PRIMARY KEY CLUSTERED 
(
	[csCriteriaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[csCriteria] ADD  CONSTRAINT [MSrepl_tran_version_default_912E57E1_52E2_4E7A_BD87_EF5E9E311CE6_792441947]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
