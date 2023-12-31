USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[enrollCommSetup]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[enrollCommSetup](
	[enrollCommId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[isDeleted] [varchar](1) NULL,
	[commRate] [int] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__enrollCo__3213E83F3575474C] PRIMARY KEY CLUSTERED 
(
	[enrollCommId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[enrollCommSetup] ADD  CONSTRAINT [MSrepl_tran_version_default_3329DD28_E68A_4CBE_BF97_407CEABDCDE3_1040878925]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
