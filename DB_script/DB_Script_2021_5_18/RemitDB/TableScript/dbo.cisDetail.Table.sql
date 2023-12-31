USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[cisDetail]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisDetail](
	[cisDetailId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[cisMasterId] [bigint] NULL,
	[condition] [int] NULL,
	[collMode] [int] NULL,
	[paymentMode] [int] NULL,
	[tranCount] [int] NULL,
	[amount] [money] NULL,
	[period] [int] NULL,
	[isEnable] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_cisDetail_cisDetailId] PRIMARY KEY CLUSTERED 
(
	[cisDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cisDetail] ADD  CONSTRAINT [MSrepl_tran_version_default_00963A93_E7CE_49BD_B907_06583AAF7F25_2036970383]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
