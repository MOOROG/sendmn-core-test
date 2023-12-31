USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CUSTOMER_DEPOSIT_LOGS]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CUSTOMER_DEPOSIT_LOGS](
	[tranId] [bigint] IDENTITY(1,1) NOT NULL,
	[tranDate] [datetime] NOT NULL,
	[depositAmount] [money] NOT NULL,
	[paymentAmount] [money] NOT NULL,
	[particulars] [nvarchar](500) NOT NULL,
	[closingBalance] [money] NOT NULL,
	[isAuto] [bit] NOT NULL,
	[bankName] [nvarchar](150) NOT NULL,
	[processedBy] [varchar](50) NULL,
	[processedDate] [datetime] NULL,
	[customerId] [bigint] NULL,
	[isSkipped] [bit] NULL,
	[skippedBy] [varchar](50) NULL,
	[skippedDate] [datetime] NULL,
	[isSettled] [bit] NULL,
	[TRAN_ID] [bigint] NULL,
	[approvedby] [varchar](50) NULL,
	[approveddate] [datetime] NULL,
	[skipRemarks] [varchar](150) NULL,
	[isEODDone] [bit] NULL,
	[downloadDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[tranId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
