USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[BlackListSound]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlackListSound](
	[rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[BlackListId] [bigint] NULL,
	[FN1] [varchar](5) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_BlackListSound_rowId] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BlackListSound] ADD  CONSTRAINT [MSrepl_tran_version_default_9FA7D2BF_65D6_4326_BA89_3CF38CEA8F5A_2119170795]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
