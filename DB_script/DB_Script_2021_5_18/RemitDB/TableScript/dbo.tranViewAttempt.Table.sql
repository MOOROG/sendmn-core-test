USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranViewAttempt]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranViewAttempt](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[userName] [varchar](50) NULL,
	[continuosAttempt] [int] NULL,
	[wholeDayAttempt] [int] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_tranViewAttempt_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tranViewAttempt] ADD  CONSTRAINT [MSrepl_tran_version_default_90BAB629_03B0_4011_8BBC_15DC9E661C19_1495884596]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
