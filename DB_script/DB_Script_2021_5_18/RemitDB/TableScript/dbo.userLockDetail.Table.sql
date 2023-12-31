USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[userLockDetail]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userLockDetail](
	[userLockId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[userId] [int] NULL,
	[startDate] [datetime] NULL,
	[endDate] [datetime] NULL,
	[lockDesc] [varchar](max) NULL,
	[startExec] [varchar](1) NULL,
	[startExecDate] [datetime] NULL,
	[endExec] [varchar](1) NULL,
	[endExecDate] [datetime] NULL,
	[createdBy] [varchar](200) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](200) NULL,
	[modifiedDate] [datetime] NULL,
	[isDeleted] [varchar](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_userLockDetail] PRIMARY KEY CLUSTERED 
(
	[userLockId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[userLockDetail] ADD  CONSTRAINT [MSrepl_tran_version_default_393C7FAA_E02D_4DEB_9F1A_94BDCDD20DB8_905926449]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
