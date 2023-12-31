USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranViewHistory]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranViewHistory](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[controlNumber] [varchar](30) NULL,
	[tranViewType] [varchar](50) NULL,
	[agentId] [int] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[dcInfo] [varchar](500) NULL,
	[tranId] [bigint] NULL,
	[remarks] [varchar](max) NULL,
	[ipAddress] [varchar](20) NULL,
 CONSTRAINT [PK__tranView__3213E83F247EFA1D] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
