USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentDocument]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentDocument](
	[adId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[fileName] [varchar](50) NULL,
	[fileDescription] [varchar](100) NULL,
	[fileType] [varchar](10) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__agentDoc__56B60FC813098A01] PRIMARY KEY CLUSTERED 
(
	[adId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentDocument] ADD  CONSTRAINT [MSrepl_tran_version_default_80AD4563_3B9C_4F2E_94A9_FA908D750FFE_171915734]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
