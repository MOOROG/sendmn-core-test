USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bankBranchList]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bankBranchList](
	[bankId] [int] NULL,
	[bankName] [varchar](200) NULL,
	[extAgentCode] [varchar](10) NULL,
	[location] [varchar](100) NULL,
	[branchId] [varchar](8) NULL,
	[locationId] [int] NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_bankBranchList_branchId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bankBranchList] ADD  CONSTRAINT [MSrepl_tran_version_default_C0E7F719_C624_413B_AD17_445A37369665_1018083013]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
