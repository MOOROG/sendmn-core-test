USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[cisCriteria]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisCriteria](
	[cisCriteriaId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[cisDetailId] [bigint] NULL,
	[criteriaId] [int] NULL,
	[idTypeId] [int] NULL,
	[isActive] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_cisCriteria_cisCriteriaId] PRIMARY KEY CLUSTERED 
(
	[cisCriteriaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cisCriteria] ADD  CONSTRAINT [MSrepl_tran_version_default_F5FAE9DD_FB6B_4C5E_B75B_B74D2EB7DB75_1860969756]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
