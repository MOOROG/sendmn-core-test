USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[txnUploadLog]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnUploadLog](
	[logId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[xmlData] [xml] NULL,
	[xmlErrorData] [xml] NULL,
	[uploadedBy] [varchar](50) NULL,
	[uploadedDate] [datetime] NULL,
	[logType] [varchar](50) NULL,
	[receivingMode] [varchar](100) NULL,
	[pAgent] [int] NULL,
	[pAgentName] [varchar](100) NULL,
	[pBranch] [int] NULL,
	[pBranchName] [varchar](100) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_txnUploadLog_logId] PRIMARY KEY CLUSTERED 
(
	[logId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[txnUploadLog] ADD  CONSTRAINT [MSrepl_tran_version_default_1C11DE9D_4D8D_47DA_A31A_8464F0742037_2120042984]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
