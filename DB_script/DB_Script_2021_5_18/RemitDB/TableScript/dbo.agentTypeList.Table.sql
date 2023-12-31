USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentTypeList]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentTypeList](
	[ROWID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SAGENT_ID] [int] NULL,
	[RAGENT_ID] [int] NULL,
	[CREATED_DATE] [datetime] NULL,
	[CREATED_BY] [varchar](30) NULL,
	[MODIFY_BY] [varchar](30) NULL,
	[MODIFY_DATE] [datetime] NULL,
	[IS_DELETE] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentTypeList_ROWID] PRIMARY KEY CLUSTERED 
(
	[ROWID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentTypeList] ADD  CONSTRAINT [MSrepl_tran_version_default_FEF5C629_57A1_43DF_A4B7_E06225CD1953_1488724356]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
