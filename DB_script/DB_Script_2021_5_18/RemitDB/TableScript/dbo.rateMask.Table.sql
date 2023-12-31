USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[rateMask]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rateMask](
	[rmId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
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
	[isActive] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_rateMask_rmId] PRIMARY KEY CLUSTERED 
(
	[rmId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rateMask] ADD  CONSTRAINT [MSrepl_tran_version_default_7DE65B10_8522_4707_BDFF_34A6765AC21F_865086518]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
