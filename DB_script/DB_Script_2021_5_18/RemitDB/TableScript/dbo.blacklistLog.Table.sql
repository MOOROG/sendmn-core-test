USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[blacklistLog]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[blacklistLog](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[totalRecord] [int] NULL,
	[dataSource] [varchar](30) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[ofacDate] [date] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_blacklistLog_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[blacklistLog] ADD  CONSTRAINT [MSrepl_tran_version_default_426D4410_D932_4186_9073_374EF1ECC41C_2129598825]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
