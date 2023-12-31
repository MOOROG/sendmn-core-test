USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[userLimitMod]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userLimitMod](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[userLimitId] [int] NULL,
	[currencyId] [int] NULL,
	[userId] [int] NULL,
	[payLimit] [money] NULL,
	[sendLimit] [money] NULL,
	[isEnable] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modType] [char](1) NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_userLimitMod_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userLimitMod] ADD  CONSTRAINT [MSrepl_tran_version_default_A8F9AD84_2C39_4DB7_8CC7_F6CA79E77E53_891306385]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
