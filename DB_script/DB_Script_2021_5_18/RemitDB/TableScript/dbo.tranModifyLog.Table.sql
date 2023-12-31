USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranModifyLog]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranModifyLog](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tranId] [bigint] NULL,
	[controlNo] [varchar](20) NULL,
	[message] [nvarchar](1000) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[fileType] [varchar](20) NULL,
	[MsgType] [varchar](50) NULL,
	[dcInfo] [varchar](500) NULL,
	[status] [varchar](50) NULL,
	[resolvedBy] [varchar](50) NULL,
	[resolvedDate] [datetime] NULL,
	[fieldName] [varchar](50) NULL,
	[fieldValue] [varchar](max) NULL,
	[oldValue] [varchar](200) NULL,
	[ScChargeMod] [money] NULL,
	[needToSync] [bit] NULL,
 CONSTRAINT [PK_tranModifyLog] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
