USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[acDepositQueueIso]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[acDepositQueueIso](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[tranId] [bigint] NULL,
	[pBank] [bigint] NULL,
	[toAc] [varchar](100) NULL,
	[toBankCode] [varchar](50) NULL,
	[amount] [money] NULL,
	[remarks] [varchar](max) NULL,
	[status] [varchar](20) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[paidDate] [datetime] NULL,
	[resCode] [varchar](50) NULL,
	[resMsg] [varchar](max) NULL,
	[processDate] [datetime] NULL,
	[processId] [bigint] NULL,
	[referenceId] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
