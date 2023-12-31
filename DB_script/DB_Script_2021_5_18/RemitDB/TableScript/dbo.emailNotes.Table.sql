USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[emailNotes]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emailNotes](
	[notesId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[sendFrom] [varchar](100) NULL,
	[sendTo] [varchar](500) NULL,
	[sendCc] [varchar](500) NULL,
	[sendBcc] [varchar](500) NULL,
	[subject] [varchar](250) NULL,
	[notesText] [varchar](max) NULL,
	[notesAttachmentFilename] [varchar](500) NULL,
	[activeFlag] [char](1) NULL,
	[sendStatus] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
 CONSTRAINT [pk_idx_emailNotes_notesId] PRIMARY KEY CLUSTERED 
(
	[notesId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[emailNotes] ADD  CONSTRAINT [MSrepl_tran_version_default_62B0F529_2104_4E9A_9790_34F87E6D3062_2121058592]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
ALTER TABLE [dbo].[emailNotes] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
