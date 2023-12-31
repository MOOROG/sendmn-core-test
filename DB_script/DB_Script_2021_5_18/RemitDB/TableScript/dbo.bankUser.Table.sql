USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bankUser]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bankUser](
	[Sno] [float] NULL,
	[Ext# Bank Name] [nvarchar](255) NULL,
	[Branch] [nvarchar](255) NULL,
	[AgentID] [nvarchar](255) NULL,
	[EmployeeID] [float] NULL,
	[USERID] [nvarchar](255) NULL,
	[MapCodeInt] [float] NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_bankUser_Sno] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bankUser] ADD  CONSTRAINT [MSrepl_tran_version_default_02412A9C_D0F9_483D_8BA7_881E85462352_1160703533]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
