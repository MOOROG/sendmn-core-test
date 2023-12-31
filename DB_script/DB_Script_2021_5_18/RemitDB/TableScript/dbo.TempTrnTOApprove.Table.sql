USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TempTrnTOApprove]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempTrnTOApprove](
	[TempId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[v_type] [char](3) NULL,
	[Remarks] [varchar](2000) NULL,
	[TranCode] [varchar](100) NULL,
	[TranDate] [date] NULL,
	[Amount] [money] NULL,
	[TransitRate] [money] NULL,
	[DrAcc] [varchar](50) NULL,
	[CrAcc] [varchar](50) NULL,
	[CreatedBy] [varchar](100) NULL,
	[CreatedDate] [date] NULL,
	[Status] [char](3) NULL,
 CONSTRAINT [pk_idx_TempTrnTOApprove_TempId] PRIMARY KEY CLUSTERED 
(
	[TempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
