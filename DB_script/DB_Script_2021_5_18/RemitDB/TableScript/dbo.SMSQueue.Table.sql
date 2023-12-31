USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[SMSQueue]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SMSQueue](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[mobileNo] [varchar](200) NULL,
	[email] [varchar](200) NULL,
	[subject] [varchar](200) NULL,
	[msg] [varchar](max) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[sentDate] [datetime] NULL,
	[priorityIndex] [int] NULL,
	[country] [varchar](200) NULL,
	[agentId] [int] NULL,
	[branchId] [int] NULL,
	[controlNo] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[tranId] [bigint] NULL,
	[txnDate] [datetime] NULL,
	[tranType] [char](1) NULL,
	[membershipId] [varchar](50) NULL,
	[isInProcess] [bit] NULL,
	[cc] [varchar](256) NULL,
	[bcc] [varchar](256) NULL,
 CONSTRAINT [pk_idx_SMSQueue_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SMSQueue] ADD  CONSTRAINT [MSrepl_tran_version_default_E8C6347F_CE70_459A_9DAB_7D93B556693C_1146135524]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
