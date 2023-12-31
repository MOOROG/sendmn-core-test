USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranCancelrequest]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranCancelrequest](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[tranId] [varchar](50) NULL,
	[controlNo] [varchar](50) NULL,
	[cancelReason] [varchar](max) NULL,
	[cancelStatus] [varchar](20) NULL,
	[scRefund] [money] NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](100) NULL,
	[approvedRemarks] [varchar](max) NULL,
	[teller] [varchar](100) NULL,
	[refundDate] [datetime] NULL,
	[assignTellerDate] [datetime] NULL,
	[assignTellerBy] [varchar](100) NULL,
	[tranStatus] [varchar](50) NULL,
	[isScRefund] [varchar](1) NULL,
 CONSTRAINT [pk_idx_tranCancelrequest_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
