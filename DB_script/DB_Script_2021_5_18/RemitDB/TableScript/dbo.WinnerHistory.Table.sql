USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[WinnerHistory]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WinnerHistory](
	[ID] [int] NOT NULL,
	[srFlag] [char](1) NULL,
	[ldDate] [datetime] NULL,
	[drawType] [char](1) NULL,
	[luckyDrawFor] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[controlNo] [varchar](50) NULL,
	[drawnDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL,
	[senderName] [varchar](200) NULL,
 CONSTRAINT [pk_idx_WinnerHistory_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WinnerHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_9FEBDE33_FCE2_421A_B985_580D4ABA7893_520037284]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
