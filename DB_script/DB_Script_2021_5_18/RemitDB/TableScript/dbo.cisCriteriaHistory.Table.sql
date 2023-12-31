USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[cisCriteriaHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisCriteriaHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[cisCriteriaId] [bigint] NULL,
	[cisDetailId] [bigint] NULL,
	[criteriaId] [int] NULL,
	[idTypeId] [int] NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_cisCriteriaHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cisCriteriaHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_1BD84FFA_CEAF_4CDF_AB0B_731656B3976B_1876969813]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
