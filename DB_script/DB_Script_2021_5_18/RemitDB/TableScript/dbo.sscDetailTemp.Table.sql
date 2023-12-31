USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[sscDetailTemp]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sscDetailTemp](
	[sscDetailId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[sscMasterId] [int] NOT NULL,
	[fromAmt] [money] NOT NULL,
	[toAmt] [money] NOT NULL,
	[pcnt] [float] NOT NULL,
	[minAmt] [money] NOT NULL,
	[maxAmt] [money] NOT NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[sessionId] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_sscDetailTemp_sscDetailId] PRIMARY KEY CLUSTERED 
(
	[sscDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sscDetailTemp] ADD  CONSTRAINT [MSrepl_tran_version_default_0F91722C_445B_4CCB_BD74_B0A382405161_1702453289]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
