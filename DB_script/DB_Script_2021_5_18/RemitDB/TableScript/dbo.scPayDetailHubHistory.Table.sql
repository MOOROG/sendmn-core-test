USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[scPayDetailHubHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scPayDetailHubHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[scPayDetailHubId] [int] NULL,
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
ALTER TABLE [dbo].[scPayDetailHubHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_AF9BB0FE_70DF_45F6_B8EF_2E96078E270C_815446079]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
