USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[occupationMaster]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[occupationMaster](
	[occupationId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[detailTitle] [varchar](50) NULL,
	[detailDesc] [varchar](50) NULL,
	[riskFactor] [varchar](20) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_occupationMaster_occupationId] PRIMARY KEY CLUSTERED 
(
	[occupationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[occupationMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_A0618842_ADB8_473F_806B_05FC86BE159F_1188563668]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
