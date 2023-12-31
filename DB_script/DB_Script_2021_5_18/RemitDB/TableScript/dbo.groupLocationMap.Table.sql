USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[groupLocationMap]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[groupLocationMap](
	[groupLocationMapId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[groupId] [int] NULL,
	[districtId] [int] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_payoutLocation] PRIMARY KEY CLUSTERED 
(
	[groupLocationMapId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[groupLocationMap] ADD  CONSTRAINT [MSrepl_tran_version_default_FD73F3BE_81C8_4A62_9255_FA435F6EADEE_276300144]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
