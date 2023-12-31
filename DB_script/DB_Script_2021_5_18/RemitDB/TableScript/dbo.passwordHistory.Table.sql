USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[passwordHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[passwordHistory](
	[userName] [varchar](50) NULL,
	[pwd] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](80) NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_passwordHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[passwordHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_4D24D04F_4D2D_4E8F_9881_3945EC4361B5_1384496111]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
