USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[intlAgentsInfo]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[intlAgentsInfo](
	[CompanyName] [nvarchar](255) NULL,
	[agentCode] [float] NULL,
	[ContactName1] [nvarchar](255) NULL,
	[Post1] [nvarchar](255) NULL,
	[AgentType] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[Country] [nvarchar](255) NULL,
	[Phone1] [nvarchar](255) NULL,
	[Phone2] [nvarchar](255) NULL,
	[Fax] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[CurrencyType] [nvarchar](255) NULL,
	[DateOfJoin] [datetime] NULL,
	[agent_short_code] [nvarchar](255) NULL,
	[limitPerTran] [float] NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [pk_idx_intlAgentsInfo_agentCode] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
