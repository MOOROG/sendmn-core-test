USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[scSendDetailHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scSendDetailHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[scSendDetailId] [int] NULL,
	[fromAmt] [money] NULL,
	[toAmt] [money] NULL,
	[pcnt] [float] NULL,
	[minAmt] [money] NULL,
	[maxAmt] [money] NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[scSendDetailHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_ABFE873A_BE94_41C4_AC5D_88BD75D3B81B_484248830]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
