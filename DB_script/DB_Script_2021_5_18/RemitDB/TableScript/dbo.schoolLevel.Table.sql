USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[schoolLevel]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[schoolLevel](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[schoolId] [int] NULL,
	[levelId] [int] NULL,
	[name] [varchar](200) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[isDeleted] [varchar](1) NULL,
	[isActive] [varchar](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_schoolLevel] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[schoolLevel] ADD  CONSTRAINT [MSrepl_tran_version_default_CAF4AD19_70BB_47A7_AD3C_CDD552DDAE65_59511641]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
