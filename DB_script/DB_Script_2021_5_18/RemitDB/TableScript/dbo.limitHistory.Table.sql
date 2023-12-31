USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[limitHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[limitHistory](
	[ROWID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AGENT_ID] [int] NULL,
	[AC_ID] [int] NULL,
	[DR_LIMIT] [varchar](30) NULL,
	[LIMIT_EXPIRY] [datetime] NULL,
	[UTILISED_AMT] [varchar](30) NULL,
	[AVL_AMT] [varchar](30) NULL,
	[CREATED_BY] [varchar](30) NULL,
	[CREATED_DATE] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_limitHistory_ROWID] PRIMARY KEY CLUSTERED 
(
	[ROWID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[limitHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_FBAB0613_F006_41EF_97DC_2A827951BC7D_1264723558]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
