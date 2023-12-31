USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[cisDetailHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisDetailHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[cisDetailId] [bigint] NULL,
	[condition] [int] NULL,
	[collMode] [int] NULL,
	[paymentMode] [int] NULL,
	[tranCount] [int] NULL,
	[amount] [money] NULL,
	[period] [int] NULL,
	[isEnable] [char](1) NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_cisDetailHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cisDetailHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_00207B20_ED85_4E41_B74C_C2330E7FACEF_2052970440]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
