USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempRemitTranLT]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempRemitTranLT](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ControlNo] [varchar](20) NULL,
	[sAgent] [int] NULL,
	[sBranch] [int] NULL,
	[pAmt] [money] NULL,
	[ControlNoDom] [varchar](50) NULL,
 CONSTRAINT [pk_idx_tempRemitTranLT_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
