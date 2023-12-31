USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[rateMaskHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rateMaskHistory](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[rmId] [int] NULL,
	[baseCurrency] [varchar](3) NULL,
	[currency] [varchar](3) NULL,
	[rateMaskMulBd] [int] NULL,
	[rateMaskMulAd] [int] NULL,
	[rateMaskDivBd] [int] NULL,
	[rateMaskDivAd] [int] NULL,
	[cMin] [float] NULL,
	[cMax] [float] NULL,
	[pMin] [float] NULL,
	[pMax] [float] NULL,
	[isEnable] [char](1) NULL,
	[modType] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_rateMaskHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rateMaskHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_2BE5A369_9756_4FED_BA79_CB1B7BEE120B_881086575]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
