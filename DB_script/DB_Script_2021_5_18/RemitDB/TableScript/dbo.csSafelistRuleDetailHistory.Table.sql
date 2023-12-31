USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[csSafelistRuleDetailHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[csSafelistRuleDetailHistory](
	[RuleId] [int] IDENTITY(1,1) NOT NULL,
	[Amount] [money] NULL,
	[Period] [int] NULL,
	[IsPerTransaction] [varchar](30) NULL,
	[IsActive] [varchar](5) NULL,
	[IsDeleted] [varchar](5) NULL,
	[ApprovedBy] [varchar](50) NULL,
	[ApprovedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [varchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[RuleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
