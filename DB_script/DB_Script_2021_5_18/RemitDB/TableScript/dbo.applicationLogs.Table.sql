USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[applicationLogs]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[applicationLogs](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[module] [int] NULL,
	[logType] [varchar](50) NULL,
	[tableName] [varchar](100) NULL,
	[dataId] [varchar](50) NULL,
	[oldData] [varchar](max) NULL,
	[newData] [varchar](max) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_applicationLogs_rowId] PRIMARY KEY NONCLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicationLogs] ADD  CONSTRAINT [MSrepl_tran_version_default_8FF411BA_94C8_47F6_A5F3_A37D834D8422_205959810]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
