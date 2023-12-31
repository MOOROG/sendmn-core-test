USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentBusinessHistory]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentBusinessHistory](
	[abhId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[remitCompany] [varchar](100) NULL,
	[fromDate] [varchar](10) NULL,
	[toDate] [varchar](10) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__agentBus__915C66EB672B07C3] PRIMARY KEY CLUSTERED 
(
	[abhId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentBusinessHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_1C3E5FAC_43FE_42E1_A28A_0113C9FA8648_2050874423]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
