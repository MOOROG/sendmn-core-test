USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[emailServerSetup]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emailServerSetup](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[smtpServer] [varchar](200) NULL,
	[smtpPort] [varchar](200) NULL,
	[sendID] [varchar](200) NULL,
	[sendPSW] [varchar](200) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[enableSsl] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_emailServerSetup] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[emailServerSetup] ADD  CONSTRAINT [MSrepl_tran_version_default_D47AD5A3_AABF_40B9_B6E0_FAECCF990869_284072298]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
