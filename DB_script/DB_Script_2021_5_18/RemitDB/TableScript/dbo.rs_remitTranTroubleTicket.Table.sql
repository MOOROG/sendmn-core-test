USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[rs_remitTranTroubleTicket]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rs_remitTranTroubleTicket](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[refno] [varchar](30) NULL,
	[comments] [varchar](1000) NULL,
	[datePosted] [datetime] NULL,
	[postedBy] [varchar](50) NULL,
	[uploadBy] [varchar](50) NULL,
	[noteType] [varchar](50) NULL,
	[status] [varchar](50) NULL,
	[msrepl_tran_version] [varchar](50) NULL,
	[tranno] [varchar](50) NULL,
	[category] [varchar](4) NULL,
 CONSTRAINT [PK_rs_remitTranTroubleTicket] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
