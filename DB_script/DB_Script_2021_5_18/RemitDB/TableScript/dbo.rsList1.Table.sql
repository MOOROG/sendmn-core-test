USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[rsList1]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rsList1](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[countryId] [int] NULL,
	[agentId] [int] NULL,
	[rsCountryId] [int] NULL,
	[rsAgentId] [int] NULL,
	[roleType] [char](1) NULL,
	[listType] [varchar](5) NULL,
	[tranType] [varchar](20) NULL,
	[applyToAgent] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[isActive] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
 CONSTRAINT [pk_idx_rsList1_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
