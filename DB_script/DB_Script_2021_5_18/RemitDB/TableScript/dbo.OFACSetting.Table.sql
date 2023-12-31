USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[OFACSetting]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OFACSetting](
	[ROWID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[OFAC_TRACKER] [varchar](20) NULL,
	[OFAC_TRAN] [varchar](20) NULL,
	[CREATED_BY] [varchar](30) NULL,
	[CREATED_DATE] [datetime] NULL,
	[MODIFY_BY] [varchar](30) NULL,
	[MODIFY_DATE] [datetime] NULL,
	[IS_DELETE] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_OFACSetting_ROWID] PRIMARY KEY CLUSTERED 
(
	[ROWID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OFACSetting] ADD  CONSTRAINT [MSrepl_tran_version_default_AC7D55B1_73B9_4B66_B6DF_88498623EFBB_1402644240]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
