USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranModifyRejectLog]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranModifyRejectLog](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tranId] [bigint] NULL,
	[controlNo] [varchar](50) NULL,
	[message] [varchar](max) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[rejectedBy] [varchar](50) NULL,
	[rejectedDate] [datetime] NULL,
	[fieldName] [varchar](50) NULL,
	[fieldValue] [varchar](max) NULL,
 CONSTRAINT [pk_idx_tranModifyRejectLog_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
