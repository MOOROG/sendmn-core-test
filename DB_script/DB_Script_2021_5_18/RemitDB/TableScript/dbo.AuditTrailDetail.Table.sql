USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[AuditTrailDetail]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditTrailDetail](
	[rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ref_num] [varchar](50) NULL,
	[tran_type] [varchar](20) NULL,
	[approved_by] [varchar](100) NULL,
	[approved_date] [date] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_AuditTrailDetail_rowid] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditTrailDetail] ADD  CONSTRAINT [MSrepl_tran_version_default_B17C8FA0_27E8_4003_A1FA_34CC2D1050C5_123147484]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
