USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bonusPrizeSetup]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bonusPrizeSetup](
	[schemePrizeId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[bonusSchemeId] [int] NULL,
	[points] [int] NULL,
	[giftItem] [int] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_bonusPrizeSetup_schemePrizeId] PRIMARY KEY CLUSTERED 
(
	[schemePrizeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bonusPrizeSetup] ADD  CONSTRAINT [MSrepl_tran_version_default_31459404_79A4_475B_92A3_57FA598C0FE7_614657633]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
