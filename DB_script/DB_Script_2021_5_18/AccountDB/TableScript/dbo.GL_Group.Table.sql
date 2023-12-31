USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[GL_Group]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GL_Group](
	[gl_code] [int] IDENTITY(1,1) NOT NULL,
	[gl_name] [varchar](200) NULL,
	[p_id] [varchar](20) NULL,
	[bal_grp] [varchar](20) NULL,
	[tree_sape] [varchar](500) NULL,
	[AccPrefix] [varchar](10) NULL,
	[SeqNo] [int] NULL,
	[seq_Number] [int] NULL,
	[acc_Prefix] [varchar](20) NULL
) ON [PRIMARY]
GO
