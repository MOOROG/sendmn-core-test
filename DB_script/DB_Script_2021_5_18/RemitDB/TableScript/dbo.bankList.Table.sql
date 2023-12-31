USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bankList]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bankList](
	[bankId] [int] NULL,
	[bankName] [varchar](200) NULL,
	[extAgentCode] [varchar](10) NULL,
	[location] [varchar](100) NULL,
	[branchId] [varchar](8) NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_bankList_bankId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bankList] ADD  CONSTRAINT [MSrepl_tran_version_default_AC1B6752_0A0C_435D_BF11_ABA0CC75BE10_986082899]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
