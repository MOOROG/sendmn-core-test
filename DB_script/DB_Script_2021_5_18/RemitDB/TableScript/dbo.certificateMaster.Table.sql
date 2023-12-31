USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[certificateMaster]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[certificateMaster](
	[requestId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[dcRequestId] [int] NULL,
	[userId] [int] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[requestedBy] [varchar](50) NULL,
	[requestedDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[dcSerialNumber] [varchar](100) NULL,
	[dcUserName] [varchar](100) NULL,
 CONSTRAINT [pk_idx_certificateMaster_requestId] PRIMARY KEY CLUSTERED 
(
	[requestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[certificateMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_9A2CE7C9_236A_4F7A_8B43_7C1125F8BC85_136699885]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
