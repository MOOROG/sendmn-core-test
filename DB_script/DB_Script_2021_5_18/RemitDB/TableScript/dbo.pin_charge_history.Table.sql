USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[pin_charge_history]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pin_charge_history](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[deno] [money] NULL,
	[qty] [int] NULL,
	[reqDate] [datetime] NULL,
	[reqBy] [varchar](100) NULL,
	[agentId] [int] NULL,
	[sAgentId] [int] NULL,
	[pinCode] [varchar](100) NULL,
	[pinSN] [float] NULL,
	[pinExpDate] [datetime] NULL,
	[pinLogId] [varchar](50) NULL,
 CONSTRAINT [PK_pin_charge_history] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
