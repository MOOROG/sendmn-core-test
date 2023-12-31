USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customerHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customerHistory](
	[ROWID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CUSTOMER_ID] [int] NULL,
	[ID_TYPE] [int] NULL,
	[ID_NO] [varchar](30) NULL,
	[ID_ISSUE_DATE] [datetime] NULL,
	[ID_EXPIRY_DATE] [datetime] NULL,
	[SALARY] [money] NULL,
	[DESIGNATION] [varchar](100) NULL,
	[JOB_NATURE] [varchar](100) NULL,
	[CREATED_DATE] [datetime] NULL,
	[CREATED_BY] [varchar](30) NULL,
	[IS_DELETE] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_customerHistory_ROWID] PRIMARY KEY CLUSTERED 
(
	[ROWID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[customerHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_6B98C6D2_9DC1_40CA_A264_92564A674C77_1117247035]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
