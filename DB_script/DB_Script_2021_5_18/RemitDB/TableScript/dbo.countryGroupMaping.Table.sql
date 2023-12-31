USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[countryGroupMaping]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[countryGroupMaping](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[countryId] [int] NULL,
	[groupCat] [int] NULL,
	[groupDetail] [int] NULL,
	[createdBy] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[isActive] [char](10) NULL,
	[isDeleted] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_countryGroupMaping_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countryGroupMaping] ADD  CONSTRAINT [MSrepl_tran_version_default_8392CCAD_DD69_4048_8E75_A289C092D65D_1436792426]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
