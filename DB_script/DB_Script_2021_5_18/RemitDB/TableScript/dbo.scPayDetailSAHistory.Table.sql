USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[scPayDetailSAHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scPayDetailSAHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[scPayDetailSAId] [int] NULL,
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
ALTER TABLE [dbo].[scPayDetailSAHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_FA9CF7DE_B271_43D1_8B3C_B7A07F145CA4_2066926535]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
