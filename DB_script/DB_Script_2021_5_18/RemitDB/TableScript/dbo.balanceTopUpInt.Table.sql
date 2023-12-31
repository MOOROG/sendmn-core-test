USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[balanceTopUpInt]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[balanceTopUpInt](
	[btId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[amount] [int] NULL,
	[topUpExpiryDate] [datetime] NULL,
	[btStatus] [varchar](50) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[modType] [varchar](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[btId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[balanceTopUpInt] ADD  CONSTRAINT [MSrepl_tran_version_default_0658CF82_E2B8_46FB_8060_E2D80A1D3AE4_244560305]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
