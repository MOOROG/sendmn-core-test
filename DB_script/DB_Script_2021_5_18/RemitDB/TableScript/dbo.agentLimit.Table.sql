USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentLimit]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentLimit](
	[ROWID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AGENT_ID] [int] NULL,
	[AC_ID] [int] NULL,
	[AC_NUM] [varchar](50) NULL,
	[DR_LIMIT] [money] NULL,
	[LIMIT_EXPIRY] [datetime] NULL,
	[UTILISED_AMT] [money] NULL,
	[AVL_AMT] [money] NULL,
	[CREATED_BY] [varchar](30) NULL,
	[CREATED_DATE] [datetime] NULL,
	[MODIFY_BY] [varchar](30) NULL,
	[MODIFY_DATE] [datetime] NULL,
	[IS_DELETE] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentLimit_ROWID] PRIMARY KEY CLUSTERED 
(
	[ROWID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentLimit] ADD  CONSTRAINT [MSrepl_tran_version_default_D021CC33_8CB5_4837_8112_65D0F30C15E2_852198086]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
