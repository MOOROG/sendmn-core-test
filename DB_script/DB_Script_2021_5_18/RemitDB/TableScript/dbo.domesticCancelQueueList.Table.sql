USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[domesticCancelQueueList]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[domesticCancelQueueList](
	[controlNo] [varchar](50) NOT NULL,
	[controlNoSwiftEnc] [varchar](30) NULL,
	[controlNoInficareEnc] [varchar](30) NULL,
 CONSTRAINT [pk_idx_domesticCancelQueueList_] PRIMARY KEY CLUSTERED 
(
	[controlNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
