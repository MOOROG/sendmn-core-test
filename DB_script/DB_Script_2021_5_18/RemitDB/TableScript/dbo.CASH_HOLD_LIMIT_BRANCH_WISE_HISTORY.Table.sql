USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CASH_HOLD_LIMIT_BRANCH_WISE_HISTORY]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CASH_HOLD_LIMIT_BRANCH_WISE_HISTORY](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[cashHoldLimitId] [int] NOT NULL,
	[agentId] [int] NOT NULL,
	[cashHoldLimit] [money] NOT NULL,
	[ruleType] [char](1) NOT NULL,
	[hasUserLimit] [bit] NOT NULL,
	[isActive] [bit] NOT NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [varchar](50) NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CASH_HOLD_LIMIT_BRANCH_WISE_HISTORY] ADD  DEFAULT ((0)) FOR [cashHoldLimit]
GO
ALTER TABLE [dbo].[CASH_HOLD_LIMIT_BRANCH_WISE_HISTORY] ADD  DEFAULT ((0)) FOR [hasUserLimit]
GO
ALTER TABLE [dbo].[CASH_HOLD_LIMIT_BRANCH_WISE_HISTORY] ADD  DEFAULT ((0)) FOR [isActive]
GO
