USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[dscDetailHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dscDetailHistory](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[dscDetailId] [int] NOT NULL,
	[fromAmt] [money] NOT NULL,
	[toAmt] [money] NOT NULL,
	[pcnt] [float] NOT NULL,
	[minAmt] [money] NOT NULL,
	[maxAmt] [money] NOT NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_dscDetailHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dscDetailHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_D33C6509_9831_4C0C_B9AC_7ED92A009A50_837630077]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
