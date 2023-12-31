USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[categoryContact]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[categoryContact](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[categoryName] [varchar](200) NULL,
	[categoryDesc] [varchar](200) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[isDeleted] [varchar](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_categoryContact] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[categoryContact] ADD  CONSTRAINT [MSrepl_tran_version_default_BCBD7D86_8FEC_4289_9CA2_11093A3366F4_732073894]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
