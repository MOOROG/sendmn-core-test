USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[topUpLimit]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[topUpLimit](
	[tulId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[userId] [int] NULL,
	[currency] [int] NULL,
	[limitPerDay] [money] NULL,
	[perTopUpLimit] [money] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[maxCreditLimitForAgent] [money] NULL,
 CONSTRAINT [PK__topUpLim__17124C392335D029] PRIMARY KEY CLUSTERED 
(
	[tulId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[topUpLimit] ADD  CONSTRAINT [MSrepl_tran_version_default_07531675_6B8E_4CE8_9316_FFA68EA6EB72_1756129597]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
