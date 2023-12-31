USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[balanceTopUpIntHistory]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[balanceTopUpIntHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[btId] [int] NULL,
	[agentId] [int] NULL,
	[amount] [money] NULL,
	[topUpDate] [datetime] NULL,
	[modType] [varchar](6) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[balanceTopUpIntHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_B7011892_7550_4E1D_A9AB_8E3C3D8B3C19_308560533]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
