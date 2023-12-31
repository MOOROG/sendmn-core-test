USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[intlAgents]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[intlAgents](
	[CompanyName] [varchar](255) NULL,
	[agentCode] [varchar](10) NULL,
	[agent_branch_Code] [varchar](10) NULL,
	[branch] [varchar](255) NULL,
	[Country] [varchar](255) NULL,
	[address] [varchar](255) NULL,
	[City] [varchar](255) NULL,
	[Telephone] [varchar](255) NULL,
	[Fax] [varchar](255) NULL,
	[isHeadOffice] [varchar](255) NULL,
	[contactPerson] [varchar](255) NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [pk_idx_intlAgents_agent_branch_Code] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
