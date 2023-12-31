USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[REFERRAL_AGENT_WISE]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[REFERRAL_AGENT_WISE](
	[ROW_ID] [int] IDENTITY(1,1) NOT NULL,
	[AGENT_ID] [int] NOT NULL,
	[REFERRAL_CODE] [varchar](50) NOT NULL,
	[REFERRAL_NAME] [varchar](150) NOT NULL,
	[REFERRAL_ADDRESS] [varchar](250) NULL,
	[REFERRAL_MOBILE] [varchar](50) NULL,
	[REFERRAL_EMAIL] [varchar](80) NULL,
	[REFERRAL_ID] [int] NOT NULL,
	[CREATED_BY] [varchar](60) NOT NULL,
	[CREATED_DATE] [datetime] NULL,
	[MODIFIED_BY] [varchar](60) NULL,
	[MODIFIED_DATE] [datetime] NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[ext_id] [int] NULL,
	[BRANCH_ID] [int] NULL,
	[REFERRAL_TYPE_CODE] [char](2) NULL,
	[REFERRAL_TYPE] [varchar](30) NULL,
	[REFERRAL_LIMIT] [money] NULL,
	[RULE_TYPE] [char](1) NULL,
	[DEDUCT_TAX_ON_SC] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ROW_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[REFERRAL_AGENT_WISE] ADD  DEFAULT ((0)) FOR [REFERRAL_ID]
GO
ALTER TABLE [dbo].[REFERRAL_AGENT_WISE] ADD  DEFAULT ((0)) FOR [IS_ACTIVE]
GO
