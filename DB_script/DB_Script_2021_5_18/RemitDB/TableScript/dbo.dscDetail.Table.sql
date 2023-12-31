USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[dscDetail]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dscDetail](
	[dscDetailId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[dscMasterId] [int] NOT NULL,
	[fromAmt] [money] NULL,
	[toAmt] [money] NULL,
	[pcnt] [float] NULL,
	[minAmt] [money] NULL,
	[maxAmt] [money] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_dscDetail_dscDetailId] PRIMARY KEY CLUSTERED 
(
	[dscDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dscDetail] ADD  CONSTRAINT [MSrepl_tran_version_default_689BE1E2_ED34_4617_B17E_B0B1E6F26455_226151901]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
