USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[locationGroupMaping]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[locationGroupMaping](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[districtCode] [int] NULL,
	[groupCat] [int] NULL,
	[groupDetail] [int] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_locationGroupMaping_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[locationGroupMaping] ADD  CONSTRAINT [MSrepl_tran_version_default_5E941C41_B6B2_4C45_9587_886E3EAC28F3_735549904]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
