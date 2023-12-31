USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[applicationMessage]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[applicationMessage](
	[msgId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[msgSubject] [varchar](max) NULL,
	[msgBody] [varchar](max) NULL,
	[msgDate] [datetime] NULL,
	[msgFrom] [varchar](30) NULL,
	[msgTo] [varchar](30) NULL,
	[sendEmailAlso] [char](1) NULL,
	[msgStatus] [varchar](10) NULL,
	[del] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_applicationMessage_msgId] PRIMARY KEY CLUSTERED 
(
	[msgId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicationMessage] ADD  CONSTRAINT [MSrepl_tran_version_default_FF491F2D_5582_4CD2_97A2_0A21F5044A08_165575628]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
