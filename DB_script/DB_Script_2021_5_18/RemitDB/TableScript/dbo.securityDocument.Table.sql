USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[securityDocument]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[securityDocument](
	[sdId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[securityTypeId] [int] NULL,
	[securityType] [char](1) NULL,
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
	[sessionId] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[sdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[securityDocument] ADD  CONSTRAINT [MSrepl_tran_version_default_12DF755A_8A25_41E9_9855_BE304514ABE9_2011258320]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
