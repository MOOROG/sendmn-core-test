USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CASH_HOLD_LIMIT_USER_WISE_MOD]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CASH_HOLD_LIMIT_USER_WISE_MOD](
	[cashHoldLimitId] [int] NOT NULL,
	[modType] [char](1) NOT NULL,
	[cashHoldLimitBranchId] [int] NOT NULL,
	[agentId] [int] NOT NULL,
	[userId] [int] NOT NULL,
	[cashHoldLimit] [money] NOT NULL,
	[ruleType] [char](1) NOT NULL,
	[isActive] [bit] NOT NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [varchar](50) NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CASH_HOLD_LIMIT_USER_WISE_MOD] ADD  DEFAULT ((0)) FOR [cashHoldLimit]
GO
ALTER TABLE [dbo].[CASH_HOLD_LIMIT_USER_WISE_MOD] ADD  DEFAULT ((0)) FOR [isActive]
GO
