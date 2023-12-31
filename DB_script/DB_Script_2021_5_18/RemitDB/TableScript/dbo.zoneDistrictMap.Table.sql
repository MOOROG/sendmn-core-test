USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[zoneDistrictMap]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zoneDistrictMap](
	[districtId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[zone] [int] NULL,
	[regionId] [int] NULL,
	[districtName] [varchar](30) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[isDeleted] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_zoneDistrictMap_districtId] PRIMARY KEY CLUSTERED 
(
	[districtId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[zoneDistrictMap] ADD  CONSTRAINT [MSrepl_tran_version_default_BF997E4C_332E_4325_9E47_0A6B4CC9E013_1172459501]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
