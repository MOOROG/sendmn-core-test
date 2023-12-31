USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentLimitMaster]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentLimitMaster](
	[limitId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[drBalLim] [money] NULL,
	[topUpTillYesterday] [money] NULL,
	[topUpToday] [money] NULL,
	[systemReservedAmount] [money] NULL,
	[currency] [int] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentLimitMaster_limitId] PRIMARY KEY CLUSTERED 
(
	[limitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentLimitMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_AEA85A5C_E39C_4978_B35A_751D941B1E97_878834393]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
