USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[api_districtList]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[api_districtList](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[code] [int] NULL,
	[districtCode] [int] NULL,
	[districtName] [varchar](50) NULL,
	[fromAPI] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_api_districtList_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[api_districtList] ADD  CONSTRAINT [MSrepl_tran_version_default_C8815FA5_59CF_4914_B839_7118C201CC4B_313872285]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
