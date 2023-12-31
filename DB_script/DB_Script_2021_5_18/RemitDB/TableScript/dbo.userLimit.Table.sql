USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[userLimit]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userLimit](
	[userLimitId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[currencyId] [int] NULL,
	[userId] [int] NULL,
	[payLimit] [money] NULL,
	[sendLimit] [money] NULL,
	[isEnable] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_userLimit] PRIMARY KEY CLUSTERED 
(
	[userLimitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userLimit] ADD  CONSTRAINT [MSrepl_tran_version_default_4EF4AFF0_5177_4101_99BF_F78F30E4FDC8_859306271]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
