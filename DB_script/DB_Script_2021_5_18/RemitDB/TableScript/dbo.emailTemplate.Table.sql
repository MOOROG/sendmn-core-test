USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[emailTemplate]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emailTemplate](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[templateName] [varchar](200) NULL,
	[emailSubject] [varchar](500) NULL,
	[isEnabled] [varchar](1) NULL,
	[isResponseToAgent] [varchar](1) NULL,
	[emailFormat] [nvarchar](max) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[isDeleted] [varchar](1) NULL,
	[templateFor] [varchar](50) NULL,
	[replyTo] [varchar](20) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_emailTemplate] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[emailTemplate] ADD  CONSTRAINT [MSrepl_tran_version_default_50641E0F_D977_4FA7_9DBF_32E59F6FBE8A_472596972]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
