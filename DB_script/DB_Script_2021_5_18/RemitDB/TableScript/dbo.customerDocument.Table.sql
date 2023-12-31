USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customerDocument]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customerDocument](
	[cdId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[customerId] [int] NULL,
	[fileName] [varchar](80) NULL,
	[fileDescription] [varchar](100) NULL,
	[fileType] [varchar](20) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[agentId] [int] NULL,
	[branchId] [int] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[isProfilePic] [char](1) NULL,
	[isKycDoc] [char](1) NULL,
	[isOnlineDoc] [varchar](1) NULL,
	[documentFolder] [varchar](100) NULL,
	[sessionId] [varchar](60) NULL,
	[documentType] [int] NULL,
	[archivedBy] [varchar](50) NULL,
	[archivedDate] [datetime] NULL,
 CONSTRAINT [PK__customer__289C55843652C63E] PRIMARY KEY CLUSTERED 
(
	[cdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[customerDocument] ADD  CONSTRAINT [MSrepl_tran_version_default_5D2A1F47_025C_4745_AA89_8E539B7F23E0_1572565036]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
