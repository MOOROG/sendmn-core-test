USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentFileFormat]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentFileFormat](
	[agentFfId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [bigint] NOT NULL,
	[flFormatId] [int] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentFileFormat_agentFfId] PRIMARY KEY CLUSTERED 
(
	[agentFfId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentFileFormat] ADD  CONSTRAINT [MSrepl_tran_version_default_6FC98860_F70D_4591_AE55_7378067DA3DF_2040042699]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
