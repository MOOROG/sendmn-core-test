USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customerTxnLimit]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customerTxnLimit](
	[sno] [int] IDENTITY(1,2) NOT FOR REPLICATION NOT NULL,
	[customer_passport] [varchar](50) NOT NULL,
	[paidAmt] [money] NOT NULL,
	[trans_date] [datetime] NOT NULL,
	[agent_id] [varchar](50) NOT NULL,
	[update_ts] [datetime] NOT NULL,
	[nos_of_txn] [int] NULL,
	[customer_name] [varchar](100) NULL,
	[customer_id_type] [varchar](100) NULL,
 CONSTRAINT [PK_customer_trans_limit] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
