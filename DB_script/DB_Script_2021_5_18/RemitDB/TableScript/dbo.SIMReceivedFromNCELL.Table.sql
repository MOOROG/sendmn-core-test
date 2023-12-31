USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[SIMReceivedFromNCELL]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SIMReceivedFromNCELL](
	[iccId] [varchar](20) NULL,
	[mobile] [varchar](10) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[isDeleted] [varchar](1) NULL,
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_simReceivedfromNcell] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SIMReceivedFromNCELL] ADD  CONSTRAINT [MSrepl_tran_version_default_EE093709_A2A9_4BD8_A4B4_C4AA3A72F85F_1054991185]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
