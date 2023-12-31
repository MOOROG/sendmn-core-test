USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[enrollCommSetupHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[enrollCommSetupHistory](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[commRate] [int] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[enrollCommSetupHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_4798DAD2_BDBC_40F5_80BE_C105CBC7B272_928878526]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
