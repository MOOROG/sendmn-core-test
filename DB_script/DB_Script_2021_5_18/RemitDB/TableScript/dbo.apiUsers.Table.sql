USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[apiUsers]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiUsers](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[districtId] [int] NULL,
	[userCode] [varchar](30) NULL,
	[userName] [varchar](50) NULL,
	[password] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_apiUsers_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[apiUsers] ADD  CONSTRAINT [MSrepl_tran_version_default_2A5819FF_33EE_4618_B4E9_93AB719799DD_694397643]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
